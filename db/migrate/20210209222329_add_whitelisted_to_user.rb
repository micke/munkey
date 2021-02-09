class AddWhitelistedToUser < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :whitelisted, :boolean, default: false
    User.update_all(whitelisted: true)
  end
end
