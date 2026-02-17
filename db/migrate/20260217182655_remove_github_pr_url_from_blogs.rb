class RemoveGithubPrUrlFromBlogs < ActiveRecord::Migration[8.1]
  def change
    safety_assured { remove_column :blogs, :github_pr_url, :string }
  end
end
