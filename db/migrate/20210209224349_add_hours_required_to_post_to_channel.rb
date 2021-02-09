class AddHoursRequiredToPostToChannel < ActiveRecord::Migration[5.1]
  def change
    add_column :channels, :hours_required_to_post, :bigint, default: 0
  end
end
