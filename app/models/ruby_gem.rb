# == Schema Information
#
# Table name: ruby_gems
#
#  id                 :bigint           not null, primary key
#  activity_type      :string           not null
#  authors            :string
#  downloads          :integer          default(0)
#  featured_in_issue  :integer
#  first_seen_at      :datetime
#  homepage_url       :string
#  info               :text
#  last_synced_at     :datetime
#  licenses           :text             default([]), is an Array
#  name               :string           not null
#  processed          :boolean          default(FALSE)
#  project_url        :string           not null
#  source_code_url    :string
#  version            :string           not null
#  version_created_at :datetime
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#
# Indexes
#
#  index_ruby_gems_on_activity_type       (activity_type)
#  index_ruby_gems_on_downloads           (downloads)
#  index_ruby_gems_on_featured_in_issue   (featured_in_issue)
#  index_ruby_gems_on_name                (name) UNIQUE
#  index_ruby_gems_on_processed           (processed)
#  index_ruby_gems_on_version_created_at  (version_created_at)
#
class RubyGem < ApplicationRecord
  API_BASE = "https://rubygems.org/api/v1/activity"
  API_TIMEOUT = 15
  ACTIVITY_TYPES = %w[new updated].freeze

  has_many :newsletter_items, as: :linkable, dependent: :nullify

  validates :name, presence: true, uniqueness: true
  validates :version, presence: true
  validates :project_url, presence: true
  validates :activity_type, presence: true, inclusion: {in: ACTIVITY_TYPES}

  default_scope { order(version_created_at: :desc) }

  scope :recent, ->(limit = 15) { limit(limit) }
  scope :unprocessed, -> { where(processed: false) }
  scope :newly_created, -> { where(activity_type: "new") }
  scope :recently_updated, -> { where(activity_type: "updated") }
  scope :featured, -> { where.not(featured_in_issue: nil) }
  scope :search_by_name, ->(query) { where("name ILIKE ?", "%#{sanitize_sql_like(query)}%") }
  scope :popular, -> { unscoped.order(downloads: :desc) }

  def self.sync_from_api!
    updated_gems = fetch_gems("just_updated.json", "updated")
    new_gems = fetch_gems("latest.json", "new")

    records = updated_gems.merge(new_gems)
    return [] if records.empty?

    now = Time.current
    rows = records.values.map { |r| r.merge(first_seen_at: now, last_synced_at: now) }

    upsert_all(
      rows,
      unique_by: :index_ruby_gems_on_name,
      update_only: %i[version authors info licenses downloads project_url homepage_url source_code_url version_created_at activity_type last_synced_at]
    )
  rescue Faraday::Error, JSON::ParserError => e
    Rails.logger.error("RubyGem sync failed: #{e.message}")
    []
  end

  def self.fetch_gems(endpoint, activity_type)
    response = http_client.get("#{API_BASE}/#{endpoint}") do |req|
      req.options.timeout = API_TIMEOUT
      req.options.open_timeout = API_TIMEOUT
    end

    gems = JSON.parse(response.body)

    gems.each_with_object({}) do |gem_data, hash|
      name = gem_data["name"]
      next if name.blank?

      hash[name] = {
        name: name,
        version: gem_data["version"],
        authors: gem_data["authors"],
        info: gem_data["info"]&.squish,
        licenses: gem_data["licenses"] || [],
        downloads: gem_data["downloads"].to_i,
        project_url: gem_data["project_uri"] || "https://rubygems.org/gems/#{name}",
        homepage_url: gem_data["homepage_uri"],
        source_code_url: gem_data["source_code_uri"],
        version_created_at: gem_data["version_created_at"],
        activity_type: activity_type
      }
    end
  rescue Faraday::Error, JSON::ParserError => e
    Rails.logger.error("Failed to fetch #{endpoint}: #{e.message}")
    {}
  end

  def self.http_client
    @http_client ||= Faraday.new(ssl: {min_version: OpenSSL::SSL::TLS1_2_VERSION}) do |f|
      f.headers["User-Agent"] = "RubyCrow/1.0 (+https://rubycrow.com)"
      f.response :follow_redirects
      f.adapter Faraday.default_adapter
    end
  end

  private_class_method :fetch_gems, :http_client
end
