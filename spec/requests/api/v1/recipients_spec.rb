require 'rails_helper'

describe "Recipients API :" do
  before(:all) do
    create_list(:recipient, 5, sender: user)

    @other_user = create(:user)
    @other_user.confirm!
    create_list(:recipient, 5, sender: @other_user)

    @recipient             = user.recipients.first
    @recipient2            = user.recipients.second
    @other_users_recipient = @other_user.recipients.first
  end

  describe "Index Action :" do
    describe "When not authenticated :" do
      before(:each) do
        get api_v1_recipients_path
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
          get api_v1_recipients_path
        end

        it "It is a successful request" do
          expect(response).to be_success
        end

        it "It responds with a list of the authenticated user's recipients" do
          expect(json.length).to eq(5)
        end

        it "Has id, first_name, last_name, email, and status for each recipient" do
          recipient       = json.first
          users_recipient = user.recipients.first

          expect(recipient.id).to eq users_recipient.id
          expect(recipient.first_name).to eq users_recipient.first_name
          expect(recipient.last_name).to eq users_recipient.last_name
          expect(recipient.email).to eq users_recipient.email
          expect(recipient.status).to eq users_recipient.status
        end
      end
    end
  end

  describe "Show Action :" do
    describe "When not authenticated :" do
      before(:each) do
        get api_v1_recipient_path(@recipient)
      end

      it "It is not a successful request" do
        expect(response).to_not be_success
      end

      it "It responds with an error message" do
        expect(json.error).to eq("You don't have permission.")
      end
    end

    describe "When authenticated but requesting another user's recipient :" do
      before(:each) do
        login(@other_user)
        get api_v1_recipient_path(@recipient)
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
        get api_v1_recipient_path(@recipient)
      end

      it "It is a successful request" do
        expect(response).to be_success
      end

      it "It responds with the recipient" do
        expect(json.id).to eql(@recipient.id)
      end
    end
  end

  describe "Create Action :" do
    before(:each) do
      def valid_recipient_json
        { 
          :format => :json, 
          :first_name => "Aubrey", 
          :last_name => "Graham", 
          :email => "youngdrizz@drake.net"
        }
      end

      def invalid_recipient_json
        { 
          :format => :json, 
          :first_name => "Aubrey",
        }
      end
    end

    describe "When not authenticated :" do
      before(:each) do
        post api_v1_recipients_path(valid_recipient_json)
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

      describe "If I create a valid recipient :" do
        before(:each) do
          post api_v1_recipients_path(valid_recipient_json)
          @new_recipient = Recipient.last
        end

        it "It is a successful request" do
          expect(response).to be_success
        end

        it "It renders the recently created recipient" do
          expect(json.id).to eql(@new_recipient.id)
        end
      end

      describe "If I create an invalid recipient :" do
        before(:each) do
          post api_v1_recipients_path(invalid_recipient_json)
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
      def valid_recipient_json
        { :format => :json, :email => "drakenet@drake.net" }
      end

      def invalid_recipient_json
        { :format => :json, :email => @recipient2.email }
      end
    end

    describe "When not authenticated :" do
      before(:each) do
        put api_v1_recipient_path(@recipient), valid_recipient_json
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

      describe "If I own the recipient :" do
        before(:each) do
          put api_v1_recipient_path(@recipient), valid_recipient_json
        end

        it "It is a successful request" do
          expect(response).to be_success
        end

        it "It renders the recently updated recipient" do
          expect(json.email).to eql("drakenet@drake.net")
        end
      end

      describe "If the recipient contains errors :" do
        before(:each) do
          put api_v1_recipient_path(@recipient), invalid_recipient_json
        end

        it "It is a successful request" do
          expect(response).to_not be_success
        end

        it "It renders a 422 unprocessable entity" do
          expect(json.status).to eq "422"
        end
      end

      describe "If I do not own the recipient :" do
        before(:each) do
          put api_v1_recipient_path(@other_users_recipient), valid_recipient_json
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
        delete api_v1_recipient_path(@recipient)
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

      describe "When the user owns the recipient :" do
        before(:each) do
          delete api_v1_recipient_path(@recipient)
        end

        it "is a successful request" do
          expect(response.status).to eq 204
        end
      end

      describe "When the user does not own the recipient :" do
        before(:each) do
          delete api_v1_recipient_path(@other_users_recipient)
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
