require "test_helper"

class SubscribersControllerTest < ActionDispatch::IntegrationTest
  setup do
    SubscribersController.cache_store.clear
  end

  test "rate limits excessive subscribe requests" do
    6.times do |i|
      post subscribers_path, params: {email: "user#{i}@example.com", form_id: "subscribe-form-hero"}, as: :turbo_stream
    end

    assert_response :too_many_requests
    assert_includes response.body, "Too many attempts"
    assert_includes response.body, 'target="subscribe-form-hero"'
  end

  test "rate limit defaults form_id when not provided" do
    6.times do |i|
      post subscribers_path, params: {email: "user#{i}@example.com"}, as: :turbo_stream
    end

    assert_response :too_many_requests
    assert_includes response.body, 'target="subscribe-form"'
  end

  test "creates subscriber with valid email" do
    assert_difference "Subscriber.count", 1 do
      post subscribers_path, params: {email: "test@example.com", form_id: "subscribe-form-hero"}, as: :turbo_stream
    end

    assert_response :success
    assert_equal "text/vnd.turbo-stream.html", response.media_type

    subscriber = Subscriber.last
    assert_equal "test@example.com", subscriber.email
    assert_not_nil subscriber.subscribed_at
    assert_not subscriber.confirmed
  end

  test "enqueues confirmation email on successful signup" do
    assert_enqueued_emails 1 do
      post subscribers_path, params: {email: "new@example.com", form_id: "subscribe-form-hero"}, as: :turbo_stream
    end
  end

  test "does not enqueue confirmation email on failed signup" do
    Subscriber.create!(email: "dupe@example.com")

    assert_no_enqueued_emails do
      post subscribers_path, params: {email: "dupe@example.com", form_id: "subscribe-form-hero"}, as: :turbo_stream
    end
  end

  test "returns success turbo stream replacing the correct form" do
    post subscribers_path, params: {email: "test@example.com", form_id: "subscribe-form-hero"}, as: :turbo_stream

    assert_response :success
    assert_includes response.body, 'turbo-stream action="replace" target="subscribe-form-hero"'
    assert_includes response.body, "Welcome to the flock."
  end

  test "rejects invalid email format" do
    assert_no_difference "Subscriber.count" do
      post subscribers_path, params: {email: "not-an-email", form_id: "subscribe-form-hero"}, as: :turbo_stream
    end

    assert_response :unprocessable_content
    assert_includes response.body, 'turbo-stream action="replace" target="subscribe-form-hero"'
    assert_includes response.body, "doesn&#39;t look valid"
  end

  test "rejects duplicate email" do
    Subscriber.create!(email: "dupe@example.com")

    assert_no_difference "Subscriber.count" do
      post subscribers_path, params: {email: "dupe@example.com", form_id: "subscribe-form-footer"}, as: :turbo_stream
    end

    assert_response :unprocessable_content
    assert_includes response.body, 'target="subscribe-form-footer"'
    assert_includes response.body, "already subscribed"
  end

  test "rejects duplicate email case-insensitively" do
    Subscriber.create!(email: "user@example.com")

    assert_no_difference "Subscriber.count" do
      post subscribers_path, params: {email: "USER@example.com", form_id: "subscribe-form-hero"}, as: :turbo_stream
    end

    assert_response :unprocessable_content
    assert_includes response.body, "already subscribed"
  end

  test "rejects blank email" do
    assert_no_difference "Subscriber.count" do
      post subscribers_path, params: {email: "", form_id: "subscribe-form-hero"}, as: :turbo_stream
    end

    assert_response :unprocessable_content
    assert_includes response.body, "turbo-stream"
  end

  test "defaults form_id when not provided" do
    post subscribers_path, params: {email: "test@example.com"}, as: :turbo_stream

    assert_response :success
    assert_includes response.body, 'target="subscribe-form"'
  end
end
