class SubscriberMailer < ApplicationMailer
  self.deliver_later_queue_name = :critical
  layout false

  def confirmation(subscriber:)
    @subscriber = subscriber
    mail(to: @subscriber.email, subject: "Confirm your RubyCrow subscription")
  end
end
