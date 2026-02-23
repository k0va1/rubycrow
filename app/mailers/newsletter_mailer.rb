class NewsletterMailer < ApplicationMailer
  helper ApplicationHelper

  def issue(newsletter_issue:, subscriber:)
    @newsletter_issue = newsletter_issue
    @subscriber = subscriber
    @sections = newsletter_issue.newsletter_sections
      .order(:position)
      .includes(newsletter_items: [:tracked_link, :linkable])
    preload_article_blogs(@sections)
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

  def preload_article_blogs(sections)
    article_linkables = sections.flat_map(&:newsletter_items)
      .select { |item| item.linkable_type == "Article" }
      .filter_map(&:linkable)

    if article_linkables.any?
      ActiveRecord::Associations::Preloader.new(
        records: article_linkables,
        associations: :blog
      ).call
    end
  end

  def first_flight_blog_ids(newsletter_issue)
    article_ids = newsletter_issue.newsletter_items
      .where(linkable_type: "Article")
      .pluck(:linkable_id)

    current_blog_ids = Article.where(id: article_ids).pluck(:blog_id).uniq

    return Set.new if current_blog_ids.empty?

    previously_seen_article_ids = NewsletterItem
      .joins(newsletter_section: :newsletter_issue)
      .where(linkable_type: "Article")
      .where(newsletter_issues: {sent_at: ...newsletter_issue.created_at})
      .where.not(newsletter_sections: {newsletter_issue_id: newsletter_issue.id})
      .pluck(:linkable_id)

    previously_seen_blog_ids = Article
      .where(id: previously_seen_article_ids, blog_id: current_blog_ids)
      .pluck(:blog_id)
      .to_set

    (current_blog_ids.to_set - previously_seen_blog_ids)
  end
end
