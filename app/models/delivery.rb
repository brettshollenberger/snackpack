require 'email_address_formatter'

class Delivery < ActiveRecord::Base
  class MissingDeliveryAdapter < StandardError; end

  belongs_to :template
  belongs_to :recipient, :class_name => "User", :autosave => true
  belongs_to :sender, :class_name => "User", :autosave => true

  serialize :data, JSON
  enum status: [:created, :sent, :failed, :not_sent, :hard_bounced, :soft_bounced]

  auto_strip_attributes :data

  validates_presence_of :template, :recipient, :sender

  def deliver
    delivery_adapter.deliver(message)
    update(status: 'sent', sent_at: Time.zone.now)
  end

  def message
    if valid? and self.template.renderable?
      @message ||= MessageRenderer.new(
        data: data_hash, 
        template: template, 
        recipient: recipient, 
        sender: sender
      ).render
    end
  end

  # Public: Return sanitized data + default values in Hashie::Mash
  #
  def data_hash
    @data_hash ||= Hashie::Mash.new(sanitize_data(self.data || {}).reverse_merge(built_in_variables))
  end

  # Public: HTML escape values that do not end in _html
  #
  def sanitize_data(value)
    HtmlSanitizer.sanitize(value)
  end

private
  # Private: Returns default variables to be used in the template
  #
  def built_in_variables
    {
      snackpack: {
        template_id: self.template.try(:to_param),
        recipient: {
          first_name: self.recipient.first_name,
          last_name: self.recipient.last_name,
          email: self.recipient.email
        },
        sender: {
          first_name: self.sender.first_name,
          last_name: self.sender.last_name,
          email: self.sender.email
        }
      }
    }
  end

  def delivery_adapter
    adapter_name = "Delivery::Deliverers::#{template.provider.classify}Deliverer"

    begin
      adapter_name.constantize
    rescue LoadError
      raise MissingDeliveryAdapter, "#{adapter_name} not defined"
    end
  end
end
