require "test_helper"

class UnsubscribesControllerTest < ActionDispatch::IntegrationTest
  test "unsubscribes a subscriber with valid signed id" do
    subscriber = subscribers(:one)
    assert_nil subscriber.unsubscribed_at

    get unsubscribe_path(signed_id: subscriber.signed_unsubscribe_id)

    assert_response :ok
    assert_includes response.body, "You've been unsubscribed"
    assert_not_nil subscriber.reload.unsubscribed_at
  end

  test "redirects to root with invalid signed id" do
    get unsubscribe_path(signed_id: "invalid-token")

    assert_redirected_to root_path
  end

  test "unsubscribe is idempotent" do
    subscriber = subscribers(:one)

    get unsubscribe_path(signed_id: subscriber.signed_unsubscribe_id)
    first_unsubscribed_at = subscriber.reload.unsubscribed_at

    travel 1.hour do
      get unsubscribe_path(signed_id: subscriber.signed_unsubscribe_id)
    end

    assert_not_equal first_unsubscribed_at, subscriber.reload.unsubscribed_at
  end
end
