class ParseRssFeedJob < ApplicationJob
  queue_as :default
  unique :until_executed, on_conflict: :log

  def perform(blog_id)
    Blog.find(blog_id).sync_feed!
  end
end
