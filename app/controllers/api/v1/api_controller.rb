module Api
  module V1
    class ApiController < ApplicationController
      before_action :authorize

      class NotPermitted < StandardError
        def message
          "You are not permitted to view that resource"
        end
      end

    private
      def rescue_401_or_404(&block)
        begin
          block.call
        rescue ActiveRecord::RecordNotFound
          render not_found and return unless not_permitted?
          rescue_401_or_404 { raise NotPermitted }
        rescue NotPermitted
          render not_permitted and return
        end
      end

      def resources_name
        self.class.name.gsub(/Api\:\:V1\:\:|Controller/) { |n| "" }.downcase
      end

      def resource_name
        resources_name.singularize
      end

      def resource
        resource_name.classify.constantize
      end

      def resource_params
        self.send("#{resource_name}_params")
      end

      def resource_url(resource)
        self.send("api_v1_#{resource_name}_url", resource)
      end

      def not_permitted?
        !!resource.where(id: params[:id]).first
      end

      def unprocessable_entity(entity)
        {:status => :unprocessable_entity,
         :json => {
            :errors => entity.errors.to_h, 
            :status => "422", 
            :error => "Unprocessable entity"
          }
        }
      end

      def deleted
        { 
          :status => :no_content,
          :json => {}
        }
      end
    end
  end
end
