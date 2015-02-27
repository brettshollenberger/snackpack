FactoryGirl.define do
  factory :template do
    sequence(:name) { |n| "My Email Template #{n}" }
    subject "An Email For You!"
    html "<h1>Email</h1><p>Hi</p>"
    text "Email. Hi"
    provider "sendgrid"

    association :campaign, factory: :campaign
    association :user, factory: :user

    factory :sendgrid_template do
      provider "sendgrid"
    end

    factory :mailgun_template do
      provider "mailgun"
    end
  end
end
