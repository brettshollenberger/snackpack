require 'rails_helper'

describe Campaign, type: :model do
  let(:campaign) { create(:campaign) }

  describe "validations" do
    it "is valid" do
      expect(campaign).to be_valid
    end

    it "is not valid without a name" do
      campaign.name = nil
      expect(campaign).to_not be_valid
    end

    it "has valid queues" do
      %w(low medium high).each do |queue|
        campaign.queue = queue
        expect(campaign).to be_valid
      end
    end
  end

  describe "#sent_count" do
    it "counts the number of successful deliveries in the campaign" do
      expect(campaign.sent_count).to eq 0

      deliveries = create_list(:delivery, 3, campaign: campaign)

      expect(campaign.sent_count).to eq 0

      deliveries.each { |d| d.update(status: :sent) }

      expect(campaign.sent_count).to eq 3
    end
  end
end
