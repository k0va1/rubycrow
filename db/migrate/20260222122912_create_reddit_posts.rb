class CreateRedditPosts < ActiveRecord::Migration[8.1]
  def change
    create_table :reddit_posts do |t|
      t.string :reddit_id, null: false
      t.string :title, null: false
      t.string :url, null: false
      t.string :external_url
      t.integer :score, default: 0
      t.string :author
      t.string :subreddit, null: false
      t.integer :num_comments, default: 0
      t.boolean :processed, default: false
      t.integer :featured_in_issue
      t.datetime :first_seen_at
      t.datetime :last_synced_at
      t.datetime :posted_at

      t.timestamps
    end

    add_index :reddit_posts, :reddit_id, unique: true
    add_index :reddit_posts, :subreddit
    add_index :reddit_posts, :score
    add_index :reddit_posts, :processed
    add_index :reddit_posts, :featured_in_issue
    add_index :reddit_posts, :posted_at
  end
end
