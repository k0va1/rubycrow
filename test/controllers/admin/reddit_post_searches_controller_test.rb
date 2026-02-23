require "test_helper"

class Admin::RedditPostSearchesControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in_admin
  end

  test "redirects when not authenticated" do
    delete admin_session_path
    get admin_reddit_post_searches_path(q: "ruby")
    assert_redirected_to new_admin_session_path
  end

  test "returns matching posts as JSON" do
    get admin_reddit_post_searches_path(q: "Ruby", format: :json)
    assert_response :success

    results = response.parsed_body
    assert results.any? { |p| p["label"].include?("Ruby") }
    assert results.all? { |p| p.key?("value") && p.key?("label") }
  end

  test "returns empty array for no matches" do
    get admin_reddit_post_searches_path(q: "zzzznonexistent", format: :json)
    assert_response :success
    assert_equal [], response.parsed_body
  end

  test "returns empty array when no query" do
    get admin_reddit_post_searches_path(format: :json)
    assert_response :success
    assert_equal [], response.parsed_body
  end

  test "returns single post by id" do
    post_record = reddit_posts(:ruby_post)
    get admin_reddit_post_searches_path(id: post_record.id, format: :json)
    assert_response :success

    result = response.parsed_body
    assert_equal post_record.id, result["id"]
    assert_equal post_record.title, result["title"]
    assert_equal post_record.url, result["url"]
    assert_includes result["description"], "r/#{post_record.subreddit}"
  end
end
