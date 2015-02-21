FactoryGirl.define do
  factory :user do
    first_name "Aubrey"
    last_name "Graham"
    sequence(:email) { |n| "drake#{n}@drizzy.net" }
    role "sender"
  end
end
