class NewsletterMailer < ApplicationMailer
  def issue(newsletter_issue:, subscriber:)
    @newsletter_issue = newsletter_issue
    @subscriber = subscriber
    @sections = newsletter_issue.newsletter_sections.includes(newsletter_items: [:tracked_link, {article: :blog}])
    @first_flight_blog_ids = first_flight_blog_ids(newsletter_issue)

    attachments.inline["rubycrow.png"] = {
      mime_type: "image/png",
      content: Rails.root.join("app/assets/images/rubycrow-email.png").read
    }

    mail(
      to: subscriber.email,
      subject: newsletter_issue.subject
    )
  end

  private

  def first_flight_blog_ids(newsletter_issue)
    current_blog_ids = newsletter_issue.newsletter_items
      .joins(:article)
      .pluck("articles.blog_id")
      .uniq

    return Set.new if current_blog_ids.empty?

    previously_seen_blog_ids = NewsletterItem
      .joins(newsletter_section: :newsletter_issue)
      .joins(:article)
      .where(newsletter_issues: {sent_at: ...newsletter_issue.created_at})
      .where.not(newsletter_sections: {newsletter_issue_id: newsletter_issue.id})
      .where(articles: {blog_id: current_blog_ids})
      .pluck("articles.blog_id")
      .to_set

    (current_blog_ids.to_set - previously_seen_blog_ids)
  end
end
