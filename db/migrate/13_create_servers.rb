# frozen_string_literal: true

class CreateServers < ActiveRecord::Migration[5.1]
  def change
    create_table :servers, id: false do |t|
      t.bigint :id
      t.string :name
      t.timestamps null: false, default: -> { "NOW()" }
    end

    execute "ALTER TABLE servers ADD PRIMARY KEY (id);"
  end
end
