class NewsletterMailerPreview < ActionMailer::Preview
  def issue
    newsletter_issue = NewsletterIssue.joins(:tracked_links).first || seed_preview_data
    subscriber = Subscriber.active.first || Subscriber.find_or_create_by!(email: "preview@example.com", confirmed: true)

    NewsletterMailer.issue(newsletter_issue: newsletter_issue, subscriber: subscriber)
  end

  private

  def seed_preview_data
    blog = Blog.first || Blog.create!(name: "SpeedShop", url: "https://www.speedshop.co", rss_url: "https://www.speedshop.co/feed.xml")

    articles = [
      {title: "Building a Zero-Downtime Deployment Pipeline with Kamal 2", summary: "A deep dive into configuring Kamal 2 for production Rails apps with zero-downtime deploys, health checks, and rollback strategies.", section: "crows_pick"},
      {title: "How We Reduced Our Sidekiq Memory Usage by 60%", summary: "Practical techniques for profiling and reducing memory bloat in Sidekiq workers, including GC tuning and object allocation patterns.", section: "shiny_objects"},
      {title: "Ruby 3.4's New Pattern Matching Features You Missed", summary: "An overlooked addition in Ruby 3.4 that makes pattern matching significantly more expressive for complex data structures.", section: "shiny_objects"},
      {title: "Understanding ActiveRecord's Query Cache", summary: "The query cache is great until it isn't. Learn when it silently causes issues and how to debug memory bloat in long-running requests.", section: "shiny_objects"},
      {title: "Building a Custom Authentication System Without Devise", summary: "A beautifully written walkthrough of building auth from scratch in Rails 8, covering sessions, password resets, and magic links.", section: "crow_call"},
      {title: "Rails 8.1 Beta Released", summary: nil, section: "quick_gems"},
      {title: "dry-rb 2.0 is Here", summary: nil, section: "quick_gems"},
      {title: "New Rubocop 2.0 Rules You Should Enable", summary: nil, section: "quick_gems"}
    ]

    issue = NewsletterIssue.create!(issue_number: 9999, subject: "The Crow scanned 47 blog posts this week and found 8 shiny gems worth your time.")

    articles.each_with_index do |attrs, i|
      url = "https://example.com/preview-#{SecureRandom.hex(4)}"
      article = blog.articles.create!(title: attrs[:title], url: url, summary: attrs[:summary], published_at: i.days.ago)
      issue.tracked_links.create!(
        article: article,
        destination_url: "#{url}?utm_source=rubycrow&utm_medium=email&utm_campaign=issue_9999",
        position_in_newsletter: i + 1,
        section: attrs[:section]
      )
    end

    issue
  end
end
