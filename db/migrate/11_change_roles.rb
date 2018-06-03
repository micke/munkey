class ChangeRoles < ActiveRecord::Migration[5.1]
  def change
    change_column :roles, :discord_id, :bigint
  end
end
