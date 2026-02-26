require "test_helper"

class Admin::BlogsControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in_admin
    @blog = blogs(:speedshop)
  end

  test "redirects when not authenticated" do
    delete admin_session_path
    get admin_blogs_path
    assert_redirected_to new_admin_session_path
  end

  test "index" do
    get admin_blogs_path
    assert_response :success
  end

  test "show" do
    get admin_blog_path(@blog)
    assert_response :success
  end

  test "new" do
    get new_admin_blog_path
    assert_response :success
  end

  test "create with valid params" do
    assert_difference("Blog.count") do
      post admin_blogs_path, params: {blog: {name: "New Blog", url: "https://newblog.com", rss_url: "https://newblog.com/feed"}}
    end
    assert_redirected_to admin_blog_path(Blog.last)
  end

  test "create with invalid params" do
    post admin_blogs_path, params: {blog: {name: "", url: ""}}
    assert_response :unprocessable_content
  end

  test "edit" do
    get edit_admin_blog_path(@blog)
    assert_response :success
  end

  test "update with valid params" do
    patch admin_blog_path(@blog), params: {blog: {name: "Updated Name"}}
    assert_redirected_to admin_blog_path(@blog)
    assert_equal "Updated Name", @blog.reload.name
  end

  test "update with invalid params" do
    patch admin_blog_path(@blog), params: {blog: {name: ""}}
    assert_response :unprocessable_content
  end

  test "destroy" do
    assert_difference("Blog.count", -1) do
      delete admin_blog_path(@blog)
    end
    assert_redirected_to admin_blogs_path
  end

  test "index with search by name" do
    get admin_blogs_path(search: "Nate")
    assert_response :success
    assert_includes response.body, "Nate Berkopec"
    assert_not_includes response.body, "Evil Martians"
  end

  test "index with search by URL" do
    get admin_blogs_path(search: "speedshop")
    assert_response :success
    assert_includes response.body, "Nate Berkopec"
    assert_not_includes response.body, "Evil Martians"
  end

  test "index with search no results" do
    get admin_blogs_path(search: "nonexistent")
    assert_response :success
  end

  test "create with tags string" do
    post admin_blogs_path, params: {blog: {name: "Tagged Blog", url: "https://tagged.com", rss_url: "https://tagged.com/feed", tags_string: "ruby, rails, web"}}
    blog = Blog.last
    assert_equal ["ruby", "rails", "web"], blog.tags
  end

  test "index excludes archived articles from blog ordering" do
    articles(:martians_article).update!(archived_at: Time.current)
    get admin_blogs_path
    assert_response :success
  end
end
