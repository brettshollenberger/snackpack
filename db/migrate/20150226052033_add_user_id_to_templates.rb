class AddUserIdToTemplates < ActiveRecord::Migration
  def self.up
    add_column :templates, :user_id, :integer, null: false

    add_foreign_key :templates, :users, :dependent => :delete, :name => :fk_user_id
  end

  def self.down
    remove_column :templates, :user_id
    remove_foreign_key :templates, :users, :name => :fk_user_id
  end
end
