class SyncBlogRegistryJob < ApplicationJob
  queue_as :default

  def perform
    Blog.sync_from_registry
  end
end
