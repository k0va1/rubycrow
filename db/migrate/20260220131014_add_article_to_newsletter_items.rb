class AddArticleToNewsletterItems < ActiveRecord::Migration[8.1]
  disable_ddl_transaction!

  def change
    add_reference :newsletter_items, :article, null: true, index: {algorithm: :concurrently}
  end
end
