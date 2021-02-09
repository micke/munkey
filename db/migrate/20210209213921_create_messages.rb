class CreateMessages < ActiveRecord::Migration[5.1]
  def up
    create_table :messages, id: false do |t|
      t.bigint :id
      t.text :content, null: false
      t.bigint :author_id, null: false

      t.timestamps null: false, default: -> { "NOW()" }
    end

    execute "ALTER TABLE messages ADD PRIMARY KEY (id);"
  end

  def down
    drop_table :messages
  end
end
