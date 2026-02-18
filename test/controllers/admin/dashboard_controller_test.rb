require "test_helper"

class Admin::DashboardControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in_admin
  end

  test "redirects when not authenticated" do
    delete admin_session_path
    get admin_root_path
    assert_redirected_to new_admin_session_path
  end

  test "index shows dashboard" do
    get admin_root_path
    assert_response :success
  end
end
