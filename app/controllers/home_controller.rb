class HomeController < ApplicationController
  def index
    @subscriber_count = Subscriber.count
    @blog_count = Blog.active.count
    @article_count = Article.count
  end
end
