require 'rails_helper'

describe Delivery::Deliverers::GenericDeliverer do
  it "maintains a list of deliverers" do
    expect(Delivery::Deliverers::GenericDeliverer.deliverers).to include Delivery::Deliverers::SendgridDeliverer,
                                                                         Delivery::Deliverers::SmtpDeliverer
  end

  it "can provide an alternative deliverer from the list of deliverers that are not unavailable" do
    Delivery::Deliverers::SmtpDeliverer.circuit_breaker.instance_variable_set(:@failure_count, 100)

    expect(Delivery::Deliverers::GenericDeliverer.acquire_alternative_deliverer).to eq Delivery::Deliverers::SendgridDeliverer
  end
end
