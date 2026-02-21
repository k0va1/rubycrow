require "test_helper"

class Admin::SubscribersControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in_admin
    @subscriber = subscribers(:one)
  end

  test "redirects when not authenticated" do
    delete admin_session_path
    get admin_subscribers_path
    assert_redirected_to new_admin_session_path
  end

  test "index" do
    get admin_subscribers_path
    assert_response :success
  end

  test "show" do
    get admin_subscriber_path(@subscriber)
    assert_response :success
  end

  test "new" do
    get new_admin_subscriber_path
    assert_response :success
  end

  test "create with valid params" do
    assert_difference("Subscriber.count") do
      post admin_subscribers_path, params: {subscriber: {email: "newadmin@example.com"}}
    end
    assert_redirected_to admin_subscriber_path(Subscriber.last)
  end

  test "create with invalid params" do
    post admin_subscribers_path, params: {subscriber: {email: ""}}
    assert_response :unprocessable_content
  end

  test "edit" do
    get edit_admin_subscriber_path(@subscriber)
    assert_response :success
  end

  test "update with valid params" do
    patch admin_subscriber_path(@subscriber), params: {subscriber: {email: "updated@example.com"}}
    assert_redirected_to admin_subscriber_path(@subscriber)
    assert_equal "updated@example.com", @subscriber.reload.email
  end

  test "update with invalid params" do
    patch admin_subscriber_path(@subscriber), params: {subscriber: {email: ""}}
    assert_response :unprocessable_content
  end

  test "index with search by email" do
    get admin_subscribers_path(search: "dev@")
    assert_response :success
    assert_includes response.body, "dev@example.com"
    assert_not_includes response.body, "rubyist@example.com"
  end

  test "index with search no results" do
    get admin_subscribers_path(search: "nonexistent")
    assert_response :success
  end

  test "destroy" do
    subscriber_without_clicks = subscribers(:inactive)
    assert_difference("Subscriber.count", -1) do
      delete admin_subscriber_path(subscriber_without_clicks)
    end
    assert_redirected_to admin_subscribers_path
  end
end
