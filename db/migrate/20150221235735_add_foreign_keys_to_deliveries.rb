class AddForeignKeysToDeliveries < ActiveRecord::Migration
  def self.up
    add_foreign_key :deliveries, :templates, :dependent => :delete, :name => :fk_template_id
    add_foreign_key :deliveries, :users, :column => :recipient_id, :dependent => :delete, :name => :fk_recipient_id
    add_foreign_key :deliveries, :users, :column => :sender_id, :dependent => :delete, :name => :fk_sender_id
  end

  def self.down
    remove_foreign_key :deliveries, :templates, :name => :fk_template_id
    remove_foreign_key :deliveries, :users, :name => :fk_recipient_id
    remove_foreign_key :deliveries, :users, :name => :fk_sender_id
  end
end
