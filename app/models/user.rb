class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :deliveries, :foreign_key => :sender_id

  validates_presence_of :first_name, :last_name, :email
  validates :email, :email => true, :uniqueness => true

  auto_strip_attributes :email

  def full_name
    "#{first_name} #{last_name}"
  end
end
