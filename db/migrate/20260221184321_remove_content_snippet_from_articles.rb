class RemoveContentSnippetFromArticles < ActiveRecord::Migration[8.1]
  def change
    safety_assured { remove_column :articles, :content_snippet, :text }
  end
end
