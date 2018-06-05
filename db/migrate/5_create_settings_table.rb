# frozen_string_literal: true

class CreateSettingsTable < ActiveRecord::Migration[5.1]
  def up
    create_table :settings do |t|
      t.string :key
      t.string :value
      t.timestamps null: false, default: -> { "NOW()" }
    end

    add_index :settings, :key, unique: true
  end

  def down

  end
end

