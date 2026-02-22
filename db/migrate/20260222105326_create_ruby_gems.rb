class CreateRubyGems < ActiveRecord::Migration[8.1]
  def change
    create_table :ruby_gems do |t|
      t.string :name, null: false
      t.string :version, null: false
      t.string :authors
      t.text :info
      t.text :licenses, array: true, default: []
      t.integer :downloads, default: 0
      t.string :project_url, null: false
      t.string :homepage_url
      t.string :source_code_url
      t.datetime :version_created_at
      t.string :activity_type, null: false
      t.boolean :processed, default: false
      t.integer :featured_in_issue
      t.datetime :first_seen_at
      t.datetime :last_synced_at

      t.timestamps
    end

    add_index :ruby_gems, :name, unique: true
    add_index :ruby_gems, :activity_type
    add_index :ruby_gems, :processed
    add_index :ruby_gems, :featured_in_issue
    add_index :ruby_gems, :version_created_at
    add_index :ruby_gems, :downloads
  end
end
