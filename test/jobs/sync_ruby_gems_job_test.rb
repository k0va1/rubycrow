require "test_helper"

class SyncRubyGemsJobTest < ActiveSupport::TestCase
  test "calls RubyGem.sync_from_api!" do
    RubyGem.expects(:sync_from_api!).once
    SyncRubyGemsJob.perform_now
  end
end
