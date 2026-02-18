class ParseRssFeedsJob < ApplicationJob
  queue_as :default

  def perform
    Blog.active.find_each do |blog|
      ParseRssFeedJob.perform_later(blog.id)
    end
  end
end
