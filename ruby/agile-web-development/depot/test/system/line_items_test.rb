require "application_system_test_case"

class LineItemsTest < ApplicationSystemTestCase
  include ActiveJob::TestHelper

  test "shows a friendly alert and notifies the system administrator when a product no longer exists" do
    product = products(:one)
    dom_id = ActionView::RecordIdentifier.dom_id(product)

    visit store_index_url

    # Simulate another admin deleting the product while this page is
    # already loaded -- the customer's "Add to Cart" button goes stale.
    product.destroy!

    within("##{dom_id}") { click_on "Add to Cart", match: :first }

    assert_text "no longer available"

    perform_enqueued_jobs

    mail = ActionMailer::Base.deliveries.last
    assert_equal [ "admin@example.com" ], mail.to
    assert_equal "Pragmatic Store Application Error", mail.subject
    assert_match(/invalid product/, mail.body.encoded)
  end
end
