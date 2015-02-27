require 'rails_helper'

describe "API Tokens API :" do
  describe "When not authenticated :" do
    before(:each) do
      get api_v1_auth_token_path
    end

    it "It is not a successful request" do
      expect(response).to_not be_success
    end

    it "It responds with an error message" do
      expect(json.error).to eq("You don't have permission.")
    end
  end

  describe "When authenticated :" do
    before(:each) do
      login(user)
    end

    describe "When no query params are passed :" do
      before(:each) do
        get api_v1_auth_token_path
      end

      it "It is a successful request" do
        expect(response).to be_success
      end

      it "It responds with the user's auth token" do
        expect(json.auth_token).to eq(user.authentication_token)
      end
    end
  end
end
