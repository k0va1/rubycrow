class CreateNewsletterIssues < ActiveRecord::Migration[8.1]
  def change
    create_table :newsletter_issues do |t|
      t.integer :issue_number, null: false
      t.string :subject, null: false
      t.datetime :sent_at
      t.integer :subscriber_count, default: 0
      t.integer :total_clicks, default: 0
      t.integer :total_unique_clicks, default: 0
      t.timestamps
    end

    add_index :newsletter_issues, :issue_number, unique: true
    add_index :newsletter_issues, :sent_at
  end
end
