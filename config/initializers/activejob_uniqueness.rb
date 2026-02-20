ActiveJob::Uniqueness.configure do |config|
  config.redlock_servers = [ENV.fetch("REDIS_URL", Rails.application.credentials.dig(:redis_url))]

  if Rails.env.test?
    config.lock_ttl = 1.second
  end
end
