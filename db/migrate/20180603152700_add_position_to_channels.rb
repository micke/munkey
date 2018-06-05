# frozen_string_literal: true

class AddPositionToChannels < ActiveRecord::Migration[5.1]
  def change
    add_column :channels, :position, :integer
  end
end
