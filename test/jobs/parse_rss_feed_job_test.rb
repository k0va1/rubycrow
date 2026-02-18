require "test_helper"

class ParseRssFeedJobTest < ActiveSupport::TestCase
  test "syncs a single blog feed" do
    blog = blogs(:speedshop)

    rss_xml = <<~XML
      <?xml version="1.0" encoding="UTF-8"?>
      <rss version="2.0">
        <channel><title>Test</title></channel>
      </rss>
    XML

    stub_request(:get, blog.rss_url).to_return(body: rss_xml)

    ParseRssFeedJob.perform_now(blog.id)

    assert_requested(:get, blog.rss_url)
  end

  test "handles feed failure gracefully" do
    blog = blogs(:speedshop)

    stub_request(:get, blog.rss_url).to_raise(Faraday::ConnectionFailed)

    assert_nothing_raised do
      ParseRssFeedJob.perform_now(blog.id)
    end
  end
end
