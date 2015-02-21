class User < ActiveRecord::Base
  enum :role => [:recipient, :sender]

  validates_presence_of :first_name, :last_name, :email, :role
  validates :email, :email => true, :uniqueness => true

  auto_strip_attributes :email
end
