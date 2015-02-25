module Api
  module V1
    class UsersController < ApplicationController
      before_action :authorize
      before_filter :standardize_id, :only => [:show]

      def index
      end

      def show
        @user = User.find(params[:id])
      end

    private
      def standardize_id
        params[:id] = params[:id] == "me" ? current_user.id : params[:id]
      end
    end
  end
end
