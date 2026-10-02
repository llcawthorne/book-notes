require "rails_helper"

RSpec.describe SupportRequestMailer, type: :mailer do
  fixtures :all

  describe "#respond" do
    let(:support_request) { support_requests(:one) }
    let(:mail) { SupportRequestMailer.respond(support_request) }

    it "renders the subject" do
      expect(mail.subject).to eq("Re: #{support_request.subject}")
    end

    it "renders the receiver" do
      expect(mail.to).to eq([ support_request.email ])
    end

    it "renders the sender" do
      expect(mail.from).to eq([ "support@example.com" ])
    end

    it "includes the original request body" do
      expect(mail.body.encoded).to match(support_request.body)
    end
  end
end
