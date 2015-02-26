require 'rails_helper'

describe Recipient do
  let(:sender)    { create(:user) } 
  let(:sender2)   { create(:user) } 
  let(:recipient) { create(:recipient, sender: sender) }

  it "belongs to a sender" do
    expect(recipient.sender).to be sender
  end

  describe "validations" do
    it "is valid" do
      expect(recipient).to be_valid
    end

    it "is not valid without first_name" do
      recipient.first_name = nil
      expect(recipient).to_not be_valid
    end

    it "is not valid without last_name" do
      recipient.last_name = nil
      expect(recipient).to_not be_valid
    end

    it "is not valid without email" do
      recipient.email = nil
      expect(recipient).to_not be_valid
    end

    it "has valid statuses" do
      %w(ok address_not_exist).each do |status|
        recipient.status = status
        expect(recipient).to be_valid
      end
    end

    it "has a unique email within the context of a sender" do
      recipient2 = build(:recipient, email: recipient.email, sender: sender)

      expect(recipient2).to_not be_valid

      recipient2.sender = sender2

      expect(recipient2).to be_valid
    end
  end
end
