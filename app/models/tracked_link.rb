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
