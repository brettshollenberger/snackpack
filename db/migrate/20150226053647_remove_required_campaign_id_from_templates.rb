class RemoveRequiredCampaignIdFromTemplates < ActiveRecord::Migration
  def self.up
    change_column :templates, :campaign_id, :integer, null: true
  end

  def self.down
    change_column :templates, :campaign_id, :integer, null: false
  end
end
