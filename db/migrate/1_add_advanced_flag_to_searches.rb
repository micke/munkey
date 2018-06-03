class AddAdvancedFlagToSearches < ActiveRecord::Migration[5.1]
  def up
    add_column :searches, :advanced, :boolean
  end

  def down
    remove_column :searches, :advanced
  end
end
