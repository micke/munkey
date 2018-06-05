# frozen_string_literal: true

class AddServerIdToRegions < ActiveRecord::Migration[5.1]
  def change
    add_column :regions, :server_id, :bigint
  end
end
