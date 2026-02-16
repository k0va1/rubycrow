require "test_helper"

class ArticleTest < ActiveSupport::TestCase
  test "valid article" do
    article = Article.new(blog: blogs(:speedshop), title: "Test", url: "https://example.com/test")
    assert article.valid?
  end

  test "requires title" do
    article = Article.new(blog: blogs(:speedshop), url: "https://example.com/test")
    assert_not article.valid?
    assert_includes article.errors[:title], "can't be blank"
  end

  test "requires url" do
    article = Article.new(blog: blogs(:speedshop), title: "Test")
    assert_not article.valid?
    assert_includes article.errors[:url], "can't be blank"
  end

  test "url must be unique" do
    article = Article.new(blog: blogs(:speedshop), title: "Dupe", url: articles(:rails_performance).url)
    assert_not article.valid?
    assert_includes article.errors[:url], "has already been taken"
  end

  test "belongs to blog" do
    assert_equal blogs(:speedshop), articles(:rails_performance).blog
  end

  test "published scope orders by published_at desc" do
    articles = Article.published
    dates = articles.map(&:published_at).compact
    assert_equal dates, dates.sort.reverse
  end

  test "recent scope limits results" do
    assert Article.recent(2).count <= 2
  end

  test "unprocessed scope returns unprocessed articles" do
    unprocessed = Article.unprocessed
    unprocessed.each do |article|
      assert_not article.processed?
    end
  end

  test "featured scope returns articles with featured_in_issue" do
    featured = Article.featured
    assert_includes featured, articles(:featured_article)
    assert_not_includes featured, articles(:rails_performance)
  end
end
