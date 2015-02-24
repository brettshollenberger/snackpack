FactoryGirl.define do
  factory :delivery do
    status :created

    association :campaign, :factory => :campaign
    association :template, :factory => :template
    association :recipient, :factory => :recipient
    association :sender, :factory => :user
  end

end
