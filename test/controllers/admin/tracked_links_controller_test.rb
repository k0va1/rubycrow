require "test_helper"

class Admin::TrackedLinksControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in_admin
    @tracked_link = tracked_links(:link_one)
  end

  test "redirects when not authenticated" do
    delete admin_session_path
    get admin_tracked_links_path
    assert_redirected_to new_admin_session_path
  end

  test "index" do
    get admin_tracked_links_path
    assert_response :success
  end

  test "index with newsletter_issue_id filter" do
    get admin_tracked_links_path(newsletter_issue_id: newsletter_issues(:issue_one).id)
    assert_response :success
  end

  test "show" do
    get admin_tracked_link_path(@tracked_link)
    assert_response :success
  end

  test "new" do
    get new_admin_tracked_link_path
    assert_response :success
  end

  test "create with valid params" do
    assert_difference("TrackedLink.count") do
      post admin_tracked_links_path, params: {tracked_link: {destination_url: "https://example.com/new"}}
    end
    assert_redirected_to admin_tracked_link_path(TrackedLink.last)
  end

  test "create with invalid params" do
    post admin_tracked_links_path, params: {tracked_link: {destination_url: ""}}
    assert_response :unprocessable_content
  end

  test "edit" do
    get edit_admin_tracked_link_path(@tracked_link)
    assert_response :success
  end

  test "update with valid params" do
    patch admin_tracked_link_path(@tracked_link), params: {tracked_link: {destination_url: "https://example.com/updated"}}
    assert_redirected_to admin_tracked_link_path(@tracked_link)
    assert_equal "https://example.com/updated", @tracked_link.reload.destination_url
  end

  test "update with invalid params" do
    patch admin_tracked_link_path(@tracked_link), params: {tracked_link: {destination_url: ""}}
    assert_response :unprocessable_content
  end

  test "destroy" do
    assert_difference("TrackedLink.count", -1) do
      delete admin_tracked_link_path(@tracked_link)
    end
    assert_redirected_to admin_tracked_links_path
  end
end
