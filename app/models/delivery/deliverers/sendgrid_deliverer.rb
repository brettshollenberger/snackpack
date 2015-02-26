require "circuit_breaker"

class Delivery
  module Deliverers
    class SendgridDeliverer < SmtpDeliverer
      def self.circuit_breaker
        @circuit_breaker ||= CircuitBreaker.new(timeout: 2, recent_count: 50, recent_minimum: 5) do |message|
          delivery_adapter(message)
        end
      end

      def self.provider_name
        "sendgrid"
      end

      def self.delivery_adapter(message)
        message.deliver
      end

      def self.sendgrid_smtp_options
        CONFIG.sendgrid_smtp_settings[Rails.env].merge(
          user_name: Rails.application.secrets.sendgrid_user_name,
          password: Rails.application.secrets.sendgrid_password,
          enable_starttls_auto: true
        )
      end
    end
  end
end
