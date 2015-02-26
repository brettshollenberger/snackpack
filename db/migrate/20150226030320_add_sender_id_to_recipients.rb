class AddSenderIdToRecipients < ActiveRecord::Migration
  def self.up
    add_column :recipients, :sender_id, :integer, null: false

    add_foreign_key :recipients, :users, :column => :sender_id, :dependent => :delete
    add_index :recipients, [:sender_id, :email], unique: true
  end

  def self.down
    remove_column :recipients, :sender_id
    remove_foreign_key :recipients, :recipients
  end
end
