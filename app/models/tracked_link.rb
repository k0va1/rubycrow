# == Schema Information
#
# Table name: tracked_links
#
#  id              :bigint           not null, primary key
#  destination_url :string           not null
#  token           :string           not null
#  total_clicks    :integer          default(0)
#  trackable_type  :string
#  unique_clicks   :integer          default(0)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  trackable_id    :bigint
#
# Indexes
#
#  index_tracked_links_on_token                            (token) UNIQUE
#  index_tracked_links_on_trackable_type_and_trackable_id  (trackable_type,trackable_id)
#
class TrackedLink < ApplicationRecord
  belongs_to :trackable, polymorphic: true, optional: true
  has_many :clicks, dependent: :destroy

  before_validation :generate_token, on: :create

  validates :token, presence: true, uniqueness: true
  validates :destination_url, presence: true

  def newsletter_issue
    case trackable
    when NewsletterItem
      trackable.newsletter_section&.newsletter_issue
    end
  end

  def tracked_url(subscriber: nil)
    params = {sid: subscriber&.id}.compact
    Rails.application.routes.url_helpers.tracked_redirect_url(token, **params)
  end

  def self.append_utm_params(url)
    uri = URI.parse(url)
    params = URI.decode_www_form(uri.query || "")
    params << ["utm_source", "rubycrow"]
    uri.query = URI.encode_www_form(params)
    uri.to_s
  end

  private

  def generate_token
    self.token ||= SecureRandom.urlsafe_base64(10)
  end
end
