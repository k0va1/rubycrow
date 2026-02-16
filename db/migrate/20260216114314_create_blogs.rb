class CreateBlogs < ActiveRecord::Migration[8.1]
  def change
    create_table :blogs do |t|
      t.string :name, null: false
      t.string :url, null: false
      t.string :rss_url, null: false
      t.text :description
      t.text :tags, array: true, default: []
      t.string :twitter
      t.string :github_pr_url
      t.boolean :active, default: true, null: false
      t.datetime :last_synced_at

      t.timestamps
    end

    add_index :blogs, :url, unique: true
    add_index :blogs, :rss_url, unique: true
    add_index :blogs, :active
  end
end
