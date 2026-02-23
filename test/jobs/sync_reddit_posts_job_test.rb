require "test_helper"

class SyncRedditPostsJobTest < ActiveSupport::TestCase
  test "calls RedditPost.sync_from_api!" do
    RedditPost.expects(:sync_from_api!).once
    SyncRedditPostsJob.perform_now
  end
end
