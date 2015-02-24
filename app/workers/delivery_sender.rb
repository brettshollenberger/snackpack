class DeliverySender
  include Sidekiq::Worker
  sidekiq_options queue: 'medium'

  def perform(delivery_id)
    Delivery.find(delivery_id).deliver
  end
end
