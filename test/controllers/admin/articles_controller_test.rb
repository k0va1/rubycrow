require "test_helper"

class Admin::ArticlesControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in_admin
    @article = articles(:rails_performance)
  end

  test "redirects when not authenticated" do
    delete admin_session_path
    get admin_articles_path
    assert_redirected_to new_admin_session_path
  end

  test "index" do
    get admin_articles_path
    assert_response :success
  end

  test "index with blog_id filter" do
    get admin_articles_path(blog_id: blogs(:speedshop).id)
    assert_response :success
  end

  test "show" do
    get admin_article_path(@article)
    assert_response :success
  end

  test "new" do
    get new_admin_article_path
    assert_response :success
  end

  test "create with valid params" do
    assert_difference("Article.count") do
      post admin_articles_path, params: {article: {title: "New Article", url: "https://example.com/new-article", blog_id: blogs(:speedshop).id}}
    end
    assert_redirected_to admin_article_path(Article.unscoped.last)
  end

  test "create with invalid params" do
    post admin_articles_path, params: {article: {title: "", url: ""}}
    assert_response :unprocessable_content
  end

  test "edit" do
    get edit_admin_article_path(@article)
    assert_response :success
  end

  test "update with valid params" do
    patch admin_article_path(@article), params: {article: {title: "Updated Title"}}
    assert_redirected_to admin_article_path(@article)
    assert_equal "Updated Title", @article.reload.title
  end

  test "update with invalid params" do
    patch admin_article_path(@article), params: {article: {title: ""}}
    assert_response :unprocessable_content
  end

  test "index with search by title" do
    get admin_articles_path(search: "Rails")
    assert_response :success
    assert_includes response.body, "How to Make Your Rails App Fast"
    assert_not_includes response.body, "ViewComponent Best Practices"
  end

  test "index with search no results" do
    get admin_articles_path(search: "nonexistent")
    assert_response :success
  end

  test "destroy" do
    assert_difference("Article.count", -1) do
      delete admin_article_path(@article)
    end
    assert_redirected_to admin_articles_path
  end
end
