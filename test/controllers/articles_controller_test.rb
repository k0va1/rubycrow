require "test_helper"

class ArticlesControllerTest < ActionDispatch::IntegrationTest
  test "index returns articles" do
    get articles_path
    assert_response :success
  end

  test "index includes article titles" do
    get articles_path
    assert_select "h3", text: articles(:martians_article).title
  end

  test "index includes blog names" do
    get articles_path
    assert_select "span", text: blogs(:speedshop).name
  end

  test "index renders turbo frame" do
    get articles_path
    assert_select "turbo-frame#live-feed"
  end

  test "index shows empty state when no articles" do
    Click.delete_all
    TrackedLink.delete_all
    Article.delete_all
    get articles_path
    assert_select "p", text: /No articles yet/
  end
end
