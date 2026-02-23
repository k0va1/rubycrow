module ApplicationHelper
  def safe_external_url(url)
    return "#" if url.blank?
    uri = URI.parse(url)
    %w[http https].include?(uri.scheme) ? url : "#"
  rescue URI::InvalidURIError
    "#"
  end

  def article_blog_for(item)
    item.linkable&.blog if item.linkable_type == "Article"
  end
end
