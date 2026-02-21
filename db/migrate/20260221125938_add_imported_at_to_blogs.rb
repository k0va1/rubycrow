class AddImportedAtToBlogs < ActiveRecord::Migration[8.1]
  def change
    add_column :blogs, :imported_at, :datetime

    reversible do |dir|
      dir.up do
        safety_assured do
          execute "UPDATE blogs SET imported_at = created_at WHERE imported_at IS NULL"
        end
      end
    end
  end
end
