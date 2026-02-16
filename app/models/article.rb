class Article < ApplicationRecord
  belongs_to :blog

  validates :title, presence: true
  validates :url, presence: true, uniqueness: true

  scope :published, -> { order(published_at: :desc) }
  scope :recent, ->(limit = 15) { published.limit(limit) }
  scope :unprocessed, -> { where(processed: false) }
  scope :featured, -> { where.not(featured_in_issue: nil) }
end
