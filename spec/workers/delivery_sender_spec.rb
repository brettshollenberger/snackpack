require 'rails_helper'

describe DeliverySender do
  before(:each) do
    @delivery = create(:delivery)
  end

  it "should deliver" do
    expect {
      DeliverySender.new.perform(@delivery.id)
    }.to change(ActionMailer::Base.deliveries, :size).by(1)
  end
end
