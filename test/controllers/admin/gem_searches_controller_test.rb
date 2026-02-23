require "test_helper"

class Admin::GemSearchesControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in_admin
  end

  test "redirects when not authenticated" do
    delete admin_session_path
    get admin_gem_searches_path(q: "rack")
    assert_redirected_to new_admin_session_path
  end

  test "returns matching gems as JSON" do
    get admin_gem_searches_path(q: "rack", format: :json)
    assert_response :success

    results = response.parsed_body
    assert results.any? { |g| g["label"].include?("rack") }
    assert results.all? { |g| g.key?("value") && g.key?("label") }
  end

  test "returns empty array for no matches" do
    get admin_gem_searches_path(q: "zzzznonexistent", format: :json)
    assert_response :success
    assert_equal [], response.parsed_body
  end

  test "returns empty array when no query" do
    get admin_gem_searches_path(format: :json)
    assert_response :success
    assert_equal [], response.parsed_body
  end

  test "returns single gem by id" do
    gem = ruby_gems(:rack_updated)
    get admin_gem_searches_path(id: gem.id, format: :json)
    assert_response :success

    result = response.parsed_body
    assert_equal gem.id, result["id"]
    assert_equal gem.name, result["title"]
    assert_equal gem.project_url, result["url"]
    assert_equal gem.info, result["description"]
  end
end
