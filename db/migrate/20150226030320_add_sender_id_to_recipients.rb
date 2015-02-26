class AddSenderIdToRecipients < ActiveRecord::Migration
  def change
    add_column :recipients, :sender_id, :integer, null: false

    add_index :recipients, :sender_id
    add_index :recipients, [:sender_id, :email], unique: true
  end
end
