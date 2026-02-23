source "https://rubygems.org"

ruby "4.0.1"

gem "bootsnap", require: false
gem "bundler-audit"
gem "pg", "~> 1.1"
gem "puma", "~> 7.2"
gem "rails", "~> 8.1"
gem "propshaft"
gem "stimulus-rails"
gem "turbo-rails"
gem "amazing_print"
gem "counter_culture", "~> 3.12"
gem "cssbundling-rails"
gem "jsbundling-rails"
gem "redis", "~> 5.4"
gem "sidekiq"
gem "sidekiq-scheduler"
gem "activejob-uniqueness", github: "kodehealth/activejob-uniqueness", branch: "main"
gem "rollbar"
gem "strong_migrations"
gem "pagy"
gem "feedjira"
gem "faraday"
gem "faraday-follow_redirects"
gem "resend"

gem "lightning_ui_kit"

group :development, :test do
  gem "brakeman"
  gem "debug"
  gem "standard"
  gem "standard-rails"
  gem "standard-performance"
end

group :development do
  gem "web-console"
  gem "colorize"
  gem "annotaterb"
  gem "rack-mini-profiler", require: false
end

group :test do
  gem "capybara"
  gem "simplecov", require: false
  gem "webmock"
end

gem "mocha", "~> 3.0", group: :test

gem "minitest-mock", "~> 5.27", group: :test

gem "selenium-webdriver", "~> 4.41", group: :test
