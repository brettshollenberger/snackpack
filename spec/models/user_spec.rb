require 'rails_helper'

RSpec.describe User do
  let(:user) { FactoryGirl.create(:user) }

  it "has a first name" do
    expect(user.first_name).to eq "Aubrey"
  end

  it "has a last name" do
    expect(user.last_name).to eq "Graham"
  end

  it "has an email" do
    expect(user.email).to eq "drake@drizzy.net"
  end

  it "has a role" do
    expect(user.role).to eq "sender"
  end

  describe "validations" do
    it "is invalid without a first_name" do
      user.first_name = nil

      expect(user).to_not be_valid
    end

    it "is invalid without a last_name" do
      user.last_name = nil

      expect(user).to_not be_valid
    end

    it "is invalid without an email" do
      user.email = nil

      expect(user).to_not be_valid
    end

    it "is invalid without a role" do
      user.role = nil

      expect(user).to_not be_valid
    end

    it "is not valid with an invalid email" do
      user.email = "not_an_email"

      expect(user).to_not be_valid
    end
  end
end
