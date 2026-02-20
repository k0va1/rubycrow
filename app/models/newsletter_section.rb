# == Schema Information
#
# Table name: newsletter_sections
#
#  id                  :bigint           not null, primary key
#  position            :integer          default(0), not null
#  title               :string           not null
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  newsletter_issue_id :bigint           not null
#
# Indexes
#
#  index_newsletter_sections_on_newsletter_issue_id               (newsletter_issue_id)
#  index_newsletter_sections_on_newsletter_issue_id_and_position  (newsletter_issue_id,position)
#
# Foreign Keys
#
#  fk_rails_...  (newsletter_issue_id => newsletter_issues.id)
#
class NewsletterSection < ApplicationRecord
  DEFAULT_SECTIONS = %w[crows_pick shiny_objects crow_call quick_gems].freeze

  belongs_to :newsletter_issue
  has_many :newsletter_items, -> { order(:position) }, dependent: :destroy
  has_many :tracked_links, through: :newsletter_items

  accepts_nested_attributes_for :newsletter_items, allow_destroy: true, reject_if: :all_blank

  validates :title, presence: true

  default_scope { order(:position) }
end
