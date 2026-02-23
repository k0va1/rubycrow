require "test_helper"

class GithubRepoTest < ActiveSupport::TestCase
  test "valid github repo" do
    repo = GithubRepo.new(full_name: "test/repo", name: "repo", url: "https://github.com/test/repo")
    assert repo.valid?
  end

  test "requires full_name" do
    repo = GithubRepo.new(name: "repo", url: "https://github.com/test/repo")
    assert_not repo.valid?
    assert_includes repo.errors[:full_name], "can't be blank"
  end

  test "full_name must be unique" do
    repo = GithubRepo.new(full_name: github_repos(:rails_repo).full_name, name: "rails", url: "https://github.com/rails/rails2")
    assert_not repo.valid?
    assert_includes repo.errors[:full_name], "has already been taken"
  end

  test "requires name" do
    repo = GithubRepo.new(full_name: "test/repo", url: "https://github.com/test/repo")
    assert_not repo.valid?
    assert_includes repo.errors[:name], "can't be blank"
  end

  test "requires url" do
    repo = GithubRepo.new(full_name: "test/repo", name: "repo")
    assert_not repo.valid?
    assert_includes repo.errors[:url], "can't be blank"
  end

  test "by_push_date scope orders by repo_pushed_at desc" do
    repos = GithubRepo.by_push_date
    dates = repos.map(&:repo_pushed_at).compact
    assert dates.any?
    assert_equal dates, dates.sort.reverse
  end

  test "recent scope limits results" do
    assert_equal 2, GithubRepo.recent(2).count
  end

  test "unprocessed scope returns unprocessed repos" do
    unprocessed = GithubRepo.unprocessed
    assert unprocessed.any?
    unprocessed.each do |repo|
      assert_not repo.processed?
    end
  end

  test "featured scope returns repos with featured_in_issue" do
    featured = GithubRepo.featured
    assert_includes featured, github_repos(:featured_repo)
    assert_not_includes featured, github_repos(:rails_repo)
  end

  test "search_by_name finds matching repos" do
    results = GithubRepo.search_by_name("rails")
    assert_includes results, github_repos(:rails_repo)
    assert_not_includes results, github_repos(:sidekiq_repo)
  end

  test "popular scope orders by stars desc" do
    popular = GithubRepo.popular
    stars = popular.map(&:stars)
    assert_equal stars, stars.sort.reverse
  end

  test "sync_from_api! upserts repos from GitHub API" do
    api_response = {
      "total_count" => 1,
      "items" => [
        {
          "full_name" => "faker-ruby/faker",
          "name" => "faker",
          "description" => "A library for generating fake data",
          "html_url" => "https://github.com/faker-ruby/faker",
          "stargazers_count" => 11000,
          "forks_count" => 3200,
          "language" => "Ruby",
          "owner" => {"login" => "faker-ruby", "avatar_url" => "https://avatars.githubusercontent.com/u/123"},
          "topics" => ["ruby", "faker"],
          "created_at" => "2015-01-01T00:00:00Z",
          "pushed_at" => "2025-06-01T00:00:00Z"
        }
      ]
    }.to_json

    stub_request(:get, "https://api.github.com/search/repositories")
      .with(query: hash_including("q" => /language:ruby/))
      .to_return(status: 200, body: api_response)

    assert_difference "GithubRepo.count", 1 do
      GithubRepo.sync_from_api!
    end

    repo = GithubRepo.find_by(full_name: "faker-ruby/faker")
    assert_equal "faker", repo.name
    assert_equal 11000, repo.stars
    assert_not_nil repo.first_seen_at
  end

  test "sync_from_api! returns empty array on api error" do
    stub_request(:get, "https://api.github.com/search/repositories")
      .with(query: hash_including("q" => /language:ruby/))
      .to_return(status: 500)

    result = GithubRepo.sync_from_api!
    assert_equal [], result
  end

  test "sync_from_api! handles json parse error" do
    stub_request(:get, "https://api.github.com/search/repositories")
      .with(query: hash_including("q" => /language:ruby/))
      .to_return(status: 200, body: "invalid json")

    result = GithubRepo.sync_from_api!
    assert_equal [], result
  end

  test "sync_from_api! preserves first_seen_at on re-sync" do
    api_response = {
      "total_count" => 1,
      "items" => [
        {
          "full_name" => github_repos(:rails_repo).full_name,
          "name" => "rails",
          "description" => "Updated description",
          "html_url" => "https://github.com/rails/rails",
          "stargazers_count" => 57000,
          "forks_count" => 21500,
          "language" => "Ruby",
          "owner" => {"login" => "rails", "avatar_url" => "https://avatars.githubusercontent.com/u/4223"},
          "topics" => ["ruby", "rails"],
          "created_at" => "2010-01-01T00:00:00Z",
          "pushed_at" => "2025-06-01T00:00:00Z"
        }
      ]
    }.to_json

    stub_request(:get, "https://api.github.com/search/repositories")
      .with(query: hash_including("q" => /language:ruby/))
      .to_return(status: 200, body: api_response)

    original_first_seen = github_repos(:rails_repo).first_seen_at

    assert_no_difference "GithubRepo.count" do
      GithubRepo.sync_from_api!
    end

    github_repos(:rails_repo).reload
    assert_equal original_first_seen, github_repos(:rails_repo).first_seen_at
    assert_equal 57000, github_repos(:rails_repo).stars
  end
end
