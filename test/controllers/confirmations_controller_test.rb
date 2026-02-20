require "test_helper"

class ConfirmationsControllerTest < ActionDispatch::IntegrationTest
  test "valid token confirms subscriber" do
    subscriber = subscribers(:inactive)
    signed_id = subscriber.signed_confirmation_id

    get confirm_subscription_path(signed_id: signed_id)

    assert_response :success
    assert_includes response.body, "You're confirmed!"
    assert subscriber.reload.confirmed
  end

  test "expired token redirects to root" do
    subscriber = subscribers(:inactive)

    travel 25.hours do
      signed_id = subscriber.signed_id(purpose: :confirmation, expires_in: 0.seconds)

      get confirm_subscription_path(signed_id: signed_id)

      assert_redirected_to root_path
      assert_not subscriber.reload.confirmed
    end
  end

  test "invalid token redirects to root" do
    get confirm_subscription_path(signed_id: "invalid-token")

    assert_redirected_to root_path
  end

  test "already confirmed subscriber stays confirmed" do
    subscriber = subscribers(:one)
    signed_id = subscriber.signed_confirmation_id

    get confirm_subscription_path(signed_id: signed_id)

    assert_response :success
    assert subscriber.reload.confirmed
  end
end
