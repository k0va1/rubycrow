class CreateNewsletterSections < ActiveRecord::Migration[8.1]
  def change
    create_table :newsletter_sections do |t|
      t.references :newsletter_issue, null: false, foreign_key: true
      t.string :title, null: false
      t.integer :position, null: false, default: 0

      t.timestamps
    end

    add_index :newsletter_sections, [:newsletter_issue_id, :position]
  end
end
