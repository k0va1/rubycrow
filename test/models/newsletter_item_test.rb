require "test_helper"

class NewsletterItemTest < ActiveSupport::TestCase
  test "validates presence of title" do
    item = NewsletterItem.new(newsletter_section: newsletter_sections(:crows_pick), url: "https://example.com")
    assert_not item.valid?
    assert_includes item.errors[:title], "can't be blank"
  end

  test "validates presence of url" do
    item = NewsletterItem.new(newsletter_section: newsletter_sections(:crows_pick), title: "Test")
    assert_not item.valid?
    assert_includes item.errors[:url], "can't be blank"
  end

  test "belongs to newsletter_section" do
    item = newsletter_items(:rails_update)
    assert_equal newsletter_sections(:crows_pick), item.newsletter_section
  end

  test "default scope orders by position" do
    section = newsletter_sections(:crows_pick)
    items = section.newsletter_items
    positions = items.map(&:position)
    assert_equal positions.sort, positions
  end

  test "valid with all required attributes" do
    item = NewsletterItem.new(
      newsletter_section: newsletter_sections(:crows_pick),
      title: "Test Item",
      url: "https://example.com/test",
      position: 0
    )
    assert item.valid?
  end

  test "article_id is optional" do
    item = NewsletterItem.new(
      newsletter_section: newsletter_sections(:crows_pick),
      title: "No Article",
      url: "https://example.com/test",
      position: 0
    )
    assert item.valid?
    assert_nil item.article_id
  end

  test "belongs_to article when set" do
    article = articles(:rails_performance)
    item = NewsletterItem.new(
      newsletter_section: newsletter_sections(:crows_pick),
      title: article.title,
      url: article.url,
      position: 0,
      article: article
    )
    assert item.valid?
    assert_equal article, item.article
  end
end
