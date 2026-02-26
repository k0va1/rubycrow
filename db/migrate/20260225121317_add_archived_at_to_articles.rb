class AddArchivedAtToArticles < ActiveRecord::Migration[8.1]
  def change
    add_column :articles, :archived_at, :datetime
  end
end
