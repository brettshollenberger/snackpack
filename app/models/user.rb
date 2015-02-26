class User < ActiveRecord::Base
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, 
         :confirmable

  has_many :deliveries, :foreign_key => :sender_id
  has_many :recipients, :foreign_key => :sender_id
  has_many :templates

  validates_presence_of :first_name, :last_name, :email
  validates :email, :email => true, :uniqueness => true

  auto_strip_attributes :email

  before_save :ensure_authentication_token

  def self.find_by_authentication_token(token)
    User.where(authentication_token: token).first
  end
 
  def ensure_authentication_token
    if authentication_token.blank?
      self.authentication_token = generate_authentication_token
    end
  end
 
  def full_name
    "#{first_name} #{last_name}"
  end

private
  def generate_authentication_token
    loop do
      token = Devise.friendly_token
      break token unless User.where(authentication_token: token).first
    end
  end
end
