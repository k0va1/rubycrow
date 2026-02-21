module Sidekiq
  # Sidekiq server middleware that throttles email delivery to stay within
  # Resend's rate limit of 2 requests per second. Uses an atomic Lua script
  # in Redis to coordinate across all Sidekiq threads with per-second fixed
  # window buckets. Falls back to ActionMailer::MailDeliveryJob's
  # retry_on(Resend::Error::RateLimitExceededError) if throttling alone
  # isn't enough. Depends on Redis being available — if Redis is down,
  # the job fails and Sidekiq's retry mechanism handles it.
  class ResendRateLimiter
    MAX_PER_SECOND = 2

    ACQUIRE_SLOT = <<~LUA
      local key = KEYS[1]
      local limit = tonumber(ARGV[1])
      local current = tonumber(redis.call('GET', key) or '0')
      if current < limit then
        if current == 0 then
          redis.call('SET', key, 1, 'EX', 1)
        else
          redis.call('INCR', key)
        end
        return 1
      end
      return 0
    LUA

    def initialize
      @script_sha = nil
    end

    def call(job_instance, job_payload, queue)
      throttle if mailer_job?(job_payload)
      yield
    end

    private

    def mailer_job?(job_payload)
      job_payload["wrapped"] == "ActionMailer::MailDeliveryJob" ||
        job_payload["class"] == "ActionMailer::MailDeliveryJob"
    end

    def throttle
      loop do
        key = "resend:ratelimit:#{Time.now.to_i}"
        allowed = Sidekiq.redis { |conn| conn.call("EVALSHA", script_sha(conn), 1, key, MAX_PER_SECOND) }
        return if allowed == 1
        sleep(0.5)
      end
    end

    def script_sha(conn)
      @script_sha ||= conn.call("SCRIPT", "LOAD", ACQUIRE_SLOT)
    end
  end
end
