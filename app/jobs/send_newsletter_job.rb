class SendNewsletterJob < ApplicationJob
  queue_as :default

  def perform(newsletter_issue_id:)
    newsletter_issue = NewsletterIssue.find(newsletter_issue_id)
    subscribers = Subscriber.active

    newsletter_issue.update!(
      subscriber_count: subscribers.count,
      sent_at: Time.current
    )

    subscribers.find_each do |subscriber|
      NewsletterMailer.issue(
        newsletter_issue: newsletter_issue,
        subscriber: subscriber
      ).deliver_later
    end
  end
end
