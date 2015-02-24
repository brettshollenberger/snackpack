class ChangeRecipientForeignKey < ActiveRecord::Migration
  def self.up
    remove_foreign_key :deliveries, :name => :fk_recipient_id

    add_foreign_key :deliveries, :recipients, :dependent => :delete, :name => :fk_recipient_id
  end

  def self.down
    remove_foreign_key :deliveries, :recipients, :name => :fk_recipient_id

    add_foreign_key :deliveries, :name => :fk_recipient_id
  end
end
