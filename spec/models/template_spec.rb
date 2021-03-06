require 'rails_helper'

describe Template do
  let(:template) { FactoryGirl.create(:template) }

  def char(n)
    (1..n).map { |n| "c" }.join("")
  end

  it "has a subject" do
    expect(template.subject).to eq "An Email For You!"
  end

  it "has an html representation" do
    expect(template.html).to eq "<h1>Email</h1><p>Hi</p>"
  end

  it "has text representation" do
    expect(template.text).to eq "Email. Hi"
  end

  it "has a provider" do
    expect(template.provider).to eq "sendgrid"
  end

  it "allows sendgrid & mailgun providers" do
    %w(sendgrid mailgun).each do |provider|
      template.provider = provider
      expect(template).to be_valid
    end
  end

  describe "validations" do
    it "is valid" do
      expect(template).to be_valid
    end

    it "is invalid without a name" do
      template.name = nil
      expect(template).to_not be_valid
    end

    it "is not valid with the same name and user of another template" do
      template2 = build(:template, user: template.user, name: template.name)
      expect(template2).to_not be_valid
    end

    it "is valid with a name up to 255 charcters" do
      template.name = char(255)

      expect(template).to be_valid
    end

    it "is invalid with a name longer than 255 characters" do
      template.name = char(256)

      expect(template).to_not be_valid
    end

    it "is valid with a subject up to 255 charcters" do
      template.subject = char(255)

      expect(template).to be_valid
    end

    it "is invalid with a subject longer than 255 characters" do
      template.subject = char(256)

      expect(template).to_not be_valid
    end

    it "is invalid if both html & text are blank" do
      template.html = nil

      expect(template).to be_valid

      template.text = nil

      expect(template).to_not be_valid

      template.html = "something"

      expect(template).to be_valid
    end
  end
end
