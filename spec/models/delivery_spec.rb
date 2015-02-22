require 'rails_helper'

RSpec.describe Delivery, type: :model do
  let(:sender)    { FactoryGirl.create(:user) }
  let(:recipient) { FactoryGirl.create(:user) }
  let(:delivery)  { FactoryGirl.create(:delivery, sender: sender, recipient: recipient) }

  it "has a sender" do
    expect(delivery.sender).to eq sender
  end

  it "has a recipient" do
    expect(delivery.recipient).to eq recipient
  end

  it "persists data as JSON" do
    delivery.data = { :cool => "dogs" }

    delivery.save

    expect(delivery.data).to eq({"cool" => "dogs" })
  end

  describe "statuses" do
    it "can be created" do
      %w(created sent failed not_sent hard_bounced soft_bounced).each do |status|
        delivery.status = status
        expect(delivery).to be_valid
      end
    end

    it "cannot be something else" do
      expect { delivery.status = "dead" }.to raise_error ArgumentError
    end
  end

  describe "validations" do
    it "is valid" do
      expect(delivery).to be_valid
    end

    it "is not valid without template" do
      delivery.template = nil
      expect(delivery).to_not be_valid
    end

    it "is not valid without recipient" do
      delivery.recipient = nil
      expect(delivery).to_not be_valid
    end

    it "is not valid without sender" do
      delivery.sender = nil
      expect(delivery).to_not be_valid
    end
  end
end
