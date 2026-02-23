class MakeNewsletterItemLinkable < ActiveRecord::Migration[8.1]
  def up
    safety_assured do
      add_column :newsletter_items, :linkable_type, :string
      add_column :newsletter_items, :linkable_id, :bigint

      execute <<~SQL
        UPDATE newsletter_items
        SET linkable_type = 'Article', linkable_id = article_id
        WHERE article_id IS NOT NULL
      SQL

      add_index :newsletter_items, [:linkable_type, :linkable_id]

      remove_index :newsletter_items, :article_id
      remove_column :newsletter_items, :article_id
    end
  end

  def down
    safety_assured do
      add_column :newsletter_items, :article_id, :bigint

      execute <<~SQL
        UPDATE newsletter_items
        SET article_id = linkable_id
        WHERE linkable_type = 'Article'
      SQL

      add_index :newsletter_items, :article_id

      remove_index :newsletter_items, [:linkable_type, :linkable_id]
      remove_column :newsletter_items, :linkable_type
      remove_column :newsletter_items, :linkable_id
    end
  end
end
