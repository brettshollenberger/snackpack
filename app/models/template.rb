class Template < ActiveRecord::Base
  auto_strip_attributes :text

  has_many :deliveries
  belongs_to :campaign
  belongs_to :user

  enum provider: [:sendgrid, :mailgun]
  validates :name, :user, :presence => true
  validates :name, :subject, :length => { :in => 1..255 }

  # Public: Returns true if the Template can be previewed.
  def renderable?
    CONFIG.template.renderable_providers.include?(self.provider)
  end
end
