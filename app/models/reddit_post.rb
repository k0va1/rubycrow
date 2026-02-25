# == Schema Information
#
# Table name: reddit_posts
#
#  id                :bigint           not null, primary key
#  author            :string
#  external_url      :string
#  featured_in_issue :integer
#  first_seen_at     :datetime
#  last_synced_at    :datetime
#  num_comments      :integer          default(0)
#  posted_at         :datetime
#  processed         :boolean          default(FALSE)
#  score             :integer          default(0)
#  subreddit         :string           not null
#  title             :string           not null
#  url               :string           not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  reddit_id         :string           not null
#
# Indexes
#
#  index_reddit_posts_on_featured_in_issue  (featured_in_issue)
#  index_reddit_posts_on_posted_at          (posted_at)
#  index_reddit_posts_on_processed          (processed)
#  index_reddit_posts_on_reddit_id          (reddit_id) UNIQUE
#  index_reddit_posts_on_score              (score)
#  index_reddit_posts_on_subreddit          (subreddit)
#
class RedditPost < ApplicationRecord
  include NewsletterSource
  include HttpFetchable

  SUBREDDITS = %w[ruby rails].freeze
  FEED_TIMEOUT = 15

  validates :reddit_id, presence: true, uniqueness: true
  validates :title, presence: true
  validates :url, presence: true
  validates :subreddit, presence: true, inclusion: {in: SUBREDDITS}

  scope :by_post_date, -> { order(posted_at: :desc) }
  scope :from_subreddit, ->(sub) { where(subreddit: sub) }
  scope :search_by_title, ->(query) { where("title ILIKE ?", "%#{sanitize_sql_like(query)}%") }

  def self.sync_from_api!
    records = {}

    SUBREDDITS.each do |subreddit|
      records.merge!(fetch_feed(subreddit))
    end

    return [] if records.empty?

    now = Time.current
    rows = records.values.map { |r| r.merge(first_seen_at: now, last_synced_at: now) }

    upsert_all(
      rows,
      unique_by: :index_reddit_posts_on_reddit_id,
      update_only: %i[title url last_synced_at]
    )
  end

  def self.fetch_feed(subreddit)
    rss_url = "https://www.reddit.com/r/#{subreddit}/hot/.rss?limit=50"
    response = http_client.get(rss_url) do |req|
      req.options.timeout = FEED_TIMEOUT
      req.options.open_timeout = FEED_TIMEOUT
    end

    feed = Feedjira.parse(response.body)

    feed.entries.each_with_object({}) do |entry, hash|
      next if entry.title.blank?

      permalink = entry.url.to_s.strip
      rid = extract_reddit_id(permalink)
      next if rid.blank?

      hash[rid] = {
        reddit_id: rid,
        title: entry.title.strip,
        url: permalink,
        external_url: extract_external_url(entry),
        score: 0,
        author: entry.try(:author)&.strip,
        subreddit: subreddit,
        num_comments: 0,
        posted_at: entry.published
      }
    end
  rescue Faraday::Error, Feedjira::NoParserAvailable => e
    Rails.logger.error("Failed to fetch Reddit feed for r/#{subreddit}: #{e.message}")
    {}
  end

  def self.extract_reddit_id(permalink)
    match = permalink.match(%r{/comments/([a-z0-9]+)}i)
    match&.captures&.first
  end

  def self.extract_external_url(entry)
    content = entry.try(:content) || entry.try(:summary) || ""
    match = content.match(%r{<a href="(https?://[^"]+)">\[link\]</a>})
    link = match&.captures&.first
    return nil if link.blank? || link.include?("reddit.com")
    link
  end

  private_class_method :fetch_feed, :extract_reddit_id, :extract_external_url
end
