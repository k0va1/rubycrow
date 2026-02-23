require "test_helper"

class Admin::GithubReposControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in_admin
    @github_repo = github_repos(:rails_repo)
  end

  test "redirects when not authenticated" do
    delete admin_session_path
    get admin_github_repos_path
    assert_redirected_to new_admin_session_path
  end

  test "index" do
    get admin_github_repos_path
    assert_response :success
  end

  test "index with search" do
    get admin_github_repos_path(search: "rails")
    assert_response :success
  end

  test "index with period filter" do
    get admin_github_repos_path(period: "last_week")
    assert_response :success
  end

  test "show" do
    get admin_github_repo_path(@github_repo)
    assert_response :success
  end

  test "new" do
    get new_admin_github_repo_path
    assert_response :success
  end

  test "create with valid params" do
    assert_difference("GithubRepo.count") do
      post admin_github_repos_path, params: {github_repo: {
        full_name: "test/new-repo",
        name: "new-repo",
        url: "https://github.com/test/new-repo"
      }}
    end
    assert_redirected_to admin_github_repo_path(GithubRepo.unscoped.last)
  end

  test "create with invalid params" do
    post admin_github_repos_path, params: {github_repo: {full_name: "", name: "", url: ""}}
    assert_response :unprocessable_content
  end

  test "edit" do
    get edit_admin_github_repo_path(@github_repo)
    assert_response :success
  end

  test "update with valid params" do
    patch admin_github_repo_path(@github_repo), params: {github_repo: {description: "Updated description"}}
    assert_redirected_to admin_github_repo_path(@github_repo)
    assert_equal "Updated description", @github_repo.reload.description
  end

  test "update with invalid params" do
    patch admin_github_repo_path(@github_repo), params: {github_repo: {full_name: ""}}
    assert_response :unprocessable_content
  end

  test "destroy" do
    assert_difference("GithubRepo.count", -1) do
      delete admin_github_repo_path(@github_repo)
    end
    assert_redirected_to admin_github_repos_path
  end
end
