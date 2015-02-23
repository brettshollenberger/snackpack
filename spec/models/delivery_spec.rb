require 'rails_helper'

describe Delivery do
  let(:sender)    { FactoryGirl.create(:user) }
  let(:recipient) { FactoryGirl.create(:user) }
  let(:delivery)  { FactoryGirl.create(:delivery, sender: sender, recipient: recipient) }

  it "has a sender" do
    expect(delivery.sender).to eq sender
  end

  it "has a recipient" do
    expect(delivery.recipient).to eq recipient
  end

  it "persists data as JSON" do
    delivery.data = { :cool => "dogs" }

    delivery.save

    expect(delivery.data).to eq({"cool" => "dogs" })
  end

  describe "statuses" do
    it "can be created" do
      %w(created sent failed not_sent hard_bounced soft_bounced).each do |status|
        delivery.status = status
        expect(delivery).to be_valid
      end
    end

    it "cannot be something else" do
      expect { delivery.status = "dead" }.to raise_error ArgumentError
    end
  end

  describe "validations" do
    it "is valid" do
      expect(delivery).to be_valid
    end

    it "is not valid without template" do
      delivery.template = nil
      expect(delivery).to_not be_valid
    end

    it "is not valid without recipient" do
      delivery.recipient = nil
      expect(delivery).to_not be_valid
    end

    it "is not valid without sender" do
      delivery.sender = nil
      expect(delivery).to_not be_valid
    end
  end

  describe "#data_hash" do
    it "returns sanitized Hashie::Mash of its data + defaults" do
      delivery.data = { body: "1 > 0", body_html: "<p>hello</p>" }

      expect(delivery.data_hash.body).to                      eq("1 &gt; 0")
      expect(delivery.data_hash.body_html).to                 eq("<p>hello</p>")
      expect(delivery.data_hash.snackpack.template_id).to     eq(delivery.template.slug)
      expect(delivery.data_hash.snackpack.recipient.email).to eq(delivery.recipient.email)
      expect(delivery.data_hash.snackpack.sender.email).to    eq(delivery.sender.email)
    end
  end

  describe "#message" do
    it "renders the message using the template and data" do
      html = <<-EOF
        <html>
          <body><p>
            Hello <%= name %>, welcome to our email campaign.
          </p></body>
        </html>
      EOF

      delivery.template.html = html
      delivery.data = {:name => "Aubrey Graham"}

      html_part = delivery.message.html_part.decoded

      expect(delivery.message.subject).to eq delivery.template.subject
      expect(delivery.message.to).to      include delivery.recipient.email
      expect(delivery.message.from).to    include delivery.sender.email
      expect(html_part).to                match "Hello Aubrey Graham"
    end

    it "renders text templates" do
      text = <<-EOF
        Hello <%= name %>, welcome to our email campaign.
      EOF

      delivery.template.text = text
      delivery.data = {:name => "Aubrey Graham"}

      expect(delivery.message.text_part.decoded).to match "Hello Aubrey Graham, welcome to our email campaign."
    end

    it "injects inline CSS to html body" do
      html = <<-EOF
        <html>
          <head><style>p {color: red;}</style></head>
          <body><p>Hello <%= name %></p></body>
        </html>
      EOF

      delivery.data = {:name => "Aubrey Graham"}
      delivery.template.html = html
      expect(delivery.message.html_part.decoded).to match '<p style="color:red">Hello Aubrey Graham</p>'
    end
  end
  
  describe "#deliver" do
    it "delivers with SMTP for sendgrid provider" do
      delivery.template = create(:sendgrid_template)

      expect { delivery.deliver }.to change(ActionMailer::Base.deliveries, :size).by(1)
      expect(delivery.status).to eq 'sent'
      expect(delivery.sent_at).to be_present
    end

    it "acquires an alternative deliverer if a timeout occurs on the preferred deliverer" do
      delivery.template = create(:sendgrid_template)

      allow(Delivery::Deliverers::SendgridDeliverer.circuit_breaker).to receive(:do_call).and_raise(Timeout::Error)

      allow(Delivery::Deliverers::GenericDeliverer).to receive(:acquire_alternative_deliverer).and_return(Delivery::Deliverers::MailgunDeliverer)

      expect { delivery.deliver }.to change(ActionMailer::Base.deliveries, :size).by(1)
    end
  end
end
