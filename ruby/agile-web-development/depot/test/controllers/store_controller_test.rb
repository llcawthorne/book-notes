require "test_helper"

class StoreControllerTest < ActionDispatch::IntegrationTest
  def setup
    login_as users(:one)
  end

  test "should get index" do
    get store_index_url
    assert_response :success
    assert_select "nav a", minimum: 4
    assert_select "main ul li", 3
    assert_select "h2", "The Pragmatic Programmer"
    assert_select "div", /\$[,\d]+\.\d\d/
  end

  test "each product's image is a clickable add-to-cart control" do
    get store_index_url

    assert_select "form[action*='/line_items'] img", 3
  end

  test "shows prices converted to euros for a euro-zone locale" do
    get store_index_url(locale: "de")
    assert_response :success
    assert_select "div", /€/
    assert_select "div", { text: /\$/, count: 0 }
  end

  test "still shows prices in dollars for the generic (Mexican/US) Spanish locale" do
    get store_index_url(locale: "es")
    assert_response :success
    assert_select "div", /\$US/
    assert_select "div", { text: /€/, count: 0 }
  end

  test "shows prices converted to yen for Japanese, with descriptions falling back to English" do
    get store_index_url(locale: "ja")
    assert_response :success
    assert_select "div", /¥[,\d]+/
    assert_select "div", { text: /\$/, count: 0 }
    assert_match "Your Journey TO Mastery", response.body
  end

  test "shows a localized timestamp, in the app's configured time zone, for when the page was rendered" do
    travel_to Time.utc(2026, 9, 13, 14, 30) do
      get store_index_url(locale: "de")
      assert_match I18n.l(Time.current, format: :short, locale: :de), response.body

      get store_index_url(locale: "ja")
      assert_match I18n.l(Time.current, format: :short, locale: :ja), response.body
    end
  end
end
