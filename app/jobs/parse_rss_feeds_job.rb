class ParseRssFeedsJob < ApplicationJob
  queue_as :default

  def perform
    Blog.active.find_each do |blog|
      blog.sync_feed
    rescue => e
      Rails.logger.error("Failed to parse feed for blog #{blog.id} (#{blog.name}): #{e.message}")
    end
  end
end
