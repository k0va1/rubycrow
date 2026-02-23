module HttpFetchable
  extend ActiveSupport::Concern

  class_methods do
    private

    def http_client(headers: {})
      Faraday.new(ssl: {min_version: OpenSSL::SSL::TLS1_2_VERSION}) do |f|
        f.headers["User-Agent"] = "RubyCrow/1.0 (+https://rubycrow.com)"
        headers.each { |key, value| f.headers[key] = value }
        f.response :follow_redirects
        f.adapter Faraday.default_adapter
      end
    end
  end
end
