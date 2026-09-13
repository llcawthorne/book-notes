require "rails_helper"

RSpec.describe OrderMailer, type: :mailer do
  fixtures :orders, :line_items, :products

  describe "#received" do
    let(:mail) { OrderMailer.received(orders(:one)) }

    it "renders the subject" do
      expect(mail.subject).to eq("Pragmatic Store Order Confirmation")
    end

    it "renders the receiver" do
      expect(mail.to).to eq([ "dave@example.org" ])
    end

    it "renders the sender" do
      expect(mail.from).to eq([ "depot@example.com" ])
    end

    it "lists the ordered line items" do
      expect(mail.body.encoded).to match(/1 x The Pragmatic Programmer/)
    end
  end

  describe "#shipped" do
    let(:mail) { OrderMailer.shipped(orders(:one)) }

    it "renders the subject" do
      expect(mail.subject).to eq("Pragmatic Store Order Shipped")
    end

    it "renders the receiver" do
      expect(mail.to).to eq([ "dave@example.org" ])
    end

    it "renders the sender" do
      expect(mail.from).to eq([ "depot@example.com" ])
    end

    it "lists the shipped line items in a table" do
      expect(mail.body.encoded).to match(%r{
        <td[^>]*>1<\/td>\s*
        <td>&times;<\/td>\s*
        <td[^>]*>\s*The\sPragmatic\sProgrammer\s*</td>
      }x)
    end
  end

  describe "#payment_failed" do
    let(:mail) { OrderMailer.payment_failed(orders(:one), "Card declined") }

    it "renders the subject" do
      expect(mail.subject).to eq("Pragmatic Store Payment Failed")
    end

    it "renders the receiver" do
      expect(mail.to).to eq([ "dave@example.org" ])
    end

    it "renders the sender" do
      expect(mail.from).to eq([ "depot@example.com" ])
    end

    it "includes the failure details" do
      expect(mail.body.encoded).to match("Card declined")
    end
  end
end
