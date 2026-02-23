require "test_helper"

class SyncGithubReposJobTest < ActiveSupport::TestCase
  test "calls GithubRepo.sync_from_api!" do
    GithubRepo.expects(:sync_from_api!).once
    SyncGithubReposJob.perform_now
  end
end
