class FixRegions < ActiveRecord::Migration[5.1]
  def change
    remove_column :regions, :discord_id
    add_column :regions, :position, :integer
  end
end
