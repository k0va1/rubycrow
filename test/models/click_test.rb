require "test_helper"

class ClickTest < ActiveSupport::TestCase
  test "validates presence of clicked_at" do
    click = Click.new(tracked_link: tracked_links(:link_one))
    assert_not click.valid?
    assert_includes click.errors[:clicked_at], "can't be blank"
  end

  test "detects desktop device" do
    click = Click.new(
      tracked_link: tracked_links(:link_one),
      clicked_at: Time.current,
      user_agent: "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36"
    )
    click.valid?
    assert_equal "desktop", click.device_type
  end

  test "detects mobile device" do
    click = Click.new(
      tracked_link: tracked_links(:link_one),
      clicked_at: Time.current,
      user_agent: "Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X)"
    )
    click.valid?
    assert_equal "mobile", click.device_type
  end

  test "detects tablet device" do
    click = Click.new(
      tracked_link: tracked_links(:link_one),
      clicked_at: Time.current,
      user_agent: "Mozilla/5.0 (iPad; CPU OS 17_0 like Mac OS X)"
    )
    click.valid?
    assert_equal "tablet", click.device_type
  end

  test "leaves device_type nil when no user_agent" do
    click = Click.new(
      tracked_link: tracked_links(:link_one),
      clicked_at: Time.current,
      user_agent: nil
    )
    click.valid?
    assert_nil click.device_type
  end

  test "belongs to tracked_link" do
    click = clicks(:click_one)
    assert_equal tracked_links(:link_one), click.tracked_link
  end

  test "optionally belongs to subscriber" do
    click = clicks(:click_one)
    assert_equal subscribers(:one), click.subscriber
  end
end
