module Api
  module V1
    class RecipientsController < ApiController
      def index
        rescue_401_or_404 do
          @recipients = current_user.recipients
        end
      end

      def show
        rescue_401_or_404 do
          @recipient = current_user.recipients.find(params[:id])
        end
      end

      def create
        @recipient = current_user.recipients.new(recipient_params)

        render :show and return if @recipient.save

        render unprocessable_entity(@recipient)
      end

      def update
        rescue_401_or_404 do
          @recipient = current_user.recipients.find(params[:id])

          render :show and return if @recipient.update(recipient_params)
          render unprocessable_entity(@recipient)
        end
      end

      def destroy
        rescue_401_or_404 do
          @recipient = current_user.recipients.find(params[:id])

          render deleted and return if !@recipient.nil? && @recipient.destroy
          render not_permitted
        end
      end

    private
      def recipient_params
        params.permit(:first_name, :last_name, :email)
      end
    end
  end
end
