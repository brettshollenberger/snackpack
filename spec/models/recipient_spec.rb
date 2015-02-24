require 'rails_helper'

describe Recipient do
  let(:recipient) { create(:recipient) }

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
  end
end
