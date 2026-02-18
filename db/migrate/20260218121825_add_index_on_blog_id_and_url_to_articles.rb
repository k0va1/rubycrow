class AddIndexOnBlogIdAndUrlToArticles < ActiveRecord::Migration[8.1]
  disable_ddl_transaction!

  def change
    add_index :articles, [:blog_id, :url], unique: true, algorithm: :concurrently
  end
end
