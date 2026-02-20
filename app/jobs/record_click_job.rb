class RecordClickJob < ApplicationJob
  queue_as :default

  def perform(tracked_link_id:, clicked_at:, subscriber_id: nil, user_agent: nil, ip_address: nil)
    tracked_link = TrackedLink.find_by(id: tracked_link_id)
    return unless tracked_link

    ip_hash = hash_ip(ip_address)
    is_unique = !Click.exists?(tracked_link_id: tracked_link_id, ip_hash: ip_hash)

    Click.create!(
      tracked_link: tracked_link,
      subscriber_id: subscriber_id,
      user_agent: user_agent,
      ip_hash: ip_hash,
      clicked_at: Time.zone.parse(clicked_at),
      unique_click: is_unique
    )

    TrackedLink.update_counters(tracked_link_id, total_clicks: 1)

    newsletter_issue = tracked_link.newsletter_issue
    if newsletter_issue
      NewsletterIssue.update_counters(newsletter_issue.id, total_clicks: 1)
    end

    if is_unique
      TrackedLink.update_counters(tracked_link_id, unique_clicks: 1)
      if newsletter_issue
        NewsletterIssue.update_counters(newsletter_issue.id, total_unique_clicks: 1)
      end
    end
  end

  private

  def hash_ip(ip_address)
    return nil if ip_address.blank?
    salt = Rails.application.secret_key_base[0..15]
    Digest::SHA256.hexdigest("#{ip_address}#{salt}")[0..15]
  end
end
