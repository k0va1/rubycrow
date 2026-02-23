module NewsletterSource
  extend ActiveSupport::Concern

  included do
    has_many :newsletter_items, as: :linkable, dependent: :nullify

    scope :unprocessed, -> { where(processed: false) }
    scope :featured, -> { where.not(featured_in_issue: nil) }
    scope :recent, ->(limit = 15) { limit(limit) }
  end
end
