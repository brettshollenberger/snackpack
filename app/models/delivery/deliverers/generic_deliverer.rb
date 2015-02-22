require "rake"

class Delivery
  module Deliverers
    class GenericDeliverer
      class << self
        # Public: Deliver mail. If mail API is down, select another to deliver through.
        def deliver(message)
          begin
            circuit_breaker.call(message)
          rescue Timeout::Error
            acquire_alternative_deliverer.deliver(message)
          end
        end

        # Public: Select an alternative deliverer that is not failing
        def acquire_alternative_deliverer
          deliverers.select do |deliverer|
            deliverer.circuit_breaker.state == :closed
          end.sample
        end

        def deliverers
          @deliverers ||= Rake::FileList.new(Dir[File.expand_path(File.join(__FILE__, "../**/*.rb"))].reject do |d|
            d.match(/generic_deliverer/)
          end).pathmap("%n").map(&:classify).map do |d|
            "Delivery::Deliverers::#{d}".constantize
          end
        end
      end
    end
  end
end
