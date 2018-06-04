class AddUsersSearchesCount < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :searches_count, :integer, null: false, default: 0
    User.find_each { |user| User.reset_counters(user.id, :searches) }
  end
end
