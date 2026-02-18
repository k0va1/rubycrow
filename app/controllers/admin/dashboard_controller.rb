module Admin
  class DashboardController < BaseController
    def index
      @total_subscribers = Subscriber.count
      @active_subscribers = Subscriber.active.count
      @total_blogs = Blog.count
      @active_blogs = Blog.active.count
      @total_articles = Article.count
      @unprocessed_articles = Article.unprocessed.count
      @total_issues = NewsletterIssue.count
      @sent_issues = NewsletterIssue.sent.count
      @total_clicks = Click.count
      @recent_issues = NewsletterIssue.order(created_at: :desc).limit(5)
      @recent_articles = Article.includes(:blog).order(published_at: :desc).limit(5)
    end
  end
end
