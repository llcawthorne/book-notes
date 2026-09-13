require "rails_helper"

RSpec.describe Order, type: :model do
  fixtures :products

  subject(:order) { Order.new(name: "Dave Thomas", address: "123 Main St", email: "dave@example.com", pay_type: "Check") }

  describe "validations" do
    it { is_expected.to be_valid }

    it "requires a name" do
      order.name = nil

      expect(order).to be_invalid
      expect(order.errors[:name]).to be_present
    end

    it "requires an address" do
      order.address = nil

      expect(order).to be_invalid
      expect(order.errors[:address]).to be_present
    end

    it "requires an email" do
      order.email = nil

      expect(order).to be_invalid
      expect(order.errors[:email]).to be_present
    end

    it "requires a recognized pay_type" do
      expect { order.pay_type = "Bitcoin" }.to raise_error(ArgumentError)
    end
  end

  describe "#add_line_items_from_cart" do
    let(:cart) { Cart.create! }

    before do
      cart.add_product(products(:pragprog)).save!
      cart.add_product(products(:one)).save!
    end

    it "moves the cart's line items onto the order" do
      order.add_line_items_from_cart(cart)

      expect(order.line_items.size).to eq(2)
    end

    it "detaches the line items from the cart" do
      order.add_line_items_from_cart(cart)

      expect(order.line_items).to all have_attributes(cart_id: nil)
    end
  end

  describe "#charge!" do
    before { order.save! }

    context "when paying by check" do
      before { order.pay_type = "Check" }

      it "sends the routing and account numbers to Pago as a check payment" do
        expect(Pago).to receive(:make_payment).with(
          order_id: order.id,
          payment_method: :check,
          payment_details: { routing: "123456", account: "987654" }
        ).and_call_original

        order.charge!(routing_number: "123456", account_number: "987654")
      end
    end

    context "when paying by credit card" do
      before { order.pay_type = "Credit card" }

      it "splits the expiration date and sends the card details to Pago" do
        expect(Pago).to receive(:make_payment).with(
          order_id: order.id,
          payment_method: :credit_card,
          payment_details: { cc_num: "4111111111111111", expiration_month: "03", expiration_year: "22" }
        ).and_call_original

        order.charge!(credit_card_number: "4111111111111111", expiration_date: "03/22")
      end
    end

    context "when paying by purchase order" do
      before { order.pay_type = "Purchase order" }

      it "sends the PO number to Pago as a purchase order payment" do
        expect(Pago).to receive(:make_payment).with(
          order_id: order.id,
          payment_method: :po,
          payment_details: { po_num: "PO-42" }
        ).and_call_original

        order.charge!(po_number: "PO-42")
      end
    end

    context "when the payment succeeds" do
      it "emails the order confirmation" do
        allow(Pago).to receive(:make_payment).and_return(OpenStruct.new(succeeded?: true))

        expect { order.charge!(routing_number: "1", account_number: "2") }
          .to have_enqueued_mail(OrderMailer, :received)
      end
    end

    context "when the payment fails" do
      it "emails the customer about the payment failure instead of raising" do
        allow(Pago).to receive(:make_payment)
          .and_return(OpenStruct.new(succeeded?: false, error: "Card declined"))

        expect { order.charge!(routing_number: "1", account_number: "2") }
          .to have_enqueued_mail(OrderMailer, :payment_failed).with(order, "Card declined")
      end
    end
  end
end
