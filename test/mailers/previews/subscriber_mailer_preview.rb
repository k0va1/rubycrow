class SubscriberMailerPreview < ActionMailer::Preview
  def confirmation
    subscriber = Subscriber.first || Subscriber.find_or_create_by!(email: "preview@example.com")
    SubscriberMailer.confirmation(subscriber: subscriber)
  end
end
