class CreateNewsletterItems < ActiveRecord::Migration[8.1]
  def change
    create_table :newsletter_items do |t|
      t.references :newsletter_section, null: false, foreign_key: true
      t.string :title, null: false
      t.text :description
      t.string :url, null: false
      t.integer :position, null: false, default: 0

      t.timestamps
    end

    add_index :newsletter_items, [:newsletter_section_id, :position]
  end
end
