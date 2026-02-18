require "test_helper"

class ParseRssFeedsJobTest < ActiveSupport::TestCase
  test "enqueues a ParseRssFeedJob for each active blog" do
    assert_enqueued_jobs Blog.active.count, only: ParseRssFeedJob do
      ParseRssFeedsJob.perform_now
    end
  end
end
