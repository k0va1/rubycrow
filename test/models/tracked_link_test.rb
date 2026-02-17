require "test_helper"

class TrackedLinkTest < ActiveSupport::TestCase
  test "auto-generates token on create" do
    link = TrackedLink.new(
      newsletter_issue: newsletter_issues(:issue_one),
      destination_url: "https://example.com"
    )
    link.valid?
    assert link.token.present?
  end

  test "does not overwrite existing token" do
    link = TrackedLink.new(
      token: "custom_token",
      newsletter_issue: newsletter_issues(:issue_one),
      destination_url: "https://example.com"
    )
    link.valid?
    assert_equal "custom_token", link.token
  end

  test "validates uniqueness of token" do
    existing = tracked_links(:link_one)
    link = TrackedLink.new(
      token: existing.token,
      newsletter_issue: newsletter_issues(:issue_one),
      destination_url: "https://example.com"
    )
    assert_not link.valid?
    assert_includes link.errors[:token], "has already been taken"
  end

  test "validates presence of destination_url" do
    link = TrackedLink.new(newsletter_issue: newsletter_issues(:issue_one))
    link.valid?
    assert_includes link.errors[:destination_url], "can't be blank"
  end

  test "validates section inclusion" do
    link = TrackedLink.new(
      newsletter_issue: newsletter_issues(:issue_one),
      destination_url: "https://example.com",
      section: "invalid_section"
    )
    assert_not link.valid?
    assert_includes link.errors[:section], "is not included in the list"
  end

  test "allows blank section" do
    link = TrackedLink.new(
      newsletter_issue: newsletter_issues(:issue_one),
      destination_url: "https://example.com",
      section: nil
    )
    link.valid?
    assert_not_includes link.errors.attribute_names, :section
  end

  test "tracked_url builds correct URL" do
    link = tracked_links(:link_one)
    url = link.tracked_url
    assert_includes url, "/go/#{link.token}"
  end

  test "tracked_url includes subscriber id when provided" do
    link = tracked_links(:link_one)
    subscriber = subscribers(:one)
    url = link.tracked_url(subscriber: subscriber)
    assert_includes url, "sid=#{subscriber.id}"
  end
end
