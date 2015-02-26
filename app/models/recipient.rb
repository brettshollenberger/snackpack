class Recipient < ActiveRecord::Base
  has_many :deliveries
  belongs_to :sender, :class_name => "User", :foreign_key => :sender_id

  enum :status => [:ok, :address_not_exist]

  validates_presence_of :first_name, :last_name, :email
  validates_uniqueness_of :email, :scope => [:sender_id]

  def full_name
    "#{first_name} #{last_name}"
  end
end
