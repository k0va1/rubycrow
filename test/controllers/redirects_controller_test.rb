require "test_helper"

class RedirectsControllerTest < ActionDispatch::IntegrationTest
  test "redirects to destination for valid token" do
    link = tracked_links(:link_one)
    get tracked_redirect_path(link.token)
    assert_redirected_to link.destination_url
  end

  test "enqueues RecordClickJob" do
    link = tracked_links(:link_one)
    assert_enqueued_with(job: RecordClickJob) do
      get tracked_redirect_path(link.token)
    end
  end

  test "redirects to root for unknown token" do
    get tracked_redirect_path("nonexistent")
    assert_redirected_to root_path
  end

  test "passes subscriber id through" do
    link = tracked_links(:link_one)
    subscriber = subscribers(:one)

    assert_enqueued_jobs 1, only: RecordClickJob do
      get tracked_redirect_path(link.token, sid: subscriber.id)
    end
  end
end
