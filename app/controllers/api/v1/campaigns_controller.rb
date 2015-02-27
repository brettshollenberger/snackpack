module Api
  module V1
    class CampaignsController < ApiController
      def index
        rescue_401_or_404 do
          @campaigns = current_user.campaigns
        end
      end

      def show
        rescue_401_or_404 do
          @campaign = current_user.campaigns.find(params[:id])
        end
      end

      def create
        @campaign = current_user.campaigns.new(campaign_params)

        render :show and return if @campaign.save

        render unprocessable_entity(@campaign)
      end

      def update
        rescue_401_or_404 do
          @campaign = current_user.campaigns.find(params[:id])

          render :show and return if @campaign.update(campaign_params)
          render unprocessable_entity(@campaign)
        end
      end

      def destroy
        rescue_401_or_404 do
          @campaign = current_user.campaigns.find(params[:id])

          render deleted and return if !@campaign.nil? && @campaign.destroy
          render not_permitted
        end
      end

    private
      def campaign_params
        params.permit(:name, :queue)
      end
    end
  end
end
