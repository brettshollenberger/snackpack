class Campaign < ActiveRecord::Base
  extend FriendlyId
  friendly_id :name, :use => [:slugged]
  QUEUES = %w(high medium low)

  has_many :templates
  has_many :deliveries

  validates :name, presence: true, length:{maximum: 250}
  validates :queue, inclusion: { :in => QUEUES }

  def sent_count
    deliveries.sent.count
  end
end
