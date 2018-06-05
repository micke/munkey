# frozen_string_literal: true

class ChangeSearchesIndex < ActiveRecord::Migration[5.1]
  def up
    remove_index :searches, [:submitter, :query]
    add_index :searches, [:submitter, :query]
  end

  def down
    remove_index :searches, [:submitter, :query]
    add_index :searches, [:submitter, :query], unique: true
  end
end
