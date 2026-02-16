require "test_helper"

class ParseRssFeedsJobTest < ActiveSupport::TestCase
  test "syncs all active blog feeds" do
    rss_xml = <<~XML
      <?xml version="1.0" encoding="UTF-8"?>
      <rss version="2.0">
        <channel><title>Test</title></channel>
      </rss>
    XML

    Blog.active.each do |blog|
      stub_request(:get, blog.rss_url).to_return(body: rss_xml)
    end

    assert_nothing_raised do
      ParseRssFeedsJob.perform_now
    end

    Blog.active.each do |blog|
      assert_requested(:get, blog.rss_url)
    end
  end

  test "continues when a blog feed fails" do
    first_blog = Blog.active.order(:id).first
    other_blogs = Blog.active.order(:id).offset(1)

    stub_request(:get, first_blog.rss_url).to_raise(Faraday::ConnectionFailed)

    rss_xml = <<~XML
      <?xml version="1.0" encoding="UTF-8"?>
      <rss version="2.0">
        <channel><title>Test</title></channel>
      </rss>
    XML

    other_blogs.each do |blog|
      stub_request(:get, blog.rss_url).to_return(body: rss_xml)
    end

    assert_nothing_raised do
      ParseRssFeedsJob.perform_now
    end

    other_blogs.each do |blog|
      assert_requested(:get, blog.rss_url)
    end
  end
end
