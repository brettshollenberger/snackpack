FactoryGirl.define do
  factory :recipient do
    first_name "Aubrey"
    last_name "Graham"
    sequence(:email) { |n| "drizzy#{n}@drake.net" }
    status 0

    association :sender, factory: :user
  end
end
