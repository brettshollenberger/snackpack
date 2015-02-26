require 'rails_helper'

describe "Deliveries API :" do
  before(:all) do
    @recipient = create(:recipient, sender: user)
    @template  = create(:template)
    @campaign  = create(:campaign)

    create_list(:delivery, 2, sender: user, campaign: @campaign)
    create_list(:delivery, 3, sender: user, template: @template)

    @other_user = create(:user)
    @other_user.confirm!
    create_list(:delivery, 5, sender: @other_user)

    @delivery             = user.deliveries.first
    @other_users_delivery = @other_user.deliveries.first
  end

  describe "Index Action :" do
    describe "When not authenticated :" do
      before(:each) do
        get api_v1_deliveries_path
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
          get api_v1_deliveries_path
        end

        it "It is a successful request" do
          expect(response).to be_success
        end

        it "It responds with a list of the authenticated user's deliveries" do
          expect(json.length).to eq(5)
        end

        it "Has id, status, recipient, template_id, and campaign_id" do
          delivery = json.first

          expect(delivery.id).to           eq @delivery.id
          expect(delivery.status).to       eq @delivery.status
          expect(delivery.recipient.id).to eq @delivery.recipient.id
          expect(delivery.template_id).to  eq @delivery.template_id
          expect(delivery.campaign_id).to  eq @delivery.campaign_id
        end
      end

      describe "Filtering by template_id :" do
        before(:each) do
          get api_v1_deliveries_path, { template_id: @template.id }
        end

        it "It is a successful request" do
          expect(response).to be_success
        end

        it "It responds with only deliveries that have the given template_id" do
          expect(json.length).to eq(3)

          json.each do |delivery|
            expect(delivery.template_id).to eq @template.id
          end
        end
      end

      describe "Filtering by campaign_id :" do
        before(:each) do
          get api_v1_deliveries_path, { campaign_id: @campaign.id }
        end

        it "It is a successful request" do
          expect(response).to be_success
        end

        it "It responds with only deliveries that have the given campaign_id" do
          expect(json.length).to eq(2)

          json.each do |delivery|
            expect(delivery.campaign_id).to eq @campaign.id
          end
        end
      end

      describe "Filtering by status :" do
        before(:each) do
          Delivery.first.update(status: :sent)
          get api_v1_deliveries_path, { status: "sent" }
        end

        it "It is a successful request" do
          expect(response).to be_success
        end

        it "It responds with only deliveries that have the given status" do
          expect(json.length).to eq(1)

          json.each do |delivery|
            expect(delivery.status).to eq "sent"
          end
        end
      end
    end
  end

  describe "Show Action :" do
    describe "When not authenticated :" do
      before(:each) do
        get api_v1_delivery_path(@delivery)
      end

      it "It is not a successful request" do
        expect(response).to_not be_success
      end

      it "It responds with an error message" do
        expect(json.error).to eq("You don't have permission.")
      end
    end

    describe "When authenticated but requesting another user's delivery :" do
      before(:each) do
        login(@other_user)
        get api_v1_delivery_path(@delivery)
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
        get api_v1_delivery_path(@delivery)
      end

      it "It is a successful request" do
        expect(response).to be_success
      end

      it "It responds with the delivery" do
        expect(json.id).to eql(@delivery.id)
      end
    end
  end

  describe "Create Action :" do
    before(:each) do
      def valid_delivery_json
        { 
          :format => :json, 
          :template_id => @template.id,
          :recipient_id => @recipient.id,
          :campaign_id => @campaign.id,
          :data => {
            :company_name => "YMCMB"
          }
        }
      end

      def invalid_delivery_json
        { 
          :format => :json, 
          :template_id => @template.id,
        }
      end

      def valid_delivery_with_recipient_json
        {
          :format => :json, 
          :template_id => @template.id,
          :campaign_id => @campaign.id,
          :recipient => {
            :first_name => "Aubrey",
            :last_name => "Graham",
            :email => "young_drake@drizzy.net"
          }
        }
      end
    end

    describe "When not authenticated :" do
      before(:each) do
        post api_v1_deliveries_path(valid_delivery_json)
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

      describe "If I create a valid delivery :" do
        before(:each) do
          post api_v1_deliveries_path(valid_delivery_json)
          @new_delivery = Delivery.last
        end

        it "It is a successful request" do
          expect(response).to be_success
        end

        it "It renders the recently created delivery" do
          expect(json.id).to eql(@new_delivery.id)
        end

        it "Adds valid data" do
          expect(@new_delivery.data).to eq({"company_name" => "YMCMB"})
        end
      end

      describe "Actual delivery" do
        it "creates a delivery job" do
          expect {
            post api_v1_deliveries_path(valid_delivery_json)
          }.to change(DeliverySender.jobs, :size).by(1)
        end
      end

      describe "If I create a delivery with a new recipient" do
        before(:each) do
          post api_v1_deliveries_path(valid_delivery_with_recipient_json)
          @new_delivery = Delivery.last
        end

        it "It is a successful request" do
          expect(response).to be_success
        end

        it "It renders the recently created delivery" do
          expect(json.id).to eql(@new_delivery.id)
        end
      end

      describe "If I create an invalid delivery :" do
        before(:each) do
          post api_v1_deliveries_path(invalid_delivery_json)
        end

        it "It is not a successful request" do
          expect(response).to_not be_success
        end

        it "It renders a 422 unprocessable entity" do
          expect(json.error).to eq "Unprocessable entity"
          expect(json.status).to eq "422"
        end
      end
    end
  end

  describe "Delete Action :" do
    describe "When not authenticated :" do
      before(:each) do
        delete api_v1_delivery_path(@delivery)
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

      describe "When the user owns the delivery :" do
        before(:each) do
          delete api_v1_delivery_path(@delivery)
        end

        it "is a successful request" do
          expect(response.status).to eq 204
        end
      end

      describe "When the user does not own the delivery :" do
        before(:each) do
          delete api_v1_delivery_path(@other_users_delivery)
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
