class AddTemplateIdCampaignIdRecipientIdUniqueKeyToDeliveries < ActiveRecord::Migration
  def change
    add_index :deliveries, [:template_id, :campaign_id, :recipient_id], unique: true
  end
end
