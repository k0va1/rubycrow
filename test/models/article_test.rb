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

  test "by_publish_date scope orders by published_at desc" do
    articles = Article.by_publish_date
    dates = articles.map(&:published_at).compact
    assert dates.any?
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

  test "archived? returns true when archived_at is set" do
    article = articles(:rails_performance)
    assert_not article.archived?

    article.archive!
    assert article.archived?
  end

  test "archive! sets archived_at" do
    article = articles(:rails_performance)
    assert_nil article.archived_at

    article.archive!
    assert_not_nil article.reload.archived_at
  end

  test "unarchive! clears archived_at" do
    article = articles(:rails_performance)
    article.update!(archived_at: Time.current)

    article.unarchive!
    assert_nil article.reload.archived_at
  end

  test "archived scope returns only archived articles" do
    article = articles(:rails_performance)
    article.update!(archived_at: Time.current)

    assert_includes Article.archived, article
    assert_not_includes Article.not_archived, article
  end

  test "not_archived scope excludes archived articles" do
    article = articles(:rails_performance)
    assert_includes Article.not_archived, article

    article.update!(archived_at: Time.current)
    assert_not_includes Article.not_archived, article
  end

  test "archived_last scope puts archived articles at the end" do
    recent = articles(:martians_article)
    older = articles(:rails_performance)
    recent.update!(archived_at: Time.current)

    results = Article.archived_last.by_publish_date.to_a
    assert results.index(older) < results.index(recent)
  end
end
