class NewsletterMailer < ApplicationMailer
  def issue(newsletter_issue:, subscriber:)
    @newsletter_issue = newsletter_issue
    @subscriber = subscriber
    @tracked_links = newsletter_issue.tracked_links.includes(:article)

    attachments.inline["rubycrow.png"] = {
      mime_type: "image/png",
      content: Rails.root.join("app/assets/images/rubycrow-email.png").read
    }

    mail(
      to: subscriber.email,
      subject: newsletter_issue.subject
    )
  end
end
