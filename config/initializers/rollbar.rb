Rollbar.configure do |config|
  config.access_token = Rails.application.credentials.dig(:rollbar, :access_token)
  config.enabled = Rails.env.production?
  config.environment = Rails.env
end
