FactoryGirl.define do
  factory :campaign do
    sequence(:name) { |n| "My Campaign #{n}" }
    queue "medium"

    association :user, :factory => :user
  end
end
