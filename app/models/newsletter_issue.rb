# == Schema Information
#
# Table name: newsletter_issues
#
#  id                  :bigint           not null, primary key
#  issue_number        :integer          not null
#  sent_at             :datetime
#  subject             :string           not null
#  subscriber_count    :integer          default(0)
#  total_clicks        :integer          default(0)
#  total_unique_clicks :integer          default(0)
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#
# Indexes
#
#  index_newsletter_issues_on_issue_number  (issue_number) UNIQUE
#  index_newsletter_issues_on_sent_at       (sent_at)
#
class NewsletterIssue < ApplicationRecord
  has_many :newsletter_sections, -> { order(:position) }, dependent: :destroy
  has_many :newsletter_items, through: :newsletter_sections
  has_many :tracked_links, through: :newsletter_items
  has_many :clicks, through: :tracked_links

  accepts_nested_attributes_for :newsletter_sections, allow_destroy: true, reject_if: :all_blank

  validates :issue_number, presence: true, uniqueness: true
  validates :subject, presence: true

  scope :sent, -> { where.not(sent_at: nil) }
  scope :recent, ->(limit = 10) { sent.order(sent_at: :desc).limit(limit) }

  def click_through_rate
    return 0 if subscriber_count.zero?
    (total_unique_clicks.to_f / subscriber_count * 100).round(2)
  end

  def create_tracked_links!
    newsletter_sections.includes(:newsletter_items).find_each do |section|
      section.newsletter_items.each do |item|
        next if item.tracked_link.present?

        url = TrackedLink.append_utm_params(item.url)
        item.create_tracked_link!(destination_url: url)
      end
    end
  end
end
