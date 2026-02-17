class NewsletterMailer < ApplicationMailer
  def issue(newsletter_issue:, subscriber:)
    @newsletter_issue = newsletter_issue
    @subscriber = subscriber
    @tracked_links = newsletter_issue.tracked_links.includes(:article)

    mail(
      to: subscriber.email,
      subject: newsletter_issue.subject
    )
  end
end
