module Api
  module V1
    class DeliveriesController < ApiController
      def index
        rescue_401_or_404 do
          @deliveries = current_user.deliveries.where(queryable_params)
        end
      end

      def show
        rescue_401_or_404 do
          @delivery = current_user.deliveries.find(params[:id])
        end
      end

      def create
        @delivery = current_user.deliveries.new(delivery_params)

        render :show and return if @delivery.save

        render unprocessable_entity(@delivery)
      end

      def destroy
        rescue_401_or_404 do
          @delivery = current_user.deliveries.find(params[:id])

          render deleted and return if !@delivery.nil? && @delivery.destroy
          render not_permitted
        end
      end

    private
      def queryable_params
        strong_params = params.permit(:campaign_id, :template_id)

        if params[:status].present?
          strong_params.merge!(status: Delivery.statuses[params[:status]])
        end

        strong_params
      end

      def delivery_params
        strong_params = params.permit(:template_id, :recipient_id, :campaign_id, :send_at)

        if recipient_params.present?
          recipient = current_user.recipients.where(recipient_params).first_or_initialize
          strong_params.merge!(recipient: recipient)
        end

        if params[:data].present?
          strong_params.merge!(data: params[:data])
        end

        strong_params
      end

      def recipient_params
        if params[:recipient].present? && params[:recipient].is_a?(Hash)
          params[:recipient].permit(:email, :first_name, :last_name)
        end
      end
    end
  end
end
