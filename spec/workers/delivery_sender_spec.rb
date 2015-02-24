require 'rails_helper'

describe DeliverySender do
  let(:delivery) { create(:delivery) }

  it 'should deliver' do
    expect {
      DeliverySender.new.perform(delivery.id)
    }.to change(ActionMailer::Base.deliveries, :size).by(1)
  end
end
