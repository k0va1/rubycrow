class RedditPost < ApplicationRecord
  SUBREDDITS = %w[ruby rails].freeze
  FEED_TIMEOUT = 15

  has_many :newsletter_items, as: :linkable, dependent: :nullify

  validates :reddit_id, presence: true, uniqueness: true
  validates :title, presence: true
  validates :url, presence: true
  validates :subreddit, presence: true, inclusion: {in: SUBREDDITS}

  default_scope { order(posted_at: :desc) }

  scope :recent, ->(limit = 15) { limit(limit) }
  scope :unprocessed, -> { where(processed: false) }
  scope :from_subreddit, ->(sub) { where(subreddit: sub) }
  scope :featured, -> { where.not(featured_in_issue: nil) }
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
      update_only: %i[title url score num_comments last_synced_at]
    )
  rescue Faraday::Error, Feedjira::NoParserAvailable => e
    Rails.logger.error("RedditPost sync failed: #{e.message}")
    []
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

  def self.http_client
    @http_client ||= Faraday.new(ssl: {min_version: OpenSSL::SSL::TLS1_2_VERSION}) do |f|
      f.headers["User-Agent"] = "RubyCrow/1.0 (+https://rubycrow.com)"
      f.response :follow_redirects
      f.adapter Faraday.default_adapter
    end
  end

  private_class_method :fetch_feed, :extract_reddit_id, :extract_external_url, :http_client
end
