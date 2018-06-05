# frozen_string_literal: true

class AddWantsToSearches < ActiveRecord::Migration[5.1]
  def up
    add_column :searches, :wants, :boolean, default: false
  end

  def down
    remove_column :searches, :wants
  end
end
