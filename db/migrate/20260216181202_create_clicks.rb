class CreateClicks < ActiveRecord::Migration[8.1]
  def change
    create_table :clicks do |t|
      t.references :tracked_link, null: false, foreign_key: true
      t.references :subscriber, foreign_key: true
      t.datetime :clicked_at, null: false
      t.string :user_agent
      t.string :ip_hash
      t.string :device_type
      t.boolean :unique_click, default: false
      t.timestamps
    end

    add_index :clicks, :clicked_at
    add_index :clicks, [:tracked_link_id, :ip_hash]
  end
end
