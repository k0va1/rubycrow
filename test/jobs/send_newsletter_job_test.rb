require "test_helper"

class SendNewsletterJobTest < ActiveSupport::TestCase
  setup do
    @issue = newsletter_issues(:issue_two)
  end

  test "enqueues mailer for each active subscriber" do
    active_count = Subscriber.active.count

    assert_enqueued_jobs active_count do
      SendNewsletterJob.perform_now(newsletter_issue_id: @issue.id)
    end
  end

  test "updates subscriber_count on issue" do
    SendNewsletterJob.perform_now(newsletter_issue_id: @issue.id)
    @issue.reload

    assert_equal Subscriber.active.count, @issue.subscriber_count
  end

  test "sets sent_at on issue" do
    assert_nil @issue.sent_at
    SendNewsletterJob.perform_now(newsletter_issue_id: @issue.id)
    @issue.reload

    assert_not_nil @issue.sent_at
  end

  test "only sends to active subscribers" do
    active_subscribers = Subscriber.active
    all_subscribers = Subscriber.all

    assert active_subscribers.count < all_subscribers.count

    assert_enqueued_jobs active_subscribers.count do
      SendNewsletterJob.perform_now(newsletter_issue_id: @issue.id)
    end
  end
end
