module RssParseable
  extend ActiveSupport::Concern

  FEED_TIMEOUT = 15
  CONTENT_MAX_LENGTH = 500

  def sync_feed
    response = Faraday.get(rss_url) { |req| req.options.timeout = FEED_TIMEOUT }
    feed = Feedjira.parse(response.body)

    feed.entries.each do |entry|
      article = articles.find_or_initialize_by(url: normalize_url(entry.url))
      article.assign_attributes(
        title: entry.title&.strip,
        published_at: entry.published,
        summary: sanitize_text(entry.summary),
        content_snippet: sanitize_text(entry.content)
      )
      article.save if article.new_record? || article.changed?
    end

    update!(last_synced_at: Time.current)
  rescue Faraday::Error, Feedjira::NoParserAvailable => e
    Rails.logger.error("Failed to sync feed for #{name} (#{rss_url}): #{e.message}")
  end

  private

  def normalize_url(url)
    uri = URI.parse(url.to_s.strip)
    uri.fragment = nil
    uri.query = nil if uri.query&.match?(/utm_/)
    uri.to_s
  rescue URI::InvalidURIError
    url.to_s.strip
  end

  def sanitize_text(text)
    return nil if text.blank?

    stripped = ActionController::Base.helpers.strip_tags(text).squish
    stripped.truncate(CONTENT_MAX_LENGTH)
  end
end
