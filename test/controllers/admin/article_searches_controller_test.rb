require "test_helper"

class Admin::ArticleSearchesControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in_admin
  end

  test "redirects when not authenticated" do
    delete admin_session_path
    get admin_article_searches_path(q: "rails")
    assert_redirected_to new_admin_session_path
  end

  test "returns matching articles as JSON" do
    get admin_article_searches_path(q: "Rails", format: :json)
    assert_response :success

    results = response.parsed_body
    assert results.any? { |a| a["label"].include?("Rails") }
    assert results.all? { |a| a.key?("value") && a.key?("label") }
  end

  test "returns empty array for no matches" do
    get admin_article_searches_path(q: "zzzznonexistent", format: :json)
    assert_response :success
    assert_equal [], response.parsed_body
  end

  test "includes blog name in label" do
    get admin_article_searches_path(q: "Rails", format: :json)
    results = response.parsed_body
    result = results.find { |a| a["label"].include?("Rails") }
    assert_includes result["label"], "Nate Berkopec"
  end

  test "returns empty array when no query" do
    get admin_article_searches_path(format: :json)
    assert_response :success
    assert_equal [], response.parsed_body
  end

  test "returns single article by id" do
    article = articles(:rails_performance)
    get admin_article_searches_path(id: article.id, format: :json)
    assert_response :success

    result = response.parsed_body
    assert_equal article.id, result["id"]
    assert_equal article.title, result["title"]
    assert_equal article.url, result["url"]
    assert_equal article.summary, result["description"]
  end
end
