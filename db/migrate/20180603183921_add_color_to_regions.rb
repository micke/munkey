# frozen_string_literal: true

class AddColorToRegions < ActiveRecord::Migration[5.1]
  def change
    add_column :regions, :color, :string
  end
end
