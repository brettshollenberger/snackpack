FactoryGirl.define do
  factory :delivery do
    # send_at "2015-02-21 15:44:35"
    # sent_at "2015-02-21 15:44:35"
    # data {key: 'value'}
    status 1

    association :template, :factory => :template
    association :recipient, :factory => :user
    association :sender, :factory => :user
  end

end
