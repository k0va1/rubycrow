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

ActiveRecord::Schema[8.1].define(version: 2026_02_16_114319) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "articles", force: :cascade do |t|
    t.bigint "blog_id", null: false
    t.text "content_snippet"
    t.datetime "created_at", null: false
    t.integer "featured_in_issue"
    t.boolean "processed", default: false
    t.datetime "published_at"
    t.text "summary"
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.string "url", null: false
    t.index ["blog_id", "published_at"], name: "index_articles_on_blog_id_and_published_at"
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
    t.string "github_pr_url"
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

  create_table "subscribers", force: :cascade do |t|
    t.boolean "confirmed", default: false
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.datetime "subscribed_at"
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_subscribers_on_email", unique: true
  end

  add_foreign_key "articles", "blogs"
end
