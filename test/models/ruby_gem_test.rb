require "test_helper"

class RubyGemTest < ActiveSupport::TestCase
  test "valid ruby gem" do
    gem = RubyGem.new(name: "test_gem", version: "1.0.0", project_url: "https://rubygems.org/gems/test_gem", activity_type: "new")
    assert gem.valid?
  end

  test "requires name" do
    gem = RubyGem.new(version: "1.0.0", project_url: "https://rubygems.org/gems/test", activity_type: "new")
    assert_not gem.valid?
    assert_includes gem.errors[:name], "can't be blank"
  end

  test "name must be unique" do
    gem = RubyGem.new(name: ruby_gems(:rack_updated).name, version: "1.0.0", project_url: "https://rubygems.org/gems/rack2", activity_type: "new")
    assert_not gem.valid?
    assert_includes gem.errors[:name], "has already been taken"
  end

  test "requires version" do
    gem = RubyGem.new(name: "test_gem", project_url: "https://rubygems.org/gems/test", activity_type: "new")
    assert_not gem.valid?
    assert_includes gem.errors[:version], "can't be blank"
  end

  test "requires project_url" do
    gem = RubyGem.new(name: "test_gem", version: "1.0.0", activity_type: "new")
    assert_not gem.valid?
    assert_includes gem.errors[:project_url], "can't be blank"
  end

  test "requires valid activity_type" do
    gem = RubyGem.new(name: "test_gem", version: "1.0.0", project_url: "https://rubygems.org/gems/test", activity_type: "invalid")
    assert_not gem.valid?
    assert_includes gem.errors[:activity_type], "is not included in the list"
  end

  test "activity_type accepts new" do
    gem = RubyGem.new(name: "test_gem", version: "1.0.0", project_url: "https://rubygems.org/gems/test", activity_type: "new")
    assert gem.valid?
  end

  test "activity_type accepts updated" do
    gem = RubyGem.new(name: "test_gem", version: "1.0.0", project_url: "https://rubygems.org/gems/test", activity_type: "updated")
    assert gem.valid?
  end

  test "default scope orders by version_created_at desc" do
    gems = RubyGem.all
    dates = gems.map(&:version_created_at).compact
    assert_equal dates, dates.sort.reverse
  end

  test "recent scope limits results" do
    assert RubyGem.recent(2).count <= 2
  end

  test "unprocessed scope returns unprocessed gems" do
    RubyGem.unprocessed.each do |gem|
      assert_not gem.processed?
    end
  end

  test "newly_created scope returns new gems" do
    RubyGem.newly_created.each do |gem|
      assert_equal "new", gem.activity_type
    end
  end

  test "recently_updated scope returns updated gems" do
    RubyGem.recently_updated.each do |gem|
      assert_equal "updated", gem.activity_type
    end
  end

  test "featured scope returns gems with featured_in_issue" do
    featured = RubyGem.featured
    assert_includes featured, ruby_gems(:featured_gem)
    assert_not_includes featured, ruby_gems(:rack_updated)
  end

  test "search_by_name finds matching gems" do
    results = RubyGem.search_by_name("rack")
    assert_includes results, ruby_gems(:rack_updated)
    assert_not_includes results, ruby_gems(:new_gem)
  end

  test "popular scope orders by downloads desc" do
    popular = RubyGem.popular
    downloads = popular.map(&:downloads)
    assert_equal downloads, downloads.sort.reverse
  end

  test "sync_from_api! upserts gems from both endpoints" do
    updated_response = [
      {
        "name" => "rails",
        "version" => "8.0.0",
        "authors" => "DHH",
        "info" => "Full-stack web framework",
        "licenses" => ["MIT"],
        "downloads" => 400000000,
        "project_uri" => "https://rubygems.org/gems/rails",
        "homepage_uri" => "https://rubyonrails.org",
        "source_code_uri" => "https://github.com/rails/rails",
        "version_created_at" => "2025-01-01T00:00:00.000Z"
      }
    ].to_json

    latest_response = [
      {
        "name" => "my_new_gem",
        "version" => "0.1.0",
        "authors" => "Author",
        "info" => "A brand new gem",
        "licenses" => ["MIT"],
        "downloads" => 10,
        "project_uri" => "https://rubygems.org/gems/my_new_gem",
        "homepage_uri" => nil,
        "source_code_uri" => nil,
        "version_created_at" => "2025-06-01T00:00:00.000Z"
      }
    ].to_json

    stub_request(:get, "https://rubygems.org/api/v1/activity/just_updated.json")
      .to_return(status: 200, body: updated_response)
    stub_request(:get, "https://rubygems.org/api/v1/activity/latest.json")
      .to_return(status: 200, body: latest_response)

    assert_difference "RubyGem.count", 2 do
      RubyGem.sync_from_api!
    end

    rails_gem = RubyGem.find_by(name: "rails")
    assert_equal "8.0.0", rails_gem.version
    assert_equal "updated", rails_gem.activity_type
    assert_not_nil rails_gem.first_seen_at

    new_gem = RubyGem.find_by(name: "my_new_gem")
    assert_equal "0.1.0", new_gem.version
    assert_equal "new", new_gem.activity_type
  end

  test "sync_from_api! updated gems take precedence over new gems with same name" do
    shared_gem = {
      "name" => "shared_gem",
      "version" => "1.0.0",
      "authors" => "Author",
      "info" => "Shared gem",
      "licenses" => ["MIT"],
      "downloads" => 100,
      "project_uri" => "https://rubygems.org/gems/shared_gem",
      "homepage_uri" => nil,
      "source_code_uri" => nil,
      "version_created_at" => "2025-06-01T00:00:00.000Z"
    }

    stub_request(:get, "https://rubygems.org/api/v1/activity/just_updated.json")
      .to_return(status: 200, body: [shared_gem].to_json)
    stub_request(:get, "https://rubygems.org/api/v1/activity/latest.json")
      .to_return(status: 200, body: [shared_gem].to_json)

    RubyGem.sync_from_api!

    gem = RubyGem.find_by(name: "shared_gem")
    assert_equal "updated", gem.activity_type
  end

  test "sync_from_api! returns empty array on api error" do
    stub_request(:get, "https://rubygems.org/api/v1/activity/just_updated.json")
      .to_return(status: 500)
    stub_request(:get, "https://rubygems.org/api/v1/activity/latest.json")
      .to_return(status: 200, body: "[]")

    result = RubyGem.sync_from_api!
    assert_equal [], result
  end

  test "sync_from_api! handles json parse error" do
    stub_request(:get, "https://rubygems.org/api/v1/activity/just_updated.json")
      .to_return(status: 200, body: "invalid json")
    stub_request(:get, "https://rubygems.org/api/v1/activity/latest.json")
      .to_return(status: 200, body: "[]")

    result = RubyGem.sync_from_api!
    assert_equal [], result
  end

  test "sync_from_api! preserves first_seen_at on re-sync" do
    stub_request(:get, "https://rubygems.org/api/v1/activity/just_updated.json")
      .to_return(status: 200, body: "[]")

    gem_data = {
      "name" => ruby_gems(:rack_updated).name,
      "version" => "3.2.0",
      "authors" => "New Author",
      "info" => "Updated info",
      "licenses" => ["MIT"],
      "downloads" => 600000000,
      "project_uri" => "https://rubygems.org/gems/rack",
      "homepage_uri" => "https://github.com/rack/rack",
      "source_code_uri" => "https://github.com/rack/rack",
      "version_created_at" => "2025-06-01T00:00:00.000Z"
    }

    stub_request(:get, "https://rubygems.org/api/v1/activity/latest.json")
      .to_return(status: 200, body: [gem_data].to_json)

    original_first_seen = ruby_gems(:rack_updated).first_seen_at

    assert_no_difference "RubyGem.count" do
      RubyGem.sync_from_api!
    end

    ruby_gems(:rack_updated).reload
    assert_equal original_first_seen, ruby_gems(:rack_updated).first_seen_at
    assert_equal "3.2.0", ruby_gems(:rack_updated).version
  end
end
