FactoryGirl.define do
  factory :template do
    name "My Email Template"
    subject "An Email For You!"
    html "<h1>Email</h1><p>Hi</p>"
    text "Email. Hi"
    provider "sendgrid"
  end
end
