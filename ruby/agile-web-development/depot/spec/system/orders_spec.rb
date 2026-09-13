require "rails_helper"

RSpec.describe "Orders", type: :system do
  include ActiveJob::TestHelper

  fixtures :products, :orders, :users

  describe "checkout form's payment fields" do
    before do
      visit store_index_url
      click_on "Add to Cart", match: :first
      click_on "Checkout"
      expect(page).to have_selector("h1", text: "Please Enter Your Details")
    end

    context "before selecting a payment method" do
      it "shows no payment-specific fields" do
        expect(page).to have_no_field("Routing #")
        expect(page).to have_no_field("Account #")
        expect(page).to have_no_field("CC #")
        expect(page).to have_no_field("Expiry")
        expect(page).to have_no_field("PO #")
      end
    end

    context "when paying by check" do
      before { select "Check", from: "Pay with" }

      it "shows only the routing and account number fields" do
        expect(page).to have_field("Routing #")
        expect(page).to have_field("Account #")
        expect(page).to have_no_field("CC #")
        expect(page).to have_no_field("Expiry")
        expect(page).to have_no_field("PO #")
      end
    end

    context "when paying by credit card" do
      before { select "Credit Card", from: "Pay with" }

      it "shows only the credit card number and expiry fields" do
        expect(page).to have_no_field("Routing #")
        expect(page).to have_no_field("Account #")
        expect(page).to have_field("CC #")
        expect(page).to have_field("Expiry")
        expect(page).to have_no_field("PO #")
      end
    end

    context "when paying by purchase order" do
      before { select "Purchase Order", from: "Pay with" }

      it "shows only the PO number field" do
        expect(page).to have_no_field("Routing #")
        expect(page).to have_no_field("Account #")
        expect(page).to have_no_field("CC #")
        expect(page).to have_no_field("Expiry")
        expect(page).to have_field("PO #")
      end
    end
  end

  describe "placing an order" do
    before do
      LineItem.delete_all
      Order.delete_all

      visit store_index_url
      click_on "Add to Cart", match: :first
      click_on "Checkout"
      expect(page).to have_selector("h1", text: "Please Enter Your Details")

      fill_in "Name", with: "Dave Thomas"
      fill_in "Address", with: "123 Main Street"
      fill_in "E-mail", with: "dave@example.com"

      select "Check", from: "Pay with"
      fill_in "Routing #", with: "123456"
      fill_in "Account #", with: "987654"

      click_button "Place Order"
      expect(page).to have_text("Thank you for your order")
    end

    it "confirms the order on screen" do
      expect(page).to have_text("Thank you for your order")
    end

    it "creates a single order with the entered details" do
      expect(Order.count).to eq(1)

      order = Order.first
      expect(order.name).to eq("Dave Thomas")
      expect(order.address).to eq("123 Main Street")
      expect(order.email).to eq("dave@example.com")
      expect(order.pay_type).to eq("Check")
      expect(order.line_items.size).to eq(1)
    end

    it "sends an order confirmation email" do
      perform_enqueued_jobs
      perform_enqueued_jobs
      assert_performed_jobs 2

      mail = ActionMailer::Base.deliveries.last
      expect(mail.to).to eq([ "dave@example.com" ])
      expect(mail[:from].value).to eq("Sam Ruby <depot@example.com>")
      expect(mail.subject).to eq("Pragmatic Store Order Confirmation")
    end
  end

  describe "placing an order when the payment processor declines" do
    before do
      LineItem.delete_all
      Order.delete_all

      allow(Pago).to receive(:make_payment)
        .and_return(OpenStruct.new(succeeded?: false, error: "Card declined"))

      visit store_index_url
      click_on "Add to Cart", match: :first
      click_on "Checkout"
      expect(page).to have_selector("h1", text: "Please Enter Your Details")

      fill_in "Name", with: "Dave Thomas"
      fill_in "Address", with: "123 Main Street"
      fill_in "E-mail", with: "dave@example.com"

      select "Check", from: "Pay with"
      fill_in "Routing #", with: "123456"
      fill_in "Account #", with: "987654"

      click_button "Place Order"
      expect(page).to have_text("Thank you for your order")
    end

    it "still creates the order" do
      expect(Order.count).to eq(1)
    end

    it "emails the customer about the payment failure instead of a confirmation" do
      perform_enqueued_jobs
      perform_enqueued_jobs
      assert_performed_jobs 2

      mail = ActionMailer::Base.deliveries.last
      expect(mail.to).to eq([ "dave@example.com" ])
      expect(mail.subject).to eq("Pragmatic Store Payment Failed")
      expect(mail.body.encoded).to match("Card declined")
    end
  end

  describe "editing an existing order as a seller" do
    before { sign_in_as users(:one) }

    it "sets the ship date through the real edit form and sends a shipped notification" do
      order = orders(:one)

      visit edit_order_url(order)
      expect(page).to have_selector("h1", text: "Editing order")

      page.execute_script(<<~JS)
        document.getElementById("order_ship_date").value = "2026-09-20"
      JS

      click_button "Place Order"

      expect(page).to have_text("Order was successfully updated")
      expect(order.reload.ship_date).to eq(Date.new(2026, 9, 20))

      perform_enqueued_jobs

      mail = ActionMailer::Base.deliveries.last
      expect(mail.to).to eq([ order.email ])
      expect(mail.subject).to eq("Pragmatic Store Order Shipped")
    end
  end
end
