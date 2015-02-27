require 'rails_helper'

describe "Campaigns API :" do
  before(:all) do
    create_list(:campaign, 5, user: user)

    @other_user = create(:user)
    @other_user.confirm!
    create_list(:campaign, 5, user: @other_user)

    @campaign             = user.campaigns.first
    @campaign2            = user.campaigns.second
    @other_users_campaign = @other_user.campaigns.first
  end

  describe "Index Action :" do
    describe "When not authenticated :" do
      before(:each) do
        get api_v1_campaigns_path
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
          get api_v1_campaigns_path
        end

        it "It is a successful request" do
          expect(response).to be_success
        end

        it "It responds with a list of the authenticated user's campaigns" do
          expect(json.length).to eq(5)
        end

        it "Has id, name, queue, send_count, send_rate" do
          campaign = json.first

          expect(campaign.id).to         eq @campaign.id
          expect(campaign.name).to       eq @campaign.name
          expect(campaign.queue).to      eq @campaign.queue
          expect(campaign.sent_count).to eq @campaign.sent_count
          expect(campaign.send_rate).to  eq @campaign.send_rate
        end
      end
    end
  end

  describe "Show Action :" do
    describe "When not authenticated :" do
      before(:each) do
        get api_v1_campaign_path(@campaign)
      end

      it "It is not a successful request" do
        expect(response).to_not be_success
      end

      it "It responds with an error message" do
        expect(json.error).to eq("You don't have permission.")
      end
    end

    describe "When authenticated but requesting another user's campaign :" do
      before(:each) do
        login(@other_user)
        get api_v1_campaign_path(@campaign)
      end

      it "It not is a successful request" do
        expect(response).to_not be_success
      end

      it "It responds with an error message" do
        expect(json.error).to eq("You don't have permission.")
      end
    end

    describe "When authenticated :" do
      before(:each) do
        login(user)
        get api_v1_campaign_path(@campaign)
      end

      it "It is a successful request" do
        expect(response).to be_success
      end

      it "It responds with the campaign" do
        expect(json.id).to eql(@campaign.id)
      end
    end
  end

  describe "Create Action :" do
    before(:each) do
      def valid_campaign_json
        { 
          :format => :json, 
          :name => "My Sweet Campaign"
        }
      end
    end

    describe "When not authenticated :" do
      before(:each) do
        post api_v1_campaigns_path(valid_campaign_json)
      end

      it "is not a successful request" do
        expect(response).to_not be_success
      end

      it "responds with an error message" do
        expect(json.error).to eql("You don't have permission.")
      end
    end

    describe "When authenticated :" do
      before(:each) do
        login(user)
      end

      describe "If I create a valid campaign :" do
        before(:each) do
          post api_v1_campaigns_path(valid_campaign_json)
          @new_campaign = Campaign.last
        end

        it "It is a successful request" do
          expect(response).to be_success
        end

        it "It renders the recently created campaign" do
          expect(json.id).to eql(@new_campaign.id)
        end
      end

      describe "If I create an invalid campaign :" do
        before(:each) do
          2.times do
            post api_v1_campaigns_path(valid_campaign_json)
          end
        end

        it "It is not a successful request" do
          expect(response).to_not be_success
        end

        it "It renders a 422 unprocessable entity" do
          expect(json.status).to eq "422"
        end
      end
    end
  end

  describe "Update Action :" do
    before(:each) do
      def valid_campaign_json
        { :format => :json, :name => "My Sweet Campaign" }
      end

      def invalid_campaign_json
        { :format => :json, :name => @campaign2.name }
      end
    end

    describe "When not authenticated :" do
      before(:each) do
        put api_v1_campaign_path(@campaign), valid_campaign_json
      end

      it "is not a successful request" do
        expect(response).to_not be_success
      end

      it "renders an error message" do
        expect(json.error).to eql("You don't have permission.")
      end
    end

    describe "When authenticated :" do
      before(:each) do
        login(user)
      end

      describe "If I own the campaign :" do
        before(:each) do
          put api_v1_campaign_path(@campaign), valid_campaign_json
        end

        it "It is a successful request" do
          expect(response).to be_success
        end

        it "It renders the recently updated campaign" do
          expect(json.name).to eql("My Sweet Campaign")
        end
      end

      describe "If the campaign contains errors :" do
        before(:each) do
          put api_v1_campaign_path(@campaign), invalid_campaign_json
        end

        it "It is a successful request" do
          expect(response).to_not be_success
        end

        it "It renders a 422 unprocessable entity" do
          expect(json.status).to eq "422"
        end
      end

      describe "If I do not own the campaign :" do
        before(:each) do
          put api_v1_campaign_path(@other_users_campaign), valid_campaign_json
        end

        it "It is not a successful request" do
          expect(response).to_not be_success
        end

        it "It renders an error message" do
          expect(json.error).to eql("You don't have permission.")
        end
      end
    end
  end

  describe "Delete Action :" do
    describe "When not authenticated :" do
      before(:each) do
        delete api_v1_campaign_path(@campaign)
      end

      it "It is not successful" do
        expect(response).to_not be_success
      end

      it "It renders an error message" do
        expect(json.error).to eql("You don't have permission.")
      end
    end

    describe "When authenticated :" do
      before(:each) do
        login(user)
      end

      describe "When the user owns the campaign :" do
        before(:each) do
          delete api_v1_campaign_path(@campaign)
        end

        it "is a successful request" do
          expect(response.status).to eq 204
        end
      end

      describe "When the user does not own the campaign :" do
        before(:each) do
          delete api_v1_campaign_path(@other_users_campaign)
        end

        it "is not a successful request" do
          expect(response).to_not be_success
        end

        it "does not display resource to the user" do
          expect(json.error).to eql("You don't have permission.")
        end
      end
    end
  end
end
