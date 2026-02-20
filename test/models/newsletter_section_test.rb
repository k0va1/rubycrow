require "test_helper"

class NewsletterSectionTest < ActiveSupport::TestCase
  test "validates presence of title" do
    section = NewsletterSection.new(newsletter_issue: newsletter_issues(:issue_one))
    assert_not section.valid?
    assert_includes section.errors[:title], "can't be blank"
  end

  test "belongs to newsletter_issue" do
    section = newsletter_sections(:crows_pick)
    assert_equal newsletter_issues(:issue_one), section.newsletter_issue
  end

  test "has many newsletter_items" do
    section = newsletter_sections(:crows_pick)
    assert_includes section.newsletter_items, newsletter_items(:rails_update)
  end

  test "destroys dependent items" do
    section = newsletter_sections(:crows_pick)
    assert_difference "NewsletterItem.count", -1 do
      section.destroy
    end
  end

  test "default scope orders by position" do
    issue = newsletter_issues(:issue_one)
    sections = issue.newsletter_sections
    assert_equal [0, 1], sections.map(&:position)
  end

  test "accepts nested attributes for items" do
    section = newsletter_sections(:crows_pick)
    section.update!(newsletter_items_attributes: [
      {title: "New Item", url: "https://example.com/new", position: 1}
    ])
    assert_equal "New Item", section.newsletter_items.last.title
  end

  test "rejects blank nested items" do
    section = newsletter_sections(:crows_pick)
    assert_no_difference "NewsletterItem.count" do
      section.update!(newsletter_items_attributes: [
        {title: "", url: "", description: ""}
      ])
    end
  end
end
