class AddNameUserIdKeyToCampaigns < ActiveRecord::Migration
  def change
    add_index :campaigns, [:name, :user_id], unique: true
  end
end
