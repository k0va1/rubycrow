require "test_helper"

class RedditPostTest < ActiveSupport::TestCase
  test "valid reddit post" do
    post = RedditPost.new(reddit_id: "xyz999", title: "Test post", url: "https://reddit.com/r/ruby/comments/xyz999/test/", subreddit: "ruby")
    assert post.valid?
  end

  test "requires reddit_id" do
    post = RedditPost.new(title: "Test", url: "https://reddit.com/test", subreddit: "ruby")
    assert_not post.valid?
    assert_includes post.errors[:reddit_id], "can't be blank"
  end

  test "reddit_id must be unique" do
    post = RedditPost.new(reddit_id: reddit_posts(:ruby_post).reddit_id, title: "Dup", url: "https://reddit.com/dup", subreddit: "ruby")
    assert_not post.valid?
    assert_includes post.errors[:reddit_id], "has already been taken"
  end

  test "requires title" do
    post = RedditPost.new(reddit_id: "xyz999", url: "https://reddit.com/test", subreddit: "ruby")
    assert_not post.valid?
    assert_includes post.errors[:title], "can't be blank"
  end

  test "requires url" do
    post = RedditPost.new(reddit_id: "xyz999", title: "Test", subreddit: "ruby")
    assert_not post.valid?
    assert_includes post.errors[:url], "can't be blank"
  end

  test "requires valid subreddit" do
    post = RedditPost.new(reddit_id: "xyz999", title: "Test", url: "https://reddit.com/test", subreddit: "invalid")
    assert_not post.valid?
    assert_includes post.errors[:subreddit], "is not included in the list"
  end

  test "subreddit accepts ruby" do
    post = RedditPost.new(reddit_id: "xyz999", title: "Test", url: "https://reddit.com/test", subreddit: "ruby")
    assert post.valid?
  end

  test "subreddit accepts rails" do
    post = RedditPost.new(reddit_id: "xyz999", title: "Test", url: "https://reddit.com/test", subreddit: "rails")
    assert post.valid?
  end

  test "by_post_date scope orders by posted_at desc" do
    posts = RedditPost.by_post_date
    dates = posts.map(&:posted_at).compact
    assert dates.any?
    assert_equal dates, dates.sort.reverse
  end

  test "recent scope limits results" do
    assert_equal 2, RedditPost.recent(2).count
  end

  test "unprocessed scope returns unprocessed posts" do
    unprocessed = RedditPost.unprocessed
    assert unprocessed.any?
    unprocessed.each do |post|
      assert_not post.processed?
    end
  end

  test "from_subreddit scope filters by subreddit" do
    ruby_posts = RedditPost.from_subreddit("ruby")
    assert ruby_posts.any?
    ruby_posts.each do |post|
      assert_equal "ruby", post.subreddit
    end
  end

  test "featured scope returns posts with featured_in_issue" do
    featured = RedditPost.featured
    assert_includes featured, reddit_posts(:featured_post)
    assert_not_includes featured, reddit_posts(:ruby_post)
  end

  test "search_by_title finds matching posts" do
    results = RedditPost.search_by_title("Ruby 4.0")
    assert_includes results, reddit_posts(:ruby_post)
    assert_not_includes results, reddit_posts(:rails_post)
  end

  test "sync_from_api! upserts posts from RSS feeds" do
    rss_body = <<~XML
      <?xml version="1.0" encoding="UTF-8"?>
      <feed xmlns="http://www.w3.org/2005/Atom">
        <title>r/ruby</title>
        <entry>
          <title>Amazing Ruby gem discovered</title>
          <link href="https://www.reddit.com/r/ruby/comments/zzz111/amazing_ruby_gem/"/>
          <author><name>testuser</name></author>
          <published>2025-06-01T12:00:00Z</published>
          <content type="html">&lt;a href="https://example.com/gem"&gt;[link]&lt;/a&gt;</content>
        </entry>
      </feed>
    XML

    empty_rss = <<~XML
      <?xml version="1.0" encoding="UTF-8"?>
      <feed xmlns="http://www.w3.org/2005/Atom">
        <title>r/rails</title>
      </feed>
    XML

    stub_request(:get, "https://www.reddit.com/r/ruby/hot/.rss?limit=50")
      .to_return(status: 200, body: rss_body, headers: {"Content-Type" => "application/xml"})
    stub_request(:get, "https://www.reddit.com/r/rails/hot/.rss?limit=50")
      .to_return(status: 200, body: empty_rss, headers: {"Content-Type" => "application/xml"})

    assert_difference "RedditPost.count", 1 do
      RedditPost.sync_from_api!
    end

    post = RedditPost.find_by(reddit_id: "zzz111")
    assert_equal "Amazing Ruby gem discovered", post.title
    assert_equal "ruby", post.subreddit
    assert_equal "https://example.com/gem", post.external_url
    assert_not_nil post.first_seen_at
  end

  test "sync_from_api! returns empty array on api error" do
    stub_request(:get, "https://www.reddit.com/r/ruby/hot/.rss?limit=50")
      .to_return(status: 500)
    stub_request(:get, "https://www.reddit.com/r/rails/hot/.rss?limit=50")
      .to_return(status: 200, body: '<?xml version="1.0"?><feed xmlns="http://www.w3.org/2005/Atom"><title>r/rails</title></feed>', headers: {"Content-Type" => "application/xml"})

    result = RedditPost.sync_from_api!
    assert_equal [], result
  end

  test "sync_from_api! handles malformed XML" do
    stub_request(:get, "https://www.reddit.com/r/ruby/hot/.rss?limit=50")
      .to_return(status: 200, body: "not valid xml at all", headers: {"Content-Type" => "application/xml"})
    stub_request(:get, "https://www.reddit.com/r/rails/hot/.rss?limit=50")
      .to_return(status: 200, body: '<?xml version="1.0"?><feed xmlns="http://www.w3.org/2005/Atom"><title>r/rails</title></feed>', headers: {"Content-Type" => "application/xml"})

    result = RedditPost.sync_from_api!
    assert_equal [], result
  end

  test "sync_from_api! preserves first_seen_at on re-sync" do
    rss_body = <<~XML
      <?xml version="1.0" encoding="UTF-8"?>
      <feed xmlns="http://www.w3.org/2005/Atom">
        <title>r/ruby</title>
        <entry>
          <title>Updated: What's new in Ruby 4.0?</title>
          <link href="https://www.reddit.com/r/ruby/comments/abc123/whats_new_in_ruby_40/"/>
          <author><name>rubyist</name></author>
          <published>2025-06-01T12:00:00Z</published>
        </entry>
      </feed>
    XML

    empty_rss = <<~XML
      <?xml version="1.0" encoding="UTF-8"?>
      <feed xmlns="http://www.w3.org/2005/Atom">
        <title>r/rails</title>
      </feed>
    XML

    stub_request(:get, "https://www.reddit.com/r/ruby/hot/.rss?limit=50")
      .to_return(status: 200, body: rss_body, headers: {"Content-Type" => "application/xml"})
    stub_request(:get, "https://www.reddit.com/r/rails/hot/.rss?limit=50")
      .to_return(status: 200, body: empty_rss, headers: {"Content-Type" => "application/xml"})

    original_first_seen = reddit_posts(:ruby_post).first_seen_at

    assert_no_difference "RedditPost.count" do
      RedditPost.sync_from_api!
    end

    reddit_posts(:ruby_post).reload
    assert_equal original_first_seen, reddit_posts(:ruby_post).first_seen_at
    assert_equal "Updated: What's new in Ruby 4.0?", reddit_posts(:ruby_post).title
  end
end
