class Template < ActiveRecord::Base
  extend FriendlyId
  friendly_id :name, :use => [:slugged]
  auto_strip_attributes :text

  has_many :deliveries

  enum provider: [:sendgrid, :mailgun]
  validates :name, :slug, :presence => true
  validates :name, :slug, :subject, :length => { :in => 1..255 }

  # Public: Returns true if the Template can be previewed.
  def renderable?
    CONFIG.template.renderable_providers.include?(self.provider)
  end
end
