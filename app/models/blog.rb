class Blog < ApplicationRecord
  include RssParseable

  REGISTRY_URL = "https://raw.githubusercontent.com/k0va1/rubycrow/master/data/blogs.yml"

  has_many :articles, dependent: :destroy

  validates :name, presence: true
  validates :url, presence: true, uniqueness: true
  validates :rss_url, presence: true, uniqueness: true

  scope :active, -> { where(active: true) }

  def self.sync_from_registry
    response = Faraday.get(REGISTRY_URL)
    entries = YAML.safe_load(response.body, permitted_classes: [Symbol])
    registry_urls = []

    entries.each do |entry|
      blog = find_or_initialize_by(url: entry["url"])
      blog.assign_attributes(
        name: entry["name"],
        rss_url: entry["rss_url"],
        description: entry["description"],
        tags: entry["tags"] || [],
        twitter: entry["twitter"],
        github_pr_url: entry["github_pr_url"],
        active: true
      )
      blog.save!
      registry_urls << entry["url"]
    end

    where.not(url: registry_urls).update_all(active: false)
  end
end
