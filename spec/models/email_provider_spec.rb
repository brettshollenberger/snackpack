require 'rails_helper'

describe EmailProvider, type: :model do
  let(:email_provider) { FactoryGirl.create(:email_provider) }

  describe "validations" do
    it "is valid" do
      expect(email_provider).to be_valid
    end

    it "is valid with supported name" do
      %w(sendgrid send_with_us).each do |supported_provider|
        email_provider.name = supported_provider
        expect(email_provider).to be_valid
      end
    end

    it "is not valid with unsupported name" do
      email_provider.name = :mailgun
      expect(email_provider).to_not be_valid
    end
  end
end
