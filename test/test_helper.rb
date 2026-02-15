ENV["RAILS_ENV"] ||= "test"

if ENV["COVERAGE"]
  require "simplecov"
  SimpleCov.start "rails"
end

require_relative "../config/environment"
require "rails/test_help"
require "minitest/autorun"
require "minitest/mock"
require "webmock/minitest"
require "mocha/minitest"
require_relative "support/openapi"

WebMock.disable_net_connect!(allow_localhost: true)

Sidekiq.logger.level = Logger::ERROR

class ActiveSupport::TestCase
  include ActiveJob::TestHelper

  fixtures :all

  parallelize(workers: :number_of_processors)

  setup do
    ActiveStorage::Current.url_options = {host: "http://localhost:6000"}
    ActiveJob::Base.queue_adapter = :test
    clear_uniqueness_locks
  end

  def clear_uniqueness_locks
    redis_url = Rails.application.credentials.dig(:redis_url)
    return unless redis_url

    redis = Redis.new(url: redis_url)
    keys = redis.keys("activejob_uniqueness:*")
    redis.del(*keys) if keys.any?
  rescue => e
    Rails.logger.debug { "Could not clear uniqueness locks: #{e.message}" }
  end
end

class ActionDispatch::IntegrationTest
  include ActiveJob::TestHelper

  fixtures :all

  self.use_transactional_tests = true

  setup do
    ActiveStorage::Current.url_options = {host: "http://localhost:6000"}
    ActiveJob::Base.queue_adapter = :test
  end

  def auth_headers
    @_auth_session ||= setup_auth_session
    {"Authorization" => "Bearer #{@_auth_session.token}"}
  end

  def setup_auth_session
    Current.session = sessions(:default)
    sessions(:default)
  end

  def current_user
    Current.user
  end

  def json_response
    JSON.parse(response.body)
  end
end

class ActionDispatch::SystemTestCase
  fixtures :all

  browser_options = Selenium::WebDriver::Chrome::Options.new.tap do |opts|
    opts.add_argument("--window-size=1400,1400")
    opts.add_argument("--no-sandbox")
    opts.add_argument("--disable-gpu")
    opts.add_argument("--disable-dev-shm-usage")
    opts.add_argument("--disable-extensions")
    opts.add_argument("--disable-renderer-backgrounding")
    opts.add_argument("--disable-backgrounding-occluded-windows")
    opts.add_argument("--deny-permission-prompts")
    opts.add_argument("--enable-automation")
  end

  Capybara.server = :puma, {Silent: true}

  Capybara.register_driver :chrome_headless do |app|
    browser_options.add_argument("--headless")
    Capybara::Selenium::Driver.new(app, browser: :chrome, options: browser_options)
  end

  Capybara.register_driver :chrome do |app|
    Capybara::Selenium::Driver.new(app, browser: :chrome, options: browser_options)
  end

  if ENV["SYSTEM_TESTS_BROWSER"]
    driven_by :chrome, screen_size: [1400, 1400]
  else
    driven_by :chrome_headless, screen_size: [1400, 1400]
  end

  setup do
    ActiveStorage::Current.url_options = {host: "http://localhost:6000"}
  end

  def sign_in(user)
    visit new_session_path
    fill_in "user[email]", with: user.email
    fill_in "user[password]", with: "password"
    click_button "Log in"
    assert_text "Dashboard"
  end
end
