class ChangeAdvancedDefault < ActiveRecord::Migration[5.1]
  def up
    change_column :searches, :advanced, :boolean, default: false
  end

  def down
    change_column :searches, :advanced, :boolean, default: nil
  end
end
