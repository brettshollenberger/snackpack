class DropEmailProviders < ActiveRecord::Migration
  def change
    drop_table :email_providers
  end
end
