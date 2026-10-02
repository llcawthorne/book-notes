require "rails_helper"

RSpec.describe "Store", type: :system do
  fixtures :all

  describe "product broadcast highlight" do
    it "flashes a product's card when a turbo-stream replace targets it" do
      product = products(:pragprog)
      dom_id = ActionView::RecordIdentifier.dom_id(product)

      visit store_index_url
      expect(page).to have_selector("##{dom_id}")
      expect(page).to have_no_selector("##{dom_id}.product-highlight")

      # Simulate the ActionCable broadcast arriving, without needing a real
      # second session or background job round-trip: build the same
      # <turbo-stream action="replace"> element Turbo would receive over the
      # wire and let the page's own JS process it.
      page.execute_script(<<~JS, dom_id)
        const target = document.getElementById(arguments[0])
        const stream = document.createElement("turbo-stream")
        stream.setAttribute("action", "replace")
        stream.setAttribute("target", arguments[0])
        const template = document.createElement("template")
        template.innerHTML = target.outerHTML
        stream.appendChild(template)
        document.body.appendChild(stream)
      JS

      expect(page).to have_selector("##{dom_id}.product-highlight")
    end
  end

  describe "line item highlight" do
    it "highlights the line item just added to the cart" do
      product = products(:pragprog)
      dom_id = ActionView::RecordIdentifier.dom_id(product)

      visit store_index_url
      within("##{dom_id}") { click_on "Add to Cart", match: :first }

      expect(page).to have_css("tr.line-item-highlight", text: product.title)
    end
  end

  describe "cart visibility" do
    it "reveals the cart when adding an item and hides it again when emptied" do
      visit store_index_url

      expect(page).to have_no_content("Your Cart")

      click_on "Add to Cart", match: :first

      expect(page).to have_content("Your Cart")
      expect(page).to have_button("Empty cart")

      click_on "Empty cart"

      expect(page).to have_no_content("Your Cart")
    end
  end
end
