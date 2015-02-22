require "circuit_breaker"

class Delivery
  module Deliverers
    class SendgridDeliverer < SmtpDeliverer
      def self.circuit_breaker
        @circuit_breaker ||= CircuitBreaker.new do |message|
          delivery_adapter(message)
        end
      end
    end
  end
end
