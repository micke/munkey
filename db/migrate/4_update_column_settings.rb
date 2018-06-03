class UpdateColumnSettings < ActiveRecord::Migration[5.1]
  def up
    change_column :searches, :user_id, :bigint, null: false
    change_column :users, :id, :bigint, null: false
  end
end
