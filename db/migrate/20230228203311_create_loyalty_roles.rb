class CreateLoyaltyRoles < ActiveRecord::Migration[5.1]
  def change
    create_table :loyalty_roles do |t|
      t.string :name
      t.bigint :server_id
      t.bigint :required_age
    end
  end
end
