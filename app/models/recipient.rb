class Recipient < ActiveRecord::Base
  has_many :deliveries

  enum :status => [:ok, :address_not_exist]

  validates_presence_of :first_name, :last_name, :email

  def full_name
    "#{first_name} #{last_name}"
  end
end
