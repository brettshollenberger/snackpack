class Template < ActiveRecord::Base
  extend FriendlyId
  friendly_id :name, :use => [:slugged]
  auto_strip_attributes :text

  has_many :deliveries

  validates :name, :slug, :presence => true
  validates :name, :slug, :subject, :length => { :in => 1..255 }
end
