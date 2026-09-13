require "rails_helper"

RSpec.describe SystemMailer, type: :mailer do
  describe "#error_notification" do
    let(:mail) { SystemMailer.error_notification("Attempt to access invalid cart 999") }

    it "renders the subject" do
      expect(mail.subject).to eq("Pragmatic Store Application Error")
    end

    it "renders the receiver" do
      expect(mail.to).to eq([ "admin@example.com" ])
    end

    it "renders the sender" do
      expect(mail.from).to eq([ "depot@example.com" ])
    end

    it "includes the error message" do
      expect(mail.body.encoded).to match("Attempt to access invalid cart 999")
    end
  end
end
