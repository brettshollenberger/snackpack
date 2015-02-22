class EmailProvider < ActiveRecord::Base
  validates :name, :inclusion => { :in => %w(sendgrid send_with_us) }
end
