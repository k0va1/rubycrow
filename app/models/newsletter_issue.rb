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
  has_many :tracked_links, dependent: :destroy
  has_many :clicks, through: :tracked_links

  validates :issue_number, presence: true, uniqueness: true
  validates :subject, presence: true

  scope :sent, -> { where.not(sent_at: nil) }
  scope :recent, ->(limit = 10) { sent.order(sent_at: :desc).limit(limit) }

  def click_through_rate
    return 0 if subscriber_count.zero?
    (total_unique_clicks.to_f / subscriber_count * 100).round(2)
  end

  def create_tracked_links!
    articles = Article.where(featured_in_issue: issue_number)
    articles.each_with_index do |article, index|
      section = determine_section(article)
      url = append_utm_params(article.url)

      tracked_links.find_or_create_by!(article: article) do |link|
        link.destination_url = url
        link.position_in_newsletter = index + 1
        link.section = section
      end
    end
  end

  private

  def append_utm_params(url)
    uri = URI.parse(url)
    params = URI.decode_www_form(uri.query || "")
    params << ["utm_source", "rubycrow"]
    params << ["utm_medium", "email"]
    params << ["utm_campaign", "issue_#{issue_number}"]
    uri.query = URI.encode_www_form(params)
    uri.to_s
  end

  def determine_section(article)
    "shiny_objects"
  end
end
