require 'email_address_formatter'

class Delivery < ActiveRecord::Base
  class MissingDeliveryAdapter < StandardError; end

  scope :sent,      -> { where(:status => :sent) }
  scope :attempted, -> { where("status <> ?", :created) }

  belongs_to :template, :dependent => :destroy
  belongs_to :campaign, :dependent => :destroy
  belongs_to :recipient, :autosave => true
  belongs_to :sender, :class_name => "User", :autosave => true

  serialize :data, JSON
  enum status: [:created, :sent, :failed, :not_sent, :hard_bounced, :soft_bounced]

  auto_strip_attributes :data

  validates_presence_of :template, :recipient, :sender
  validates_uniqueness_of :recipient_id, :scope => [:template_id, :campaign_id], :message => "Delivery has already been created for this recipient."

  after_commit :async_deliver, on: :create

  # Public: Delivers the message
  #
  def deliver
    return false if sent?

    if undeliverable?
      update(status: "not_sent")
      return false
    end

    begin
      delivery_adapter.deliver(message)
      update(status: 'sent', sent_at: Time.zone.now)
    rescue Net::SMTPFatalError => e
      handle_smtp_error(e)
    rescue StandardError => e
      update(status: 'failed')
      raise e
    end
  end

  # Public: The delivery has been sent
  #
  def sent?
    status == "sent"
  end

  # Public: The delivery has not been sent
  #
  def unsent?
    !sent?
  end

  # Public: The delivery is not already known to be impossible
  #
  def deliverable?
    recipient.status != "address_not_exist"
  end

  # Public: The delivery is already known to be impossible
  #
  def undeliverable?
    !deliverable?
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
      template_id: self.template.try(:to_param),
      recipient: {
        full_name: self.recipient.full_name,
        first_name: self.recipient.first_name,
        last_name: self.recipient.last_name,
        email: self.recipient.email
      },
      sender: {
        full_name: self.sender.full_name,
        first_name: self.sender.first_name,
        last_name: self.sender.last_name,
        email: self.sender.email
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

  # Private: When deliveries raise errors that are not the fault of the deliverer,
  # update the model appropriately
  #
  def handle_smtp_error(error)
    case error.message
    when /^512/, /^550/
      update(status: 'hard_bounced')
      recipient.update(status: 'address_not_exist')
      # Recipient's mailbox full
    when /^422/
      update(status: 'not_sent')
    else
      update(status: 'hard_bounced')
      raise error
    end
  end
end
