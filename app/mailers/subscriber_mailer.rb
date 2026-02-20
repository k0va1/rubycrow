class SubscriberMailer < ApplicationMailer
  layout false

  def confirmation(subscriber:)
    @subscriber = subscriber
    mail(to: @subscriber.email, subject: "Confirm your RubyCrow subscription")
  end
end
