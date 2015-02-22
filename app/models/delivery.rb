class Delivery < ActiveRecord::Base
  belongs_to :template
  belongs_to :recipient, :class_name => "User", :autosave => true
  belongs_to :sender, :class_name => "User", :autosave => true

  serialize :data, JSON
  enum status: [:created, :sent, :failed, :not_sent, :hard_bounced, :soft_bounced]

  auto_strip_attributes :data

  validates_presence_of :template, :recipient, :sender
end
