class ChangeRolesNames < ActiveRecord::Migration[5.1]
  def change
    execute "CREATE EXTENSION citext;"
    change_column :roles, :name, :citext
  end
end
