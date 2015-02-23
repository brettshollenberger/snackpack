class Delivery
  module Deliverers
    class SmtpDeliverer < GenericDeliverer
      def self.circuit_breaker
        @circuit_breaker ||= CircuitBreaker.new(timeout: 1, recent_count: 50, recent_minimum: 5) do |message|
          delivery_adapter(message)
        end
      end

      def self.delivery_adapter(message)
        message.deliver
      end
    end
  end
end
