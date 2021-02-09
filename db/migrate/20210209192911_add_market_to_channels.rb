class AddMarketToChannels < ActiveRecord::Migration[5.1]
  def change
    add_column :channels, :market, :boolean, default: false
    add_column :channels, :delete_message_log_channel_id, :bigint
  end
end
