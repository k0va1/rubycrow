class NewsletterMailerPreview < ActionMailer::Preview
  def issue
    newsletter_issue = NewsletterIssue.joins(newsletter_sections: {newsletter_items: :tracked_link}).first || seed_preview_data
    subscriber = Subscriber.active.first || Subscriber.find_or_create_by!(email: "preview@example.com", confirmed: true)

    NewsletterMailer.issue(newsletter_issue: newsletter_issue, subscriber: subscriber)
  end

  private

  def seed_preview_data
    blog = Blog.first || Blog.create!(name: "SpeedShop", url: "https://www.speedshop.co", rss_url: "https://www.speedshop.co/feed.xml")

    sections_data = {
      "Crows Pick" => [
        {title: "Building a Zero-Downtime Deployment Pipeline with Kamal 2", description: "A deep dive into configuring Kamal 2 for production Rails apps with zero-downtime deploys, health checks, and rollback strategies."}
      ],
      "Shiny Objects" => [
        {title: "How We Reduced Our Sidekiq Memory Usage by 60%", description: "Practical techniques for profiling and reducing memory bloat in Sidekiq workers, including GC tuning and object allocation patterns."},
        {title: "Ruby 3.4's New Pattern Matching Features You Missed", description: "An overlooked addition in Ruby 3.4 that makes pattern matching significantly more expressive for complex data structures."},
        {title: "Understanding ActiveRecord's Query Cache", description: "The query cache is great until it isn't. Learn when it silently causes issues and how to debug memory bloat in long-running requests."}
      ],
      "Crow Call" => [
        {title: "Building a Custom Authentication System Without Devise", description: "A beautifully written walkthrough of building auth from scratch in Rails 8, covering sessions, password resets, and magic links."}
      ],
      "Quick Gems" => [
        {title: "Rails 8.1 Beta Released", description: nil},
        {title: "dry-rb 2.0 is Here", description: nil},
        {title: "New Rubocop 2.0 Rules You Should Enable", description: nil}
      ]
    }

    issue = NewsletterIssue.create!(issue_number: 9999, subject: "The Crow scanned 47 blog posts this week and found 8 shiny gems worth your time.")

    sections_data.each_with_index do |(section_title, items), section_idx|
      section = issue.newsletter_sections.create!(title: section_title, position: section_idx)

      items.each_with_index do |attrs, item_idx|
        url = "https://example.com/preview-#{SecureRandom.hex(4)}"
        article = blog.articles.create!(title: attrs[:title], url: url, summary: attrs[:description], published_at: item_idx.days.ago)
        item = section.newsletter_items.create!(title: attrs[:title], description: attrs[:description], url: url, position: item_idx, linkable: article)

        utm_url = "#{url}?utm_source=rubycrow&utm_medium=email&utm_campaign=issue_9999"
        item.create_tracked_link!(destination_url: utm_url)
      end
    end

    issue
  end
end
