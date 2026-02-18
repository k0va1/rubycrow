module RssParseable
  extend ActiveSupport::Concern

  FEED_TIMEOUT = 15
  CONTENT_MAX_LENGTH = 500

  def fetch_feed
    response = http_client.get(rss_url) { |req| req.options.timeout = FEED_TIMEOUT }
    feed = Feedjira.parse(response.body)

    records = feed.entries.each_with_object({}) do |entry, hash|
      url = normalize_url(entry.url)
      hash[url] = {
        blog_id: id,
        url: url,
        title: entry.title&.strip,
        published_at: entry.published,
        summary: sanitize_text(entry.summary),
        content_snippet: sanitize_text(entry.content)
      }
    end.values

    [self, records, feed.entries.size]
  rescue Faraday::Error, Feedjira::NoParserAvailable, OpenSSL::SSL::SSLError, Net::OpenTimeout => e
    Rails.logger.error("Failed to sync feed for #{name} (#{rss_url}): #{e.message}")
    nil
  end

  def sync_feed!
    result = fetch_feed
    return unless result

    _, records, entry_count = result
    persist_feed(records, entry_count)
  end

  def persist_feed(records, entry_count)
    Article.upsert_all(
      records,
      unique_by: :index_articles_on_blog_id_and_url,
      update_only: %i[title published_at summary content_snippet]
    ) if records.any?

    update(last_synced_at: Time.current)
    Rails.logger.info("Successfully synced feed for #{name} (#{rss_url}) with #{entry_count} entries")
  rescue => e
    Rails.logger.error("Failed to persist feed for #{name} (#{rss_url}): #{e.message}")
  end

  private

  def http_client
    @http_client ||= Faraday.new(ssl: {min_version: OpenSSL::SSL::TLS1_2_VERSION}) do |f|
      f.headers["User-Agent"] = "RubyCrow/1.0 (+https://rubycrow.com)"
      f.response :follow_redirects
      f.adapter Faraday.default_adapter
    end
  end

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
