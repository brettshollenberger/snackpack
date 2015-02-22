FactoryGirl.define do
  factory :template do
    name "My Email Template"
    subject "An Email For You!"
    html "<h1>Email</h1><p>Hi</p>"
    text "Email. Hi"
    provider "sendgrid"

    factory :send_with_us_template do
      provider "sendgrid"
    end

    factory :sendgrid_template do
      provider "sendgrid"
    end
  end
end
