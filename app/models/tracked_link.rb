# == Schema Information
#
# Table name: tracked_links
#
#  id                     :bigint           not null, primary key
#  destination_url        :string           not null
#  position_in_newsletter :integer
#  section                :string
#  token                  :string           not null
#  total_clicks           :integer          default(0)
#  unique_clicks          :integer          default(0)
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  article_id             :bigint
#  newsletter_issue_id    :bigint           not null
#
# Indexes
#
#  index_tracked_links_on_article_id           (article_id)
#  index_tracked_links_on_issue_and_url        (newsletter_issue_id,destination_url)
#  index_tracked_links_on_newsletter_issue_id  (newsletter_issue_id)
#  index_tracked_links_on_token                (token) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (article_id => articles.id)
#  fk_rails_...  (newsletter_issue_id => newsletter_issues.id)
#
class TrackedLink < ApplicationRecord
  SECTIONS = %w[crows_pick shiny_objects crow_call quick_gems].freeze

  belongs_to :newsletter_issue
  belongs_to :article, optional: true
  has_many :clicks, dependent: :destroy

  before_validation :generate_token, on: :create

  validates :token, presence: true, uniqueness: true
  validates :destination_url, presence: true
  validates :section, inclusion: {in: SECTIONS, allow_blank: true}

  def tracked_url(subscriber: nil)
    params = {sid: subscriber&.id}.compact
    Rails.application.routes.url_helpers.tracked_redirect_url(token, **params)
  end

  private

  def generate_token
    self.token ||= SecureRandom.urlsafe_base64(10)
  end
end
