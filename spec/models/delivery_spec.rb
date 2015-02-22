require 'rails_helper'

describe Delivery do
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

  describe "#data_hash" do
    it "returns sanitized Hashie::Mash of its data + defaults" do
      delivery.data = { body: "1 > 0", body_html: "<p>hello</p>" }

      expect(delivery.data_hash.body).to                      eq("1 &gt; 0")
      expect(delivery.data_hash.body_html).to                 eq("<p>hello</p>")
      expect(delivery.data_hash.snackpack.template_id).to     eq(delivery.template.slug)
      expect(delivery.data_hash.snackpack.recipient.email).to eq(delivery.recipient.email)
      expect(delivery.data_hash.snackpack.sender.email).to    eq(delivery.sender.email)
    end
  end
end
