require 'rails_helper'

describe Delivery::Deliverers::GenericDeliverer do
  it "maintains a list of deliverers" do
    expect(Delivery::Deliverers::GenericDeliverer.deliverers).to include Delivery::Deliverers::SendgridDeliverer,
                                                                         Delivery::Deliverers::MailgunDeliverer
  end
end
