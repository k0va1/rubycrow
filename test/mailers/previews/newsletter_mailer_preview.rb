class NewsletterMailerPreview < ActionMailer::Preview
  def issue
    newsletter_issue = NewsletterIssue.joins(newsletter_sections: {newsletter_items: :tracked_link}).first || seed_preview_data
    subscriber = Subscriber.active.first || Subscriber.find_or_create_by!(email: "preview@example.com", confirmed: true)

    NewsletterMailer.issue(newsletter_issue: newsletter_issue, subscriber: subscriber)
  end

  private

  def seed_preview_data
    blog = Blog.first || Blog.create!(name: "SpeedShop", url: "https://www.speedshop.co", rss_url: "https://www.speedshop.co/feed.xml")

    gem = RubyGem.first || RubyGem.create!(
      name: "solid_queue", version: "1.0.0", project_url: "https://rubygems.org/gems/solid_queue",
      activity_type: "new", info: "Database-backed Active Job backend"
    )

    repo = GithubRepo.first || GithubRepo.create!(
      full_name: "rails/rails", name: "rails", url: "https://github.com/rails/rails",
      description: "Ruby on Rails", stars: 56000
    )

    reddit = RedditPost.first || RedditPost.create!(
      reddit_id: "preview123", title: "What's new in Ruby 4.0?",
      url: "https://www.reddit.com/r/ruby/comments/preview123/test/", subreddit: "ruby"
    )

    sections_data = {
      "Crows Pick" => [
        {title: "Building a Zero-Downtime Deployment Pipeline with Kamal 2", description: "A deep dive into configuring Kamal 2 for production Rails apps with zero-downtime deploys, health checks, and rollback strategies.", linkable: blog.articles.create!(title: "Building a Zero-Downtime Deployment Pipeline with Kamal 2", url: "https://example.com/preview-#{SecureRandom.hex(4)}", summary: "A deep dive into configuring Kamal 2", published_at: 1.day.ago)}
      ],
      "Shiny Objects" => [
        {title: "How We Reduced Our Sidekiq Memory Usage by 60%", description: "Practical techniques for profiling and reducing memory bloat in Sidekiq workers.", linkable: blog.articles.create!(title: "How We Reduced Our Sidekiq Memory Usage by 60%", url: "https://example.com/preview-#{SecureRandom.hex(4)}", published_at: 2.days.ago)},
        {title: gem.name, description: gem.info, linkable: gem},
        {title: repo.full_name, description: repo.description, linkable: repo}
      ],
      "Crow Call" => [
        {title: "Building a Custom Authentication System Without Devise", description: "A beautifully written walkthrough of building auth from scratch in Rails 8.", linkable: blog.articles.create!(title: "Building a Custom Authentication System Without Devise", url: "https://example.com/preview-#{SecureRandom.hex(4)}", published_at: 3.days.ago)}
      ],
      "Quick Gems" => [
        {title: reddit.title, description: nil, linkable: reddit},
        {title: "dry-rb 2.0 is Here", description: nil, linkable: nil},
        {title: "New Rubocop 2.0 Rules You Should Enable", description: nil, linkable: nil}
      ]
    }

    issue = NewsletterIssue.create!(issue_number: 9999, subject: "The Crow scanned 47 blog posts this week and found 8 shiny gems worth your time.")

    sections_data.each_with_index do |(section_title, items), section_idx|
      section = issue.newsletter_sections.create!(title: section_title, position: section_idx)

      items.each_with_index do |attrs, item_idx|
        url = attrs[:linkable]&.try(:url) || attrs[:linkable]&.try(:project_url) || "https://example.com/preview-#{SecureRandom.hex(4)}"
        item = section.newsletter_items.create!(title: attrs[:title], description: attrs[:description], url: url, position: item_idx, linkable: attrs[:linkable])

        utm_url = "#{url}?utm_source=rubycrow&utm_medium=email&utm_campaign=issue_9999"
        item.create_tracked_link!(destination_url: utm_url)
      end
    end

    issue
  end
end
