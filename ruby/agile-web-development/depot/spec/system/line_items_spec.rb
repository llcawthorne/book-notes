require "rails_helper"

RSpec.describe "LineItems", type: :system do
  include ActiveJob::TestHelper

  fixtures :all

  describe "adding a stale product to the cart" do
    it "shows a friendly alert and notifies the system administrator" do
      product = products(:one)
      dom_id = ActionView::RecordIdentifier.dom_id(product)

      visit store_index_url

      # Simulate another admin deleting the product while this page is
      # already loaded -- the customer's "Add to Cart" button goes stale.
      product.destroy!

      within("##{dom_id}") { click_on "Add to Cart", match: :first }

      expect(page).to have_text("no longer available")

      perform_enqueued_jobs

      mail = ActionMailer::Base.deliveries.last
      expect(mail.to).to eq([ "admin@example.com" ])
      expect(mail.subject).to eq("Pragmatic Store Application Error")
      expect(mail.body.encoded).to match(/invalid product/)
    end
  end
end
