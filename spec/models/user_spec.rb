require 'rails_helper'

describe User do
  let(:user) { FactoryGirl.create(:user) }

  it "has a first name" do
    expect(user.first_name).to eq "Aubrey"
  end

  it "has a last name" do
    expect(user.last_name).to eq "Graham"
  end

  it "has an email" do
    expect(user.email).to_not be_empty
  end

  it "has an authentication token" do
    expect(user.authentication_token).to_not be_blank
  end

  it "finds user by authentication token" do
    token = user.authentication_token

    expect(User.find_by_authentication_token(token)).to eq user
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

    it "is not valid with an invalid email" do
      user.email = "not_an_email"

      expect(user).to_not be_valid
    end

    it "is not valid with a non-unique email" do
      user_with_dup_email = FactoryGirl.build(:user, :email => user.email)

      expect(user_with_dup_email).to_not be_valid
    end
  end
end
