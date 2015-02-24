class CreateRecipients < ActiveRecord::Migration
  def change
    create_table :recipients do |t|
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.string :email, null: false
      t.integer :status, default: 0

      t.timestamps null: false
    end

    add_index :recipients, :email, unique: true
  end
end
