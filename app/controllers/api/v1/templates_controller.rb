module Api
  module V1
    class TemplatesController < ApiController
      def index
        rescue_401_or_404 do
          @templates = current_user.templates
        end
      end

      def show
        rescue_401_or_404 do
          @template = current_user.templates.find(params[:id])
        end
      end

      def create
        @template = current_user.templates.new(template_params)

        render :show and return if @template.save

        render unprocessable_entity(@template)
      end

      def update
        rescue_401_or_404 do
          @template = current_user.templates.find(params[:id])

          render :show and return if @template.update(template_params)
          render unprocessable_entity(@template)
        end
      end

      def destroy
        rescue_401_or_404 do
          @template = current_user.templates.find(params[:id])

          render deleted and return if !@template.nil? && @template.destroy
          render not_permitted
        end
      end

    private
      def template_params
        params.permit(:name, :subject, :html, :text)
      end
    end
  end
end
