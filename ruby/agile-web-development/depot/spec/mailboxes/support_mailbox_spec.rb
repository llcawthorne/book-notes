require "rails_helper"

RSpec.describe SupportMailbox, type: :mailbox do
  fixtures :all

  describe "receiving a support request email" do
    subject(:support_request) { SupportRequest.last }

    context "when the sender has no matching order" do
      before do
        process(
          to: "support@example.com",
          from: "chris@somewhere.net",
          subject: "Need help",
          body: "I can't figure out how to check out!!"
        )
      end

      it "records the sender's email" do
        expect(support_request.email).to eq("chris@somewhere.net")
      end

      it "records the subject" do
        expect(support_request.subject).to eq("Need help")
      end

      it "records the body" do
        expect(support_request.body).to eq("I can't figure out how to check out!!")
      end

      it "has no associated order" do
        expect(support_request.order).to be_nil
      end
    end

    context "when the sender has placed orders before" do
      let(:recent_order) { orders(:one) }

      before do
        orders(:another_one)
        orders(:other_customer)

        process(
          to: "support@example.com",
          from: recent_order.email,
          subject: "Need help",
          body: "I can't figure out how to check out!!"
        )
      end

      it "associates the request with their most recent order" do
        expect(support_request.order).to eq(recent_order)
      end
    end
  end
end
