class CreateArticles < ActiveRecord::Migration[8.1]
  def change
    create_table :articles do |t|
      t.references :blog, null: false, foreign_key: true
      t.string :title, null: false
      t.string :url, null: false
      t.datetime :published_at
      t.text :summary
      t.text :content_snippet
      t.boolean :processed, default: false
      t.integer :featured_in_issue

      t.timestamps
    end

    add_index :articles, :url, unique: true
    add_index :articles, :published_at
    add_index :articles, :processed
    add_index :articles, :featured_in_issue
    add_index :articles, [:blog_id, :published_at]
  end
end
