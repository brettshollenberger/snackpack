require 'rails_helper'

describe "Templates API :" do
  before(:all) do
    create_list(:template, 5, user: user)

    @other_user = create(:user)
    @other_user.confirm!
    create_list(:template, 5, user: @other_user)

    @template             = user.templates.first
    @other_users_template = @other_user.templates.first
  end

  describe "Index Action :" do
    describe "When not authenticated :" do
      before(:each) do
        get api_v1_templates_path
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
          get api_v1_templates_path
        end

        it "It is a successful request" do
          expect(response).to be_success
        end

        it "It responds with a list of the authenticated user's templates" do
          expect(json.length).to eq(5)
        end

        it "Has id, name, subject, html, and text" do
          template = json.first

          expect(template.id).to eq @template.id
          expect(template.name).to eq @template.name
          expect(template.subject).to eq @template.subject
          expect(template.html).to eq @template.html
          expect(template.text).to eq @template.text
        end
      end
    end
  end

  describe "Show Action :" do
    describe "When not authenticated :" do
      before(:each) do
        get api_v1_template_path(@template)
      end

      it "It is not a successful request" do
        expect(response).to_not be_success
      end

      it "It responds with an error message" do
        expect(json.error).to eq("You don't have permission.")
      end
    end

    describe "When authenticated but requesting another user's template :" do
      before(:each) do
        login(@other_user)
        get api_v1_template_path(@template)
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
        get api_v1_template_path(@template)
      end

      it "It is a successful request" do
        expect(response).to be_success
      end

      it "It responds with the template" do
        expect(json.id).to eql(@template.id)
      end
    end
  end

  describe "Create Action :" do
    before(:each) do
      def valid_template_json
        { 
          :format => :json, 
          :name => "My Great Template",
          :subject => "Hello",
          :html => "<p>Hello</p>",
          :text => "Hello"
        }
      end

      def invalid_template_json
        { 
          :format => :json, 
          :name => "My Great Template",
        }
      end
    end

    describe "When not authenticated :" do
      before(:each) do
        post api_v1_templates_path(valid_template_json)
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

      describe "If I create a valid template :" do
        before(:each) do
          post api_v1_templates_path(valid_template_json)
          @new_template = Template.last
        end

        it "It is a successful request" do
          expect(response).to be_success
        end

        it "It renders the recently created template" do
          expect(json.id).to eql(@new_template.id)
        end
      end

      describe "If I create an invalid template :" do
        before(:each) do
          post api_v1_templates_path(invalid_template_json)
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
      def valid_template_json
        { :format => :json, :subject => "New subject" }
      end
    end

    describe "When not authenticated :" do
      before(:each) do
        put api_v1_template_path(@template), valid_template_json
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

      describe "If I own the template :" do
        before(:each) do
          put api_v1_template_path(@template), valid_template_json
        end

        it "It is a successful request" do
          expect(response).to be_success
        end

        it "It renders the recently updated template" do
          expect(json.subject).to eql("New subject")
        end
      end

      describe "If I do not own the template :" do
        before(:each) do
          put api_v1_template_path(@other_users_template), valid_template_json
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
        delete api_v1_template_path(@template)
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

      describe "When the user owns the template :" do
        before(:each) do
          delete api_v1_template_path(@template)
        end

        it "is a successful request" do
          expect(response.status).to eq 204
        end
      end

      describe "When the user does not own the template :" do
        before(:each) do
          delete api_v1_template_path(@other_users_template)
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
