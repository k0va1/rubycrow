require "test_helper"

class SubscriberMailerTest < ActiveSupport::TestCase
  test "confirmation email has correct subject and recipient" do
    subscriber = subscribers(:inactive)
    email = SubscriberMailer.confirmation(subscriber: subscriber)

    assert_equal ["newsletter@rubycrow.dev"], email.from
    assert_equal [subscriber.email], email.to
    assert_equal "Confirm your RubyCrow subscription", email.subject
  end

  test "confirmation email body contains confirmation link" do
    subscriber = subscribers(:inactive)
    email = SubscriberMailer.confirmation(subscriber: subscriber)

    assert_match "confirm/", email.html_part.body.to_s
    assert_match "confirm/", email.text_part.body.to_s
  end

  test "confirmation email body contains welcome message" do
    subscriber = subscribers(:inactive)
    email = SubscriberMailer.confirmation(subscriber: subscriber)

    assert_match "Welcome to the flock", email.html_part.body.to_s
    assert_match "Welcome to the flock", email.text_part.body.to_s
  end
end
