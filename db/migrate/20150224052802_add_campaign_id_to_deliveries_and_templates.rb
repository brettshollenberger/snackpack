class AddCampaignIdToDeliveriesAndTemplates < ActiveRecord::Migration
  def change
    add_column :templates, :campaign_id, :integer, null: false
    add_column :deliveries, :campaign_id, :integer, null: false

    add_foreign_key :templates, :campaigns
    add_foreign_key :deliveries, :campaigns
  end
end
