# == Schema Information
#
# Table name: clicks
#
#  id              :bigint           not null, primary key
#  clicked_at      :datetime         not null
#  device_type     :string
#  ip_hash         :string
#  unique_click    :boolean          default(FALSE)
#  user_agent      :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  subscriber_id   :bigint
#  tracked_link_id :bigint           not null
#
# Indexes
#
#  index_clicks_on_clicked_at                   (clicked_at)
#  index_clicks_on_subscriber_id                (subscriber_id)
#  index_clicks_on_tracked_link_id              (tracked_link_id)
#  index_clicks_on_tracked_link_id_and_ip_hash  (tracked_link_id,ip_hash)
#
# Foreign Keys
#
#  fk_rails_...  (subscriber_id => subscribers.id)
#  fk_rails_...  (tracked_link_id => tracked_links.id)
#
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
