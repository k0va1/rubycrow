class Subscriber < ApplicationRecord
  validates :email, presence: true,
    uniqueness: { case_sensitive: false, message: "is already subscribed" },
    format: { with: URI::MailTo::EMAIL_REGEXP, message: "doesn't look valid" }

  before_create { self.subscribed_at = Time.current }
end
