require "test_helper"

class Admin::ClicksControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in_admin
    @click = clicks(:click_one)
  end

  test "redirects when not authenticated" do
    delete admin_session_path
    get admin_clicks_path
    assert_redirected_to new_admin_session_path
  end

  test "index" do
    get admin_clicks_path
    assert_response :success
  end

  test "index with tracked_link_id filter" do
    get admin_clicks_path(tracked_link_id: tracked_links(:link_one).id)
    assert_response :success
  end

  test "index with subscriber_id filter" do
    get admin_clicks_path(subscriber_id: subscribers(:one).id)
    assert_response :success
  end

  test "show" do
    get admin_click_path(@click)
    assert_response :success
  end

  test "destroy" do
    assert_difference("Click.count", -1) do
      delete admin_click_path(@click)
    end
    assert_redirected_to admin_clicks_path
  end
end
