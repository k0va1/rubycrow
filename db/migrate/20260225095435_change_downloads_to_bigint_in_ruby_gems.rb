class ChangeDownloadsToBigintInRubyGems < ActiveRecord::Migration[8.1]
  def up
    safety_assured do
      change_column :ruby_gems, :downloads, :bigint, default: 0
    end
  end

  def down
    safety_assured do
      change_column :ruby_gems, :downloads, :integer, default: 0
    end
  end
end
