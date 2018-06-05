# frozen_string_literal: true

class AddServersCounts < ActiveRecord::Migration[5.1]
  def change
    add_column :servers, :channels_count, :integer, null: false, default: 0
    add_column :servers, :regions_count, :integer, null: false, default: 0
    Server.find_each { |server| Server.reset_counters(server.id, :channels, :regions) }
  end
end
