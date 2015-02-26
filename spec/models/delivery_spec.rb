require 'circuit_breaker'
require 'rails_helper'

describe Delivery do
  let(:sender)    { FactoryGirl.create(:user) }
  let(:recipient) { FactoryGirl.create(:recipient) }
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

      expect(delivery.data_hash.body). to            eq("1 &gt; 0")
      expect(delivery.data_hash.body_html).to        eq("<p>hello</p>")
      expect(delivery.data_hash.template_id.to_i).to eq(delivery.template.id)
      expect(delivery.data_hash.recipient.email).to  eq(delivery.recipient.email)
      expect(delivery.data_hash.sender.email).to     eq(delivery.sender.email)
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

    context "exception sending email" do
      context "template error" do
        before(:each) do
          delivery.template.update(html: '<%= raise "FAIL" %>')
        end

        it "updates the status to failed" do
          expect{delivery.deliver}.to raise_error
          expect(delivery.status).to eq('failed')
        end
      end

      context "SMTP error" do
        context "users mailbox out of storage" do
          it "marks the delivery as not_sent" do
            allow_any_instance_of(CircuitBreaker).to receive(:call).and_raise(Net::SMTPFatalError.new("422 ERROR"))

            expect{delivery.deliver}.to_not raise_error
            expect(delivery.status).to eq 'not_sent'
          end
        end

        context "deliverer error" do
          it "delivers via an alternative deliverer if the initial deliverer fails with other 400 error" do
            delivery.template.provider = "sendgrid"
            @call_iteration = 1

            allow(Delivery::Deliverers::SendgridDeliverer.circuit_breaker).to receive(:call).and_raise(Net::SMTPFatalError.new("420 ERROR"))

            allow(Delivery::Deliverers::GenericDeliverer).to receive(:acquire_alternative_deliverer).and_return(Delivery::Deliverers::MailgunDeliverer)

            expect(Delivery::Deliverers::MailgunDeliverer).to receive(:deliver)

            expect{delivery.deliver}.to_not raise_error
          end
        end

        context "email address does not exist" do
          ["512", "550"].each do |error_code|
            describe "for error_code #{error_code}" do
              before(:each) do
                allow_any_instance_of(CircuitBreaker).to receive(:call).and_raise(Net::SMTPFatalError.new("#{error_code} ERROR"))
              end

              it "marks the delivery as hard_bounced" do
                expect{delivery.deliver}.to_not raise_error
                expect(delivery.status).to eq 'hard_bounced'
              end

              it "should mark the recipient status to address_not_exist" do
                expect{delivery.deliver}.to_not raise_error
                expect(delivery.recipient.status).to eq 'address_not_exist'
              end
            end
          end
        end

        context 'other hard bounces' do
          ["541", "554"].each do |error_code|
            describe "for error_code #{error_code}" do
              before do
                allow_any_instance_of(CircuitBreaker).to receive(:call).and_raise(Net::SMTPFatalError.new("#{error_code} ERROR"))
              end

              it "should mark the delivery as hard_bounced" do
                expect{delivery.deliver}.to raise_error
                expect(delivery.status).to eq 'hard_bounced'
              end
            end
          end
        end
      end
    end
  end

  describe "#async_deliver" do
    let(:delivery)  { FactoryGirl.build(:delivery, sender: sender, recipient: recipient) }

    it "creates a sidekiq job" do
      expect{delivery.async_deliver}.to change(DeliverySender.jobs, :size).by(1)
    end

    it "is called when Delivery is created" do
      expect{delivery.save}.to change(DeliverySender.jobs, :size).by(1)
      expect(DeliverySender.jobs.last["at"]).to be_blank
    end

    it "schedules on send_at if send_at is present" do
      expect{create(:delivery, send_at: 1.hour.from_now)}.to change(DeliverySender.jobs, :size).by(1)
      expect(DeliverySender.jobs.last["at"]).to be_present
    end

    it "pushes the job to medium queue by default" do
      delivery.save
      expect(DeliverySender.jobs.last["queue"]).to eq "medium"
    end
  end
end
