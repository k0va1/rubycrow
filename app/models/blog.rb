# == Schema Information
#
# Table name: blogs
#
#  id             :bigint           not null, primary key
#  active         :boolean          default(TRUE), not null
#  description    :text
#  imported_at    :datetime
#  last_synced_at :datetime
#  name           :string           not null
#  rss_url        :string           not null
#  tags           :text             default([]), is an Array
#  twitter        :string
#  url            :string           not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
# Indexes
#
#  index_blogs_on_active   (active)
#  index_blogs_on_rss_url  (rss_url) UNIQUE
#  index_blogs_on_url      (url) UNIQUE
#
class Blog < ApplicationRecord
  include RssParseable

  REGISTRY_URL = "https://raw.githubusercontent.com/k0va1/rubycrow/master/data/blogs.yml"

  has_many :articles, dependent: :destroy

  validates :name, presence: true
  validates :url, presence: true, uniqueness: true
  validates :rss_url, presence: true, uniqueness: true

  scope :active, -> { where(active: true) }

  def new?
    imported_at.present? && imported_at >= 1.week.ago
  end

  def self.sync_from_registry!
    response = Faraday.get(REGISTRY_URL)
    entries = YAML.safe_load(response.body, permitted_classes: [Symbol])
    registry_urls = []

    entries.each do |entry|
      blog = find_or_initialize_by(url: entry["url"])
      blog.imported_at = Time.current if blog.new_record?
      blog.assign_attributes(
        name: entry["name"],
        rss_url: entry["rss_url"],
        description: entry["description"],
        tags: entry["tags"] || [],
        active: true
      )
      blog.save!
      registry_urls << entry["url"]
    end

    where.not(url: registry_urls).update_all(active: false)
  end
end
