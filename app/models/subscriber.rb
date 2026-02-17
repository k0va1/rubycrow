# == Schema Information
#
# Table name: subscribers
#
#  id              :bigint           not null, primary key
#  confirmed       :boolean          default(FALSE)
#  email           :string           not null
#  subscribed_at   :datetime
#  unsubscribed_at :datetime
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_subscribers_on_email  (email) UNIQUE
#
class Subscriber < ApplicationRecord
  has_many :clicks

  validates :email, presence: true,
    uniqueness: {case_sensitive: false, message: "is already subscribed"},
    format: {with: URI::MailTo::EMAIL_REGEXP, message: "doesn't look valid"}

  scope :active, -> { where(confirmed: true, unsubscribed_at: nil) }

  before_create { self.subscribed_at = Time.current }

  def signed_unsubscribe_id
    signed_id(purpose: :unsubscribe)
  end
end
