class User < ActiveRecord::Base
  has_many :sent_deliveries, :class_name => "Delivery", :foreign_key => :sender_id
  has_many :received_deliveries, :class_name => "Delivery", :foreign_key => :recipient_id

  enum :role => [:recipient, :sender]

  validates_presence_of :first_name, :last_name, :email, :role
  validates :email, :email => true, :uniqueness => true

  auto_strip_attributes :email
end
