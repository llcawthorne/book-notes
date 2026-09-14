require "rails_helper"

RSpec.describe "Store", type: :request do
  fixtures :users, :products, :product_translations

  before { login_as users(:one) }

  describe "GET /" do
    it "renders the catalog" do
      get store_index_url

      expect(response).to be_successful
      assert_select "nav a", minimum: 4
      assert_select "main ul li", 3
      assert_select "h2", "The Pragmatic Programmer"
      assert_select "div", /\$[,\d]+\.\d\d/
    end

    it "makes each product's image a clickable add-to-cart control" do
      get store_index_url

      assert_select "form[action*='/line_items'] img", 3
    end

    it "shows prices converted to euros for a euro-zone locale" do
      get store_index_url(locale: "de")

      expect(response).to be_successful
      assert_select "div", /€/
      assert_select "div", { text: /\$/, count: 0 }
    end

    it "still shows prices in dollars for the generic (Mexican/US) Spanish locale" do
      get store_index_url(locale: "es")

      expect(response).to be_successful
      assert_select "div", /\$US/
      assert_select "div", { text: /€/, count: 0 }
    end

    it "shows prices converted to yen for Japanese, with descriptions falling back to English" do
      get store_index_url(locale: "ja")

      expect(response).to be_successful
      assert_select "div", /¥[,\d]+/
      assert_select "div", { text: /\$/, count: 0 }
      expect(response.body).to include("Your Journey TO Mastery")
    end

    it "shows a localized timestamp, in the app's configured time zone, for when the page was rendered" do
      travel_to Time.utc(2026, 9, 13, 14, 30) do
        get store_index_url(locale: "de")
        expect(response.body).to include(I18n.l(Time.current, format: :short, locale: :de))

        get store_index_url(locale: "ja")
        expect(response.body).to include(I18n.l(Time.current, format: :short, locale: :ja))
      end
    end
  end
end
