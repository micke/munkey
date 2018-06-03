class CreateChannels < ActiveRecord::Migration[5.1]
  def up
    create_table :channels, id: false do |t|
      t.bigint :id
      t.bigint :server_id
      t.string :topic
      t.boolean :gb_alerts, default: false
      t.timestamps null: false, default: -> { 'NOW()' }
    end

    execute "ALTER TABLE channels ADD PRIMARY KEY (id);"
  end

  def down

  end
end
