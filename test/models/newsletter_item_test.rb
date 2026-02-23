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

  test "linkable is optional" do
    item = NewsletterItem.new(
      newsletter_section: newsletter_sections(:crows_pick),
      title: "No Linkable",
      url: "https://example.com/test",
      position: 0
    )
    assert item.valid?
    assert_nil item.linkable
  end

  test "linkable can be an article" do
    article = articles(:rails_performance)
    item = newsletter_items(:rails_update)
    assert_equal "Article", item.linkable_type
    assert_equal article, item.linkable
  end

  test "linkable can be a ruby gem" do
    gem = ruby_gems(:rack_updated)
    item = newsletter_items(:ruby_gem)
    assert_equal "RubyGem", item.linkable_type
    assert_equal gem, item.linkable
  end

  test "clear_blank_linkable nils both fields when linkable_type is blank" do
    item = NewsletterItem.new(
      newsletter_section: newsletter_sections(:crows_pick),
      title: "Test",
      url: "https://example.com",
      linkable_type: "",
      linkable_id: 1
    )
    item.valid?
    assert_nil item.linkable_type
    assert_nil item.linkable_id
  end

  test "clear_blank_linkable nils both fields when linkable_id is blank" do
    item = NewsletterItem.new(
      newsletter_section: newsletter_sections(:crows_pick),
      title: "Test",
      url: "https://example.com",
      linkable_type: "Article",
      linkable_id: nil
    )
    item.valid?
    assert_nil item.linkable_type
    assert_nil item.linkable_id
  end

  test "rejects invalid linkable_type" do
    item = NewsletterItem.new(
      newsletter_section: newsletter_sections(:crows_pick),
      title: "Test",
      url: "https://example.com",
      linkable_type: "User",
      linkable_id: 1
    )
    assert_not item.valid?
    assert_includes item.errors[:linkable_type], "is not included in the list"
  end

  test "first_flight? returns false when item has no article" do
    item = newsletter_items(:ruby_gem)
    assert_not item.first_flight?
  end

  test "first_flight? returns true when blog has not appeared in any previously sent issue" do
    item = newsletter_items(:issue_two_martians)
    assert item.first_flight?
  end

  test "first_flight? returns false when blog appeared in a previously sent issue" do
    item = newsletter_items(:issue_two_speedshop)
    assert_not item.first_flight?
  end

  test "first_flight? returns true when blog only appears in same unsent issue" do
    section = newsletter_sections(:issue_two_picks)
    article = articles(:martians_article)
    another_item = NewsletterItem.create!(
      newsletter_section: section,
      linkable: article,
      title: "Another Martians Post",
      url: "https://example.com/another-martians",
      position: 2
    )
    assert another_item.first_flight?
  end
end
