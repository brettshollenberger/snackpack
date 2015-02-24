class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :sent_deliveries, :class_name => "Delivery", :foreign_key => :sender_id
  has_many :received_deliveries, :class_name => "Delivery", :foreign_key => :recipient_id

  enum :status => [:ok, :address_not_exist]
  enum :role => [:recipient, :sender]

  validates_presence_of :first_name, :last_name, :email, :role
  validates :email, :email => true, :uniqueness => true

  auto_strip_attributes :email

  def full_name
    "#{first_name} #{last_name}"
  end
end
