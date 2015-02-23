require "rake"

class Delivery
  module Deliverers
    class GenericDeliverer
      class << self
        # Public: Deliver mail. If mail API is down, select another to deliver through.
        def deliver(message)
          begin
            change_delivery_method(message, provider_name)
            circuit_breaker.call(message)
          rescue Timeout::Error
            puts "Timed out. Acquiring alternative deliverer"
            acquire_alternative_deliverer.deliver(message)
          end
        end

        def change_delivery_method(message, provider)
          message.delivery_method delivery_method, HashWithIndifferentAccess.new(
            send("#{provider}_smtp_options")
          ).symbolize_keys
        end

        def delivery_method
          CONFIG[Rails.env.to_sym].delivery_method
        end

        # Public: Select an alternative deliverer that is not failing
        def acquire_alternative_deliverer
          deliverers.select do |deliverer|
            deliverer.circuit_breaker.status != :open
          end.sample
        end

        def deliverers
          @deliverers ||= Rake::FileList.new(Dir[File.expand_path(File.join(__FILE__, "../**/*.rb"))].reject do |d|
            d.match(/generic_deliverer/) || d.match(/smtp_deliverer/)
          end).pathmap("%n").map(&:classify).map do |d|
            "Delivery::Deliverers::#{d}".constantize
          end
        end
      end
    end
  end
end
