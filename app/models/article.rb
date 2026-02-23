# == Schema Information
#
# Table name: articles
#
#  id                :bigint           not null, primary key
#  featured_in_issue :integer
#  processed         :boolean          default(FALSE)
#  published_at      :datetime
#  summary           :text
#  tags              :text             default([]), is an Array
#  title             :string           not null
#  url               :string           not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  blog_id           :bigint           not null
#
# Indexes
#
#  index_articles_on_blog_id                   (blog_id)
#  index_articles_on_blog_id_and_published_at  (blog_id,published_at)
#  index_articles_on_blog_id_and_url           (blog_id,url) UNIQUE
#  index_articles_on_featured_in_issue         (featured_in_issue)
#  index_articles_on_processed                 (processed)
#  index_articles_on_published_at              (published_at)
#  index_articles_on_url                       (url) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (blog_id => blogs.id)
#
class Article < ApplicationRecord
  include NewsletterSource

  self.ignored_columns += ["content_snippet"]
  belongs_to :blog

  validates :title, presence: true
  validates :url, presence: true, uniqueness: true

  scope :by_publish_date, -> { order(Arel.sql("published_at DESC NULLS LAST")) }
  scope :search_by_title, ->(query) { where("title ILIKE ?", "%#{sanitize_sql_like(query)}%") }
end
