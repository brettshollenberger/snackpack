class AddUserIdToCampaigns < ActiveRecord::Migration
  def self.up
    add_column :campaigns, :user_id, :integer, null: false

    add_foreign_key :campaigns, :users, :dependent => :delete
  end

  def self.down
    remove_column :campaigns, :user_id
    remove_foreign_key :campaigns, :users
  end
end
