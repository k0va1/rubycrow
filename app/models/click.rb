class Click < ApplicationRecord
  MOBILE_REGEX = /mobile|android|iphone|ipod|opera mini|iemobile/i
  TABLET_REGEX = /tablet|ipad|kindle|silk/i

  belongs_to :tracked_link
  belongs_to :subscriber, optional: true

  before_validation :detect_device_type

  validates :clicked_at, presence: true

  private

  def detect_device_type
    return if user_agent.blank?

    self.device_type = if user_agent.match?(TABLET_REGEX)
      "tablet"
    elsif user_agent.match?(MOBILE_REGEX)
      "mobile"
    else
      "desktop"
    end
  end
end
