# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_02_22_122912) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "articles", force: :cascade do |t|
    t.bigint "blog_id", null: false
    t.datetime "created_at", null: false
    t.integer "featured_in_issue"
    t.boolean "processed", default: false
    t.datetime "published_at"
    t.text "summary"
    t.text "tags", default: [], array: true
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.string "url", null: false
    t.index ["blog_id", "published_at"], name: "index_articles_on_blog_id_and_published_at"
    t.index ["blog_id", "url"], name: "index_articles_on_blog_id_and_url", unique: true
    t.index ["blog_id"], name: "index_articles_on_blog_id"
    t.index ["featured_in_issue"], name: "index_articles_on_featured_in_issue"
    t.index ["processed"], name: "index_articles_on_processed"
    t.index ["published_at"], name: "index_articles_on_published_at"
    t.index ["url"], name: "index_articles_on_url", unique: true
  end

  create_table "blogs", force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.text "description"
    t.datetime "imported_at"
    t.datetime "last_synced_at"
    t.string "name", null: false
    t.string "rss_url", null: false
    t.text "tags", default: [], array: true
    t.string "twitter"
    t.datetime "updated_at", null: false
    t.string "url", null: false
    t.index ["active"], name: "index_blogs_on_active"
    t.index ["rss_url"], name: "index_blogs_on_rss_url", unique: true
    t.index ["url"], name: "index_blogs_on_url", unique: true
  end

  create_table "clicks", force: :cascade do |t|
    t.datetime "clicked_at", null: false
    t.datetime "created_at", null: false
    t.string "device_type"
    t.string "ip_hash"
    t.bigint "subscriber_id"
    t.bigint "tracked_link_id", null: false
    t.boolean "unique_click", default: false
    t.datetime "updated_at", null: false
    t.string "user_agent"
    t.index ["clicked_at"], name: "index_clicks_on_clicked_at"
    t.index ["subscriber_id"], name: "index_clicks_on_subscriber_id"
    t.index ["tracked_link_id", "ip_hash"], name: "index_clicks_on_tracked_link_id_and_ip_hash"
    t.index ["tracked_link_id"], name: "index_clicks_on_tracked_link_id"
  end

  create_table "github_repos", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.integer "featured_in_issue"
    t.datetime "first_seen_at"
    t.integer "forks", default: 0
    t.string "full_name", null: false
    t.string "language"
    t.datetime "last_synced_at"
    t.string "name", null: false
    t.string "owner_avatar_url"
    t.string "owner_name"
    t.boolean "processed", default: false
    t.datetime "repo_created_at"
    t.datetime "repo_pushed_at"
    t.integer "stars", default: 0
    t.text "topics", default: [], array: true
    t.datetime "updated_at", null: false
    t.string "url", null: false
    t.index ["featured_in_issue"], name: "index_github_repos_on_featured_in_issue"
    t.index ["full_name"], name: "index_github_repos_on_full_name", unique: true
    t.index ["processed"], name: "index_github_repos_on_processed"
    t.index ["repo_pushed_at"], name: "index_github_repos_on_repo_pushed_at"
    t.index ["stars"], name: "index_github_repos_on_stars"
  end

  create_table "newsletter_issues", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "issue_number", null: false
    t.datetime "sent_at"
    t.string "subject", null: false
    t.integer "subscriber_count", default: 0
    t.integer "total_clicks", default: 0
    t.integer "total_unique_clicks", default: 0
    t.datetime "updated_at", null: false
    t.index ["issue_number"], name: "index_newsletter_issues_on_issue_number", unique: true
    t.index ["sent_at"], name: "index_newsletter_issues_on_sent_at"
  end

  create_table "newsletter_items", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.bigint "linkable_id"
    t.string "linkable_type"
    t.bigint "newsletter_section_id", null: false
    t.integer "position", default: 0, null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.string "url", null: false
    t.index ["linkable_type", "linkable_id"], name: "index_newsletter_items_on_linkable_type_and_linkable_id"
    t.index ["newsletter_section_id", "position"], name: "index_newsletter_items_on_newsletter_section_id_and_position"
    t.index ["newsletter_section_id"], name: "index_newsletter_items_on_newsletter_section_id"
  end

  create_table "newsletter_sections", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "newsletter_issue_id", null: false
    t.integer "position", default: 0, null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.index ["newsletter_issue_id", "position"], name: "index_newsletter_sections_on_newsletter_issue_id_and_position"
    t.index ["newsletter_issue_id"], name: "index_newsletter_sections_on_newsletter_issue_id"
  end

  create_table "reddit_posts", force: :cascade do |t|
    t.string "author"
    t.datetime "created_at", null: false
    t.string "external_url"
    t.integer "featured_in_issue"
    t.datetime "first_seen_at"
    t.datetime "last_synced_at"
    t.integer "num_comments", default: 0
    t.datetime "posted_at"
    t.boolean "processed", default: false
    t.string "reddit_id", null: false
    t.integer "score", default: 0
    t.string "subreddit", null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.string "url", null: false
    t.index ["featured_in_issue"], name: "index_reddit_posts_on_featured_in_issue"
    t.index ["posted_at"], name: "index_reddit_posts_on_posted_at"
    t.index ["processed"], name: "index_reddit_posts_on_processed"
    t.index ["reddit_id"], name: "index_reddit_posts_on_reddit_id", unique: true
    t.index ["score"], name: "index_reddit_posts_on_score"
    t.index ["subreddit"], name: "index_reddit_posts_on_subreddit"
  end

  create_table "ruby_gems", force: :cascade do |t|
    t.string "activity_type", null: false
    t.string "authors"
    t.datetime "created_at", null: false
    t.integer "downloads", default: 0
    t.integer "featured_in_issue"
    t.datetime "first_seen_at"
    t.string "homepage_url"
    t.text "info"
    t.datetime "last_synced_at"
    t.text "licenses", default: [], array: true
    t.string "name", null: false
    t.boolean "processed", default: false
    t.string "project_url", null: false
    t.string "source_code_url"
    t.datetime "updated_at", null: false
    t.string "version", null: false
    t.datetime "version_created_at"
    t.index ["activity_type"], name: "index_ruby_gems_on_activity_type"
    t.index ["downloads"], name: "index_ruby_gems_on_downloads"
    t.index ["featured_in_issue"], name: "index_ruby_gems_on_featured_in_issue"
    t.index ["name"], name: "index_ruby_gems_on_name", unique: true
    t.index ["processed"], name: "index_ruby_gems_on_processed"
    t.index ["version_created_at"], name: "index_ruby_gems_on_version_created_at"
  end

  create_table "subscribers", force: :cascade do |t|
    t.boolean "confirmed", default: false
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.datetime "subscribed_at"
    t.datetime "unsubscribed_at"
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_subscribers_on_email", unique: true
  end

  create_table "tracked_links", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "destination_url", null: false
    t.string "token", null: false
    t.integer "total_clicks", default: 0
    t.bigint "trackable_id"
    t.string "trackable_type"
    t.integer "unique_clicks", default: 0
    t.datetime "updated_at", null: false
    t.index ["token"], name: "index_tracked_links_on_token", unique: true
    t.index ["trackable_type", "trackable_id"], name: "index_tracked_links_on_trackable_type_and_trackable_id"
  end

  add_foreign_key "articles", "blogs"
  add_foreign_key "clicks", "subscribers"
  add_foreign_key "clicks", "tracked_links"
  add_foreign_key "newsletter_items", "newsletter_sections"
  add_foreign_key "newsletter_sections", "newsletter_issues"
end
