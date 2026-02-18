require "test_helper"

class Admin::SessionsControllerTest < ActionDispatch::IntegrationTest
  test "new renders login form" do
    get new_admin_session_path
    assert_response :success
  end

  test "create with valid credentials signs in" do
    post admin_session_path, params: {
      email: Rails.application.credentials.admin_email,
      password: Rails.application.credentials.admin_password
    }
    assert_redirected_to admin_root_path
    follow_redirect!
    assert_response :success
  end

  test "create with invalid credentials re-renders form" do
    post admin_session_path, params: {email: "wrong@example.com", password: "wrong"}
    assert_response :unprocessable_content
  end

  test "destroy signs out" do
    sign_in_admin
    delete admin_session_path
    assert_redirected_to new_admin_session_path
  end

  test "unauthenticated access redirects to login" do
    get admin_root_path
    assert_redirected_to new_admin_session_path
  end
end
