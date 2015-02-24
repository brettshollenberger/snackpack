require 'email_address_formatter'

class Delivery < ActiveRecord::Base
  class MissingDeliveryAdapter < StandardError; end

  scope :sent, -> { where(:status => :sent) }

  belongs_to :template
  belongs_to :campaign
  belongs_to :recipient, :class_name => "User", :autosave => true
  belongs_to :sender, :class_name => "User", :autosave => true

  serialize :data, JSON
  enum status: [:created, :sent, :failed, :not_sent, :hard_bounced, :soft_bounced]

  auto_strip_attributes :data

  validates_presence_of :template, :recipient, :sender

  after_commit :async_deliver, on: :create

  # Public: Delivers the message
  #
  def deliver
    begin
      delivery_adapter.deliver(message)
      update(status: 'sent', sent_at: Time.zone.now)
    rescue Net::SMTPFatalError => e
      case e.message
      when /^512/, /^550/
        update(status: 'hard_bounced')
        recipient.update(status: 'address_not_exist')
      # Recipient's mailbox full
      when /^422/
        update(status: 'not_sent')
      else
        update(status: 'hard_bounced')
        raise e
      end
    rescue StandardError => e
      update(status: 'failed')
      raise e
    end
  end

  # Public: Schedules a background job to deliver.
  #
  def async_deliver
    if self.send_at.present?
      Sidekiq::Client.enqueue_to_in("medium", self.send_at, DeliverySender, self.id)
    else
      Sidekiq::Client.enqueue_to("medium", DeliverySender, self.id)
    end
  end

  # Public: Renders the mail using data from delivery
  #
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

  # Private: Finds the adapter for the chosen mail provider
  #
  def delivery_adapter
    adapter_name = "Delivery::Deliverers::#{template.provider.classify}Deliverer"

    begin
      adapter_name.constantize
    rescue LoadError
      raise MissingDeliveryAdapter, "#{adapter_name} not defined"
    end
  end
end
