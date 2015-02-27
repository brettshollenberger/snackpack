class Campaign < ActiveRecord::Base
  QUEUES = %w(high medium low)

  has_many :templates
  has_many :deliveries, :dependent => :destroy
  belongs_to :user

  validates :name, presence: true, length:{maximum: 250}
  validates :queue, inclusion: { :in => QUEUES }
  validates_uniqueness_of :name, :scope => [:user]

  def sent_count
    deliveries.sent.count
  end

  def send_rate
    total_attempted = deliveries.attempted.count.to_f

    return 0 if total_attempted == 0

    ((sent_count/total_attempted)*100).round
  end
end
