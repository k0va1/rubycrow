require "test_helper"

class BlogTest < ActiveSupport::TestCase
  test "valid blog" do
    blog = Blog.new(name: "Test Blog", url: "https://test.example.com", rss_url: "https://test.example.com/feed.xml")
    assert blog.valid?
  end

  test "requires name" do
    blog = Blog.new(url: "https://test.example.com", rss_url: "https://test.example.com/feed.xml")
    assert_not blog.valid?
    assert_includes blog.errors[:name], "can't be blank"
  end

  test "requires url" do
    blog = Blog.new(name: "Test", rss_url: "https://test.example.com/feed.xml")
    assert_not blog.valid?
    assert_includes blog.errors[:url], "can't be blank"
  end

  test "requires rss_url" do
    blog = Blog.new(name: "Test", url: "https://test.example.com")
    assert_not blog.valid?
    assert_includes blog.errors[:rss_url], "can't be blank"
  end

  test "url must be unique" do
    blog = Blog.new(name: "Dupe", url: blogs(:speedshop).url, rss_url: "https://unique.example.com/feed.xml")
    assert_not blog.valid?
    assert_includes blog.errors[:url], "has already been taken"
  end

  test "rss_url must be unique" do
    blog = Blog.new(name: "Dupe", url: "https://unique.example.com", rss_url: blogs(:speedshop).rss_url)
    assert_not blog.valid?
    assert_includes blog.errors[:rss_url], "has already been taken"
  end

  test "active scope returns only active blogs" do
    active = Blog.active
    assert_includes active, blogs(:speedshop)
    assert_includes active, blogs(:evil_martians)
    assert_not_includes active, blogs(:inactive_blog)
  end

  test "has many articles" do
    assert_respond_to blogs(:speedshop), :articles
    assert_includes blogs(:speedshop).articles, articles(:rails_performance)
  end

  test "destroying blog destroys articles" do
    blog = blogs(:speedshop)
    article_ids = blog.article_ids

    assert_difference "Article.count", -article_ids.size do
      blog.destroy!
    end
  end

  test "sync_from_registry! creates blogs from YAML" do
    registry_yaml = <<~YAML
      - name: "New Blog"
        url: "https://newblog.example.com"
        rss_url: "https://newblog.example.com/feed.xml"
        description: "A new blog"
        tags:
          - ruby
        twitter: "newblog"
    YAML

    stub_request(:get, Blog::REGISTRY_URL).to_return(body: registry_yaml)

    Click.delete_all
    TrackedLink.delete_all
    Article.delete_all
    Blog.delete_all

    assert_difference "Blog.count", 1 do
      Blog.sync_from_registry!
    end

    blog = Blog.last
    assert_equal "New Blog", blog.name
    assert_equal "https://newblog.example.com", blog.url
    assert_equal ["ruby"], blog.tags
    assert blog.active?
  end

  test "sync_from_registry! deactivates blogs not in registry" do
    registry_yaml = <<~YAML
      - name: "Nate Berkopec"
        url: "https://www.speedshop.co"
        rss_url: "https://www.speedshop.co/feed.xml"
        description: "Ruby perf"
    YAML

    stub_request(:get, Blog::REGISTRY_URL).to_return(body: registry_yaml)

    Blog.sync_from_registry!

    assert blogs(:speedshop).reload.active?
    assert_not blogs(:evil_martians).reload.active?
  end

  test "sync_feed! creates articles from RSS" do
    blog = blogs(:evil_martians)

    rss_xml = <<~XML
      <?xml version="1.0" encoding="UTF-8"?>
      <rss version="2.0">
        <channel>
          <title>Evil Martians</title>
          <item>
            <title>New Post</title>
            <link>https://evilmartians.com/chronicles/new-post</link>
            <pubDate>#{1.hour.ago.rfc2822}</pubDate>
            <description>A new post about Ruby</description>
          </item>
        </channel>
      </rss>
    XML

    stub_request(:get, blog.rss_url).to_return(body: rss_xml)

    assert_difference "blog.articles.count", 1 do
      blog.sync_feed!
    end

    article = blog.articles.find_by(url: "https://evilmartians.com/chronicles/new-post")
    assert_equal "New Post", article.title
    assert_not_nil article.published_at
    assert_not_nil blog.reload.last_synced_at
  end

  test "sync_feed! excludes entries with blank titles" do
    blog = blogs(:evil_martians)

    rss_xml = <<~XML
      <?xml version="1.0" encoding="UTF-8"?>
      <rss version="2.0">
        <channel>
          <title>Evil Martians</title>
          <item>
            <title>  </title>
            <link>https://evilmartians.com/chronicles/no-title</link>
            <pubDate>#{1.hour.ago.rfc2822}</pubDate>
          </item>
        </channel>
      </rss>
    XML

    stub_request(:get, blog.rss_url).to_return(body: rss_xml)

    assert_no_difference "blog.articles.count" do
      blog.sync_feed!
    end
  end

  test "sync_feed! excludes legal pages by URL" do
    blog = blogs(:evil_martians)

    rss_xml = <<~XML
      <?xml version="1.0" encoding="UTF-8"?>
      <rss version="2.0">
        <channel>
          <title>Test</title>
          <item>
            <title>Our Terms</title>
            <link>https://example.com/terms/</link>
            <pubDate>#{1.hour.ago.rfc2822}</pubDate>
          </item>
          <item>
            <title>Our Privacy</title>
            <link>https://example.com/privacypolicy</link>
            <pubDate>#{1.hour.ago.rfc2822}</pubDate>
          </item>
          <item>
            <title>Real Article</title>
            <link>https://example.com/blog/real-article</link>
            <pubDate>#{1.hour.ago.rfc2822}</pubDate>
          </item>
        </channel>
      </rss>
    XML

    stub_request(:get, blog.rss_url).to_return(body: rss_xml)

    assert_difference "blog.articles.count", 1 do
      blog.sync_feed!
    end

    assert_nil blog.articles.find_by(url: "https://example.com/terms")
    assert_nil blog.articles.find_by(url: "https://example.com/privacypolicy")
    assert_not_nil blog.articles.find_by(url: "https://example.com/blog/real-article")
  end

  test "sync_feed! excludes entries with legal titles" do
    blog = blogs(:evil_martians)

    rss_xml = <<~XML
      <?xml version="1.0" encoding="UTF-8"?>
      <rss version="2.0">
        <channel>
          <title>Test</title>
          <item>
            <title>Terms and Conditions</title>
            <link>https://example.com/some-page</link>
            <pubDate>#{1.hour.ago.rfc2822}</pubDate>
          </item>
          <item>
            <title>Privacy Policy</title>
            <link>https://example.com/another-page</link>
            <pubDate>#{1.hour.ago.rfc2822}</pubDate>
          </item>
        </channel>
      </rss>
    XML

    stub_request(:get, blog.rss_url).to_return(body: rss_xml)

    assert_no_difference "blog.articles.count" do
      blog.sync_feed!
    end
  end

  test "sync_feed! handles network errors gracefully" do
    blog = blogs(:speedshop)
    stub_request(:get, blog.rss_url).to_raise(Faraday::ConnectionFailed)

    assert_nothing_raised do
      blog.sync_feed!
    end
  end

  test "sync_feed! extracts categories as tags" do
    blog = blogs(:evil_martians)

    rss_xml = <<~XML
      <?xml version="1.0" encoding="UTF-8"?>
      <rss version="2.0">
        <channel>
          <title>Evil Martians</title>
          <item>
            <title>Karafka Post</title>
            <link>https://evilmartians.com/chronicles/karafka-post</link>
            <pubDate>#{1.hour.ago.rfc2822}</pubDate>
            <description>About Karafka</description>
            <category><![CDATA[Karafka]]></category>
            <category><![CDATA[Ruby]]></category>
            <category><![CDATA[Software]]></category>
            <category><![CDATA[apache kafka]]></category>
            <category><![CDATA[karafka]]></category>
            <category><![CDATA[Performance]]></category>
            <category><![CDATA[waterdrop]]></category>
          </item>
        </channel>
      </rss>
    XML

    stub_request(:get, blog.rss_url).to_return(body: rss_xml)
    blog.sync_feed!

    article = blog.articles.find_by(url: "https://evilmartians.com/chronicles/karafka-post")
    assert_equal %w[karafka ruby software apache\ kafka performance waterdrop], article.tags
  end

  test "sync_feed! deduplicates by normalized URL" do
    blog = blogs(:evil_martians)

    rss_xml = <<~XML
      <?xml version="1.0" encoding="UTF-8"?>
      <rss version="2.0">
        <channel>
          <title>Evil Martians</title>
          <item>
            <title>Same Post</title>
            <link>https://evilmartians.com/chronicles/same-post#comments</link>
            <pubDate>#{1.hour.ago.rfc2822}</pubDate>
          </item>
        </channel>
      </rss>
    XML

    stub_request(:get, blog.rss_url).to_return(body: rss_xml)

    blog.sync_feed!
    initial_count = blog.articles.count

    blog.sync_feed!
    assert_equal initial_count, blog.articles.count
  end
end
