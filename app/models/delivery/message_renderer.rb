require 'email_address_formatter'

class Delivery
  class MessageRenderer
    attr_accessor :data, :template, :recipient, :sender

    def initialize(options={})
      @data         = options.fetch(:data, {})
      @template     = options.fetch(:template)
      @recipient    = options.fetch(:recipient)
      @sender       = options.fetch(:sender)
    end

    def render
      renderer = self

      Mail.new do
        subject renderer.subject
        to renderer.to
        from renderer.from

        text_part do
          body renderer.text_body
        end

        html_part do
          body renderer.html_body
        end
      end
    end

    def data_binding
      @data_binding ||= data.instance_eval{binding}
    end

    def html_body
      Roadie::Document.new(
        erb_template(template.html)
      ).transform
    end

    def text_body
      template.text && erb_template(template.text)
    end

    def erb_template(template)
      ERB.new(template).result(data_binding)
    end

    def subject
      template.subject
    end

    def to
      EmailAddressFormatter.new.format_address(recipient.full_name, recipient.email)
    end

    def from
      EmailAddressFormatter.new.format_address(sender.full_name, sender.email)
    end
  end
end
