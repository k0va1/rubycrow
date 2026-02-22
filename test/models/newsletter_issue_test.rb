require "test_helper"

class NewsletterIssueTest < ActiveSupport::TestCase
  test "validates presence of issue_number" do
    issue = NewsletterIssue.new(subject: "Test")
    assert_not issue.valid?
    assert_includes issue.errors[:issue_number], "can't be blank"
  end

  test "validates uniqueness of issue_number" do
    existing = newsletter_issues(:issue_one)
    issue = NewsletterIssue.new(issue_number: existing.issue_number, subject: "Dup")
    assert_not issue.valid?
    assert_includes issue.errors[:issue_number], "has already been taken"
  end

  test "validates presence of subject" do
    issue = NewsletterIssue.new(issue_number: 99)
    assert_not issue.valid?
    assert_includes issue.errors[:subject], "can't be blank"
  end

  test "click_through_rate returns percentage" do
    issue = newsletter_issues(:issue_one)
    expected = (issue.total_unique_clicks.to_f / issue.subscriber_count * 100).round(2)
    assert_equal expected, issue.click_through_rate
  end

  test "click_through_rate returns 0 when subscriber_count is zero" do
    issue = newsletter_issues(:issue_two)
    assert_equal 0, issue.click_through_rate
  end

  test "sent scope returns issues with sent_at" do
    sent_issues = NewsletterIssue.sent
    assert_includes sent_issues, newsletter_issues(:issue_one)
    assert_not_includes sent_issues, newsletter_issues(:issue_two)
  end

  test "create_tracked_links! generates links from sections and items" do
    issue = NewsletterIssue.create!(issue_number: 99, subject: "Test Issue")
    section = issue.newsletter_sections.create!(title: "Shiny Objects", position: 0)
    section.newsletter_items.create!(title: "Test Article", url: "https://example.com/test", position: 0)

    assert_difference "TrackedLink.count", 1 do
      issue.create_tracked_links!
    end

    link = issue.tracked_links.first
    assert_equal "Test Article", link.trackable.title
    assert_includes link.destination_url, "utm_source=rubycrow"
  end

  test "create_tracked_links! is idempotent" do
    issue = NewsletterIssue.create!(issue_number: 100, subject: "Test")
    section = issue.newsletter_sections.create!(title: "Shiny Objects", position: 0)
    section.newsletter_items.create!(title: "Test", url: "https://example.com/test", position: 0)

    issue.create_tracked_links!
    assert_no_difference "TrackedLink.count" do
      issue.create_tracked_links!
    end
  end

  test "create_tracked_links! sets trackable to newsletter item" do
    article = articles(:rails_performance)
    issue = NewsletterIssue.create!(issue_number: 101, subject: "Test")
    section = issue.newsletter_sections.create!(title: "Crows Pick", position: 0)
    section.newsletter_items.create!(title: article.title, url: article.url, position: 0, linkable: article)

    issue.create_tracked_links!

    link = issue.tracked_links.first
    assert_equal article, link.trackable.article
  end
end
