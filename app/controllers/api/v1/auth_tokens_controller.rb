module Api
  module V1
    class AuthTokensController < ApiController
      def show
        rescue_401_or_404 do
          @auth_token = current_user.authentication_token
        end
      end
    end
  end
end
