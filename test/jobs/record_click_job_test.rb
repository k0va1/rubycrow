require "test_helper"

class RecordClickJobTest < ActiveSupport::TestCase
  setup do
    @tracked_link = tracked_links(:link_one)
    @clicked_at = Time.current.iso8601
  end

  test "creates a click record" do
    assert_difference "Click.count", 1 do
      RecordClickJob.perform_now(
        tracked_link_id: @tracked_link.id,
        ip_address: "192.168.1.100",
        clicked_at: @clicked_at
      )
    end
  end

  test "increments total_clicks counter" do
    before_count = @tracked_link.total_clicks
    RecordClickJob.perform_now(
      tracked_link_id: @tracked_link.id,
      ip_address: "10.0.0.1",
      clicked_at: @clicked_at
    )
    assert_equal before_count + 1, @tracked_link.reload.total_clicks
  end

  test "increments unique_clicks for first click from IP" do
    before_count = @tracked_link.unique_clicks
    RecordClickJob.perform_now(
      tracked_link_id: @tracked_link.id,
      ip_address: "10.0.0.99",
      clicked_at: @clicked_at
    )
    assert_equal before_count + 1, @tracked_link.reload.unique_clicks
  end

  test "does not increment unique_clicks for duplicate IP" do
    RecordClickJob.perform_now(
      tracked_link_id: @tracked_link.id,
      ip_address: "10.0.0.50",
      clicked_at: @clicked_at
    )
    unique_before = @tracked_link.reload.unique_clicks

    RecordClickJob.perform_now(
      tracked_link_id: @tracked_link.id,
      ip_address: "10.0.0.50",
      clicked_at: @clicked_at
    )
    assert_equal unique_before, @tracked_link.reload.unique_clicks
  end

  test "hashes IP address" do
    RecordClickJob.perform_now(
      tracked_link_id: @tracked_link.id,
      ip_address: "192.168.1.1",
      clicked_at: @clicked_at
    )

    click = Click.last
    assert click.ip_hash.present?
    assert_not_equal "192.168.1.1", click.ip_hash
    assert_equal 16, click.ip_hash.length
  end

  test "handles missing tracked link gracefully" do
    assert_nothing_raised do
      RecordClickJob.perform_now(
        tracked_link_id: 0,
        ip_address: "10.0.0.1",
        clicked_at: @clicked_at
      )
    end
  end

  test "sets subscriber when subscriber_id provided" do
    subscriber = subscribers(:one)
    RecordClickJob.perform_now(
      tracked_link_id: @tracked_link.id,
      subscriber_id: subscriber.id,
      ip_address: "10.0.0.200",
      clicked_at: @clicked_at
    )

    click = Click.last
    assert_equal subscriber, click.subscriber
  end

  test "increments newsletter issue counters" do
    issue = @tracked_link.newsletter_issue
    before_count = issue.total_clicks

    RecordClickJob.perform_now(
      tracked_link_id: @tracked_link.id,
      ip_address: "10.0.0.201",
      clicked_at: @clicked_at
    )

    assert_equal before_count + 1, issue.reload.total_clicks
  end
end
