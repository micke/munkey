class CreateTables < ActiveRecord::Migration[5.1]
  def up
    create_table :users, id: false do |t|
      t.bigint :id
      t.string :name
      t.boolean :blocked
      t.timestamps null: false, default: -> { 'NOW()' }
    end

    execute "ALTER TABLE users ADD PRIMARY KEY (id);"

    create_table :searches do |t|
      t.bigint :user_id
      t.text :submitter
      t.text :unparsed_query
      t.boolean :enabled, default: true
      t.datetime :last_trigger_at
      t.timestamps null: false, default: -> { 'NOW()' }
    end

    add_foreign_key :searches, :users

    execute <<-SQL
      ALTER TABLE searches 
        ADD query tsquery
    SQL

    add_index :searches, [:submitter, :query], unique: true
  end

  def down

  end
end
