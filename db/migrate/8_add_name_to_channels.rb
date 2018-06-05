# frozen_string_literal: true

class AddNameToChannels < ActiveRecord::Migration[5.1]
  def change
    add_column :channels, :name, :string
  end
end
