class CreateTrackedLinks < ActiveRecord::Migration[8.1]
  def change
    create_table :tracked_links do |t|
      t.string :token, null: false
      t.references :newsletter_issue, null: false, foreign_key: true
      t.references :article, foreign_key: true
      t.string :destination_url, null: false
      t.integer :position_in_newsletter
      t.string :section
      t.integer :total_clicks, default: 0
      t.integer :unique_clicks, default: 0
      t.timestamps
    end

    add_index :tracked_links, :token, unique: true
    add_index :tracked_links, [:newsletter_issue_id, :destination_url], name: "index_tracked_links_on_issue_and_url"
  end
end
