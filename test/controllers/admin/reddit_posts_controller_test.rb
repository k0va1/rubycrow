require "test_helper"

class Admin::RedditPostsControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in_admin
    @reddit_post = reddit_posts(:ruby_post)
  end

  test "redirects when not authenticated" do
    delete admin_session_path
    get admin_reddit_posts_path
    assert_redirected_to new_admin_session_path
  end

  test "index" do
    get admin_reddit_posts_path
    assert_response :success
  end

  test "index with subreddit filter" do
    get admin_reddit_posts_path(subreddit: "ruby")
    assert_response :success
  end

  test "index with search" do
    get admin_reddit_posts_path(search: "Ruby")
    assert_response :success
  end

  test "index with period filter" do
    get admin_reddit_posts_path(period: "last_week")
    assert_response :success
  end

  test "show" do
    get admin_reddit_post_path(@reddit_post)
    assert_response :success
  end

  test "new" do
    get new_admin_reddit_post_path
    assert_response :success
  end

  test "create with valid params" do
    assert_difference("RedditPost.count") do
      post admin_reddit_posts_path, params: {reddit_post: {
        reddit_id: "xyz999",
        title: "New post",
        url: "https://www.reddit.com/r/ruby/comments/xyz999/new_post/",
        subreddit: "ruby",
        posted_at: 1.hour.ago
      }}
    end
    assert_redirected_to admin_reddit_post_path(RedditPost.unscoped.last)
  end

  test "create with invalid params" do
    post admin_reddit_posts_path, params: {reddit_post: {reddit_id: "", title: "", url: ""}}
    assert_response :unprocessable_content
  end

  test "edit" do
    get edit_admin_reddit_post_path(@reddit_post)
    assert_response :success
  end

  test "update with valid params" do
    patch admin_reddit_post_path(@reddit_post), params: {reddit_post: {title: "Updated Title"}}
    assert_redirected_to admin_reddit_post_path(@reddit_post)
    assert_equal "Updated Title", @reddit_post.reload.title
  end

  test "update with invalid params" do
    patch admin_reddit_post_path(@reddit_post), params: {reddit_post: {title: ""}}
    assert_response :unprocessable_content
  end

  test "destroy" do
    assert_difference("RedditPost.count", -1) do
      delete admin_reddit_post_path(@reddit_post)
    end
    assert_redirected_to admin_reddit_posts_path
  end
end
