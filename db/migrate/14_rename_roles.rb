# frozen_string_literal: true

class RenameRoles < ActiveRecord::Migration[5.1]
  def change
    rename_table :roles, :regions
  end
end

