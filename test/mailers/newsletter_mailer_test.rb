require "test_helper"

class NewsletterMailerTest < ActiveSupport::TestCase
  test "issue renders with article linkable" do
    issue = newsletter_issues(:issue_one)
    subscriber = subscribers(:one)

    mail = NewsletterMailer.issue(newsletter_issue: issue, subscriber: subscriber)

    assert_equal issue.subject, mail.subject
    assert_equal [subscriber.email], mail.to
    assert_includes mail.html_part.body.to_s, "Rails 8.1 Released"
  end

  test "issue renders with ruby gem linkable" do
    issue = newsletter_issues(:issue_one)
    subscriber = subscribers(:one)

    mail = NewsletterMailer.issue(newsletter_issue: issue, subscriber: subscriber)

    assert_includes mail.html_part.body.to_s, "Rack 3.1.0"
  end

  test "issue renders with github repo linkable" do
    issue = newsletter_issues(:issue_one)
    subscriber = subscribers(:one)

    mail = NewsletterMailer.issue(newsletter_issue: issue, subscriber: subscriber)

    assert_includes mail.html_part.body.to_s, "rails/rails"
  end

  test "issue renders with reddit post linkable" do
    issue = newsletter_issues(:issue_one)
    subscriber = subscribers(:one)

    mail = NewsletterMailer.issue(newsletter_issue: issue, subscriber: subscriber)
    body = mail.html_part.body.to_s

    assert_includes body, "What&#39;s new in Ruby 4.0?"
  end

  test "issue includes source attribution for non-article items" do
    issue = newsletter_issues(:issue_one)
    subscriber = subscribers(:one)

    mail = NewsletterMailer.issue(newsletter_issue: issue, subscriber: subscriber)
    body = mail.html_part.body.to_s

    assert_includes body, ">RubyGems</span>"
    assert_includes body, ">GitHub</span>"
    assert_includes body, ">r/ruby</span>"
  end
end
