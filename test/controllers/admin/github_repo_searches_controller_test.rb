require "test_helper"

class Admin::GithubRepoSearchesControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in_admin
  end

  test "redirects when not authenticated" do
    delete admin_session_path
    get admin_github_repo_searches_path(q: "rails")
    assert_redirected_to new_admin_session_path
  end

  test "returns matching repos as JSON" do
    get admin_github_repo_searches_path(q: "rails", format: :json)
    assert_response :success

    results = response.parsed_body
    assert results.any? { |r| r["label"].include?("rails") }
    assert results.all? { |r| r.key?("value") && r.key?("label") }
  end

  test "returns empty array for no matches" do
    get admin_github_repo_searches_path(q: "zzzznonexistent", format: :json)
    assert_response :success
    assert_equal [], response.parsed_body
  end

  test "returns empty array when no query" do
    get admin_github_repo_searches_path(format: :json)
    assert_response :success
    assert_equal [], response.parsed_body
  end

  test "returns single repo by id" do
    repo = github_repos(:rails_repo)
    get admin_github_repo_searches_path(id: repo.id, format: :json)
    assert_response :success

    result = response.parsed_body
    assert_equal repo.id, result["id"]
    assert_equal repo.full_name, result["title"]
    assert_equal repo.url, result["url"]
    assert_equal repo.description, result["description"]
  end
end
