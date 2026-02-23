class SyncRubyGemsJob < ApplicationJob
  queue_as :default
  unique :until_executed, on_conflict: :log

  def perform
    RubyGem.sync_from_api!
  end
end
