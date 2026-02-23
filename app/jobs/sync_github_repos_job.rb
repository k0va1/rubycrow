class SyncGithubReposJob < ApplicationJob
  queue_as :default
  unique :until_executed, on_conflict: :log

  def perform
    GithubRepo.sync_from_api!
  end
end
