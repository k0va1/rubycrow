# == Schema Information
#
# Table name: github_repos
#
#  id                :bigint           not null, primary key
#  description       :text
#  featured_in_issue :integer
#  first_seen_at     :datetime
#  forks             :integer          default(0)
#  full_name         :string           not null
#  language          :string
#  last_synced_at    :datetime
#  name              :string           not null
#  owner_avatar_url  :string
#  owner_name        :string
#  processed         :boolean          default(FALSE)
#  repo_created_at   :datetime
#  repo_pushed_at    :datetime
#  stars             :integer          default(0)
#  topics            :text             default([]), is an Array
#  url               :string           not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#
# Indexes
#
#  index_github_repos_on_featured_in_issue  (featured_in_issue)
#  index_github_repos_on_full_name          (full_name) UNIQUE
#  index_github_repos_on_processed          (processed)
#  index_github_repos_on_repo_pushed_at     (repo_pushed_at)
#  index_github_repos_on_stars              (stars)
#
class GithubRepo < ApplicationRecord
  include NewsletterSource
  include HttpFetchable

  API_BASE = "https://api.github.com/search/repositories"
  API_TIMEOUT = 15

  validates :full_name, presence: true, uniqueness: true
  validates :name, presence: true
  validates :url, presence: true

  scope :by_push_date, -> { order(repo_pushed_at: :desc) }
  scope :search_by_name, ->(query) { where("full_name ILIKE ?", "%#{sanitize_sql_like(query)}%") }
  scope :popular, -> { order(stars: :desc) }

  def self.sync_from_api!
    daily_repos = fetch_repos(1.day.ago)
    weekly_repos = fetch_repos(1.week.ago)

    records = weekly_repos.merge(daily_repos)
    return [] if records.empty?

    now = Time.current
    rows = records.values.map { |r| r.merge(first_seen_at: now, last_synced_at: now) }

    upsert_all(
      rows,
      unique_by: :index_github_repos_on_full_name,
      update_only: %i[name description url stars forks language owner_name owner_avatar_url topics repo_pushed_at last_synced_at]
    )
  end

  def self.fetch_repos(pushed_after)
    date = pushed_after.strftime("%Y-%m-%d")
    response = github_client.get(API_BASE) do |req|
      req.params["q"] = "language:ruby pushed:>#{date}"
      req.params["sort"] = "stars"
      req.params["order"] = "desc"
      req.params["per_page"] = 50
      req.options.timeout = API_TIMEOUT
      req.options.open_timeout = API_TIMEOUT
    end

    data = JSON.parse(response.body)
    items = data["items"] || []

    items.each_with_object({}) do |repo, hash|
      full_name = repo["full_name"]
      next if full_name.blank?

      hash[full_name] = {
        full_name: full_name,
        name: repo["name"],
        description: repo["description"]&.squish,
        url: repo["html_url"],
        stars: repo["stargazers_count"].to_i,
        forks: repo["forks_count"].to_i,
        language: repo["language"],
        owner_name: repo.dig("owner", "login"),
        owner_avatar_url: repo.dig("owner", "avatar_url"),
        topics: repo["topics"] || [],
        repo_created_at: repo["created_at"],
        repo_pushed_at: repo["pushed_at"]
      }
    end
  rescue Faraday::Error, JSON::ParserError => e
    Rails.logger.error("Failed to fetch GitHub repos (pushed>#{date}): #{e.message}")
    {}
  end

  def self.github_client
    token = Rails.application.credentials.github_token
    headers = {"Accept" => "application/vnd.github+json"}
    headers["Authorization"] = "Bearer #{token}" if token.present?
    http_client(headers: headers)
  end

  private_class_method :fetch_repos, :github_client
end
