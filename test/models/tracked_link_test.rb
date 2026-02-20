require "test_helper"

class TrackedLinkTest < ActiveSupport::TestCase
  test "auto-generates token on create" do
    link = TrackedLink.new(destination_url: "https://example.com")
    link.valid?
    assert link.token.present?
  end

  test "does not overwrite existing token" do
    link = TrackedLink.new(
      token: "custom_token",
      destination_url: "https://example.com"
    )
    link.valid?
    assert_equal "custom_token", link.token
  end

  test "validates uniqueness of token" do
    existing = tracked_links(:link_one)
    link = TrackedLink.new(
      token: existing.token,
      destination_url: "https://example.com"
    )
    assert_not link.valid?
    assert_includes link.errors[:token], "has already been taken"
  end

  test "validates presence of destination_url" do
    link = TrackedLink.new
    link.valid?
    assert_includes link.errors[:destination_url], "can't be blank"
  end

  test "belongs to trackable (polymorphic)" do
    link = tracked_links(:link_one)
    assert_equal newsletter_items(:rails_update), link.trackable
  end

  test "newsletter_issue traverses through trackable chain" do
    link = tracked_links(:link_one)
    assert_equal link.trackable.newsletter_section.newsletter_issue, link.newsletter_issue
  end

  test "newsletter_issue returns nil when trackable is nil" do
    link = TrackedLink.new(destination_url: "https://example.com")
    assert_nil link.newsletter_issue
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
