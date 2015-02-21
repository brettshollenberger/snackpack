class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.string :email, null: false
      t.integer :role, default: 0

      t.timestamps null: false
    end

    add_index :users, :email, unique: true
  end
end
