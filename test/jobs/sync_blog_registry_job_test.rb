require "test_helper"

class SyncBlogRegistryJobTest < ActiveSupport::TestCase
  test "calls Blog.sync_from_registry!" do
    Blog.expects(:sync_from_registry!).once
    SyncBlogRegistryJob.perform_now
  end
end
