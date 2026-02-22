class CreateGithubRepos < ActiveRecord::Migration[8.1]
  def change
    create_table :github_repos do |t|
      t.string :full_name, null: false
      t.string :name, null: false
      t.text :description
      t.string :url, null: false
      t.integer :stars, default: 0
      t.integer :forks, default: 0
      t.string :language
      t.string :owner_name
      t.string :owner_avatar_url
      t.text :topics, array: true, default: []
      t.boolean :processed, default: false
      t.integer :featured_in_issue
      t.datetime :first_seen_at
      t.datetime :last_synced_at
      t.datetime :repo_created_at
      t.datetime :repo_pushed_at

      t.timestamps
    end

    add_index :github_repos, :full_name, unique: true
    add_index :github_repos, :stars
    add_index :github_repos, :processed
    add_index :github_repos, :featured_in_issue
    add_index :github_repos, :repo_pushed_at
  end
end
