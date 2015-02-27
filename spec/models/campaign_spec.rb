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

    it "is not valid with the same name and user of another campaign" do
      campaign2 = build(:campaign, user: campaign.user, name: campaign.name)
      expect(campaign2).to_not be_valid
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

  describe "#send_rate" do
    it "returns the rate of sent/attempted deliveries" do
      expect(campaign.send_rate).to eq 0

      deliveries = create_list(:delivery, 3, campaign: campaign)

      expect(campaign.send_rate).to eq 0

      2.times do |i|
        deliveries[i].update(status: :sent)
      end

      deliveries.last.update(status: :failed)

      expect(campaign.send_rate).to eq 67
    end

    it "excludes unattempted deliveries" do
      expect(campaign.send_rate).to eq 0

      deliveries = create_list(:delivery, 3, campaign: campaign)

      expect(campaign.send_rate).to eq 0

      2.times do |i|
        deliveries[i].update(status: :sent)
      end

      expect(campaign.send_rate).to eq 100
    end
  end
end
