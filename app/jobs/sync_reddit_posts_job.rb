class SyncRedditPostsJob < ApplicationJob
  queue_as :default
  unique :until_executed, on_conflict: :log

  def perform
    RedditPost.sync_from_api!
  end
end
