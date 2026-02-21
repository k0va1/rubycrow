require "test_helper"
require "sidekiq/resend_rate_limiter"

class Sidekiq::ResendRateLimiterTest < ActiveSupport::TestCase
  setup do
    @limiter = Sidekiq::ResendRateLimiter.new
  end

  test "identifies SubscriberMailer jobs as mailer jobs" do
    subscriber = subscribers(:inactive)
    SubscriberMailer.confirmation(subscriber: subscriber).deliver_later

    job = enqueued_jobs.last
    payload = {"wrapped" => job["job_class"], "args" => job}

    assert_equal "ActionMailer::MailDeliveryJob", payload["wrapped"]
  end

  test "allows first 2 mailer deliveries per second" do
    subscriber = subscribers(:inactive)
    sent = 0

    with_clean_window do
      2.times do
        @limiter.call(nil, real_mailer_payload(subscriber), "critical") { sent += 1 }
      end
    end

    assert_equal 2, sent
  end

  test "throttles 3rd mailer delivery in the same second" do
    subscriber = subscribers(:inactive)
    payload = real_mailer_payload(subscriber)

    with_clean_window do
      2.times { @limiter.call(nil, payload, "critical") { } }

      slept = false
      @limiter.stub(:sleep, ->(_) {
        slept = true
        flush_current_key
      }) do
        @limiter.call(nil, payload, "critical") { }
      end

      assert slept
    end
  end

  test "resumes delivery after rate limit window passes" do
    subscriber = subscribers(:inactive)
    payload = real_mailer_payload(subscriber)
    delivery_times = []

    flush_current_key

    2.times do
      @limiter.call(nil, payload, "critical") { delivery_times << Time.now }
    end

    @limiter.call(nil, payload, "critical") { delivery_times << Time.now }

    assert_equal 3, delivery_times.size
    gap = delivery_times.last - delivery_times.first
    assert gap >= 0.5, "Expected >= 0.5s gap for 3rd delivery, got #{gap}s"
  end

  test "does not throttle non-mailer jobs" do
    subscriber = subscribers(:inactive)
    payload = real_mailer_payload(subscriber)

    with_clean_window do
      2.times { @limiter.call(nil, payload, "critical") { } }

      slept = false
      @limiter.stub(:sleep, ->(_) { slept = true }) do
        @limiter.call(nil, {"wrapped" => "ParseRssFeedJob", "args" => []}, "default") { }
      end

      refute slept
    end
  end

  test "rate limit counter increments in redis" do
    subscriber = subscribers(:inactive)
    payload = real_mailer_payload(subscriber)

    with_clean_window do |key|
      @limiter.call(nil, payload, "critical") { }
      assert_equal 1, Sidekiq.redis { |conn| conn.call("GET", key).to_i }

      @limiter.call(nil, payload, "critical") { }
      assert_equal 2, Sidekiq.redis { |conn| conn.call("GET", key).to_i }
    end
  end

  test "redis key has short ttl" do
    subscriber = subscribers(:inactive)

    with_clean_window do |key|
      @limiter.call(nil, real_mailer_payload(subscriber), "critical") { }

      ttl = Sidekiq.redis { |conn| conn.call("TTL", key) }
      assert_equal 1, ttl
    end
  end

  private

  def real_mailer_payload(subscriber)
    SubscriberMailer.confirmation(subscriber: subscriber).deliver_later

    job = enqueued_jobs.last
    {"wrapped" => job["job_class"], "args" => [job["arguments"]]}
  end

  def with_clean_window
    travel_to Time.at(Time.now.to_i + rand(1_000_000)) do
      key = "resend:ratelimit:#{Time.now.to_i}"
      Sidekiq.redis { |conn| conn.call("DEL", key) }
      yield key
    end
  end

  def flush_current_key
    key = "resend:ratelimit:#{Time.now.to_i}"
    Sidekiq.redis { |conn| conn.call("DEL", key) }
  end
end
