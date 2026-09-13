require "rails_helper"

RSpec.describe PasswordsMailer, type: :mailer do
  fixtures :users

  describe "#reset" do
    let(:user) { users(:one) }
    let(:mail) { PasswordsMailer.reset(user) }

    it "renders the subject" do
      expect(mail.subject).to eq("Reset your password")
    end

    it "renders the receiver" do
      expect(mail.to).to eq([ user.email_address ])
    end

    it "includes a link to the password reset page" do
      expect(mail.body.encoded).to match(%r{/passwords/[^/\s]+/edit})
    end
  end
end
