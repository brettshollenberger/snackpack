FactoryGirl.define do
  factory :user do
    first_name "Aubrey"
    last_name "Graham"
    password "foobar15"
    sequence(:email) { |n| "drake#{n}@drizzy.net" }
  end
end
