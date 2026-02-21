require "sidekiq/resend_rate_limiter"

Sidekiq.configure_server do |config|
  config.redis = {url: Rails.application.credentials.redis_url, reconnect_attempts: 10}

  config.server_middleware do |chain|
    chain.add Sidekiq::ResendRateLimiter
  end

  config.on(:startup) do
    schedule_file = Rails.root.join("config/scheduler/#{Rails.env}.yml")

    if File.exist?(schedule_file)
      Sidekiq.schedule = YAML.load_file(schedule_file)
      SidekiqScheduler::Scheduler.instance.reload_schedule!
    end
  end
end

Sidekiq.configure_client do |config|
  config.redis = {url: Rails.application.credentials.redis_url, reconnect_attempts: 3}
end
