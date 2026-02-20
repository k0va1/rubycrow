class MakeTrackedLinkPolymorphic < ActiveRecord::Migration[8.1]
  def up
    safety_assured do
      add_column :tracked_links, :trackable_type, :string
      add_column :tracked_links, :trackable_id, :bigint

      execute <<~SQL
        UPDATE tracked_links
        SET trackable_type = 'NewsletterItem', trackable_id = newsletter_item_id
        WHERE newsletter_item_id IS NOT NULL
      SQL

      add_index :tracked_links, [:trackable_type, :trackable_id]

      remove_foreign_key :tracked_links, :newsletter_issues
      remove_foreign_key :tracked_links, :articles
      remove_foreign_key :tracked_links, :newsletter_items

      remove_index :tracked_links, :article_id
      remove_index :tracked_links, [:newsletter_issue_id, :destination_url]
      remove_index :tracked_links, :newsletter_issue_id
      remove_index :tracked_links, :newsletter_item_id

      remove_column :tracked_links, :newsletter_issue_id
      remove_column :tracked_links, :article_id
      remove_column :tracked_links, :newsletter_item_id
    end
  end

  def down
    safety_assured do
      add_column :tracked_links, :newsletter_issue_id, :bigint
      add_column :tracked_links, :article_id, :bigint
      add_column :tracked_links, :newsletter_item_id, :bigint

      execute <<~SQL
        UPDATE tracked_links
        SET newsletter_item_id = trackable_id
        WHERE trackable_type = 'NewsletterItem'
      SQL

      execute <<~SQL
        UPDATE tracked_links
        SET newsletter_issue_id = newsletter_items.newsletter_section_id
        FROM newsletter_items
        JOIN newsletter_sections ON newsletter_sections.id = newsletter_items.newsletter_section_id
        WHERE tracked_links.newsletter_item_id = newsletter_items.id
          AND tracked_links.newsletter_issue_id IS NULL
      SQL

      execute <<~SQL
        UPDATE tracked_links
        SET newsletter_issue_id = newsletter_sections.newsletter_issue_id
        FROM newsletter_items
        JOIN newsletter_sections ON newsletter_sections.id = newsletter_items.newsletter_section_id
        WHERE tracked_links.newsletter_item_id = newsletter_items.id
      SQL

      add_index :tracked_links, :article_id
      add_index :tracked_links, [:newsletter_issue_id, :destination_url], name: "index_tracked_links_on_issue_and_url"
      add_index :tracked_links, :newsletter_issue_id
      add_index :tracked_links, :newsletter_item_id

      add_foreign_key :tracked_links, :newsletter_issues
      add_foreign_key :tracked_links, :articles
      add_foreign_key :tracked_links, :newsletter_items

      remove_index :tracked_links, [:trackable_type, :trackable_id]
      remove_column :tracked_links, :trackable_type
      remove_column :tracked_links, :trackable_id
    end
  end
end
