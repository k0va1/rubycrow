class ParseRssFeedJob < ApplicationJob
  queue_as :default

  def perform(blog_id)
    Blog.find(blog_id).sync_feed!
  end
end
