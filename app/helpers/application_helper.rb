module ApplicationHelper
  def safe_external_url(url)
    return "#" if url.blank?
    uri = URI.parse(url)
    %w[http https].include?(uri.scheme) ? url : "#"
  rescue URI::InvalidURIError
    "#"
  end
end
