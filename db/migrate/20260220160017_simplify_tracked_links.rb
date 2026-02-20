class SimplifyTrackedLinks < ActiveRecord::Migration[8.1]
  def change
    safety_assured do
      add_reference :tracked_links, :newsletter_item, null: true, foreign_key: true
      remove_column :tracked_links, :section, :string
      remove_column :tracked_links, :position_in_newsletter, :integer
    end
  end
end
