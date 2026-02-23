require "test_helper"

class Admin::RubyGemsControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in_admin
    @ruby_gem = ruby_gems(:rack_updated)
  end

  test "redirects when not authenticated" do
    delete admin_session_path
    get admin_ruby_gems_path
    assert_redirected_to new_admin_session_path
  end

  test "index" do
    get admin_ruby_gems_path
    assert_response :success
  end

  test "index with activity_type filter" do
    get admin_ruby_gems_path(activity_type: "new")
    assert_response :success
  end

  test "index with search" do
    get admin_ruby_gems_path(search: "rack")
    assert_response :success
  end

  test "index with period filter" do
    get admin_ruby_gems_path(period: "last_week")
    assert_response :success
  end

  test "show" do
    get admin_ruby_gem_path(@ruby_gem)
    assert_response :success
  end

  test "new" do
    get new_admin_ruby_gem_path
    assert_response :success
  end

  test "create with valid params" do
    assert_difference("RubyGem.count") do
      post admin_ruby_gems_path, params: {ruby_gem: {
        name: "brand_new_gem",
        version: "1.0.0",
        project_url: "https://rubygems.org/gems/brand_new_gem",
        activity_type: "new"
      }}
    end
    assert_redirected_to admin_ruby_gem_path(RubyGem.unscoped.last)
  end

  test "create with invalid params" do
    post admin_ruby_gems_path, params: {ruby_gem: {name: "", version: "", project_url: ""}}
    assert_response :unprocessable_content
  end

  test "edit" do
    get edit_admin_ruby_gem_path(@ruby_gem)
    assert_response :success
  end

  test "update with valid params" do
    patch admin_ruby_gem_path(@ruby_gem), params: {ruby_gem: {version: "3.2.0"}}
    assert_redirected_to admin_ruby_gem_path(@ruby_gem)
    assert_equal "3.2.0", @ruby_gem.reload.version
  end

  test "update with invalid params" do
    patch admin_ruby_gem_path(@ruby_gem), params: {ruby_gem: {name: ""}}
    assert_response :unprocessable_content
  end

  test "destroy" do
    assert_difference("RubyGem.count", -1) do
      delete admin_ruby_gem_path(@ruby_gem)
    end
    assert_redirected_to admin_ruby_gems_path
  end
end
