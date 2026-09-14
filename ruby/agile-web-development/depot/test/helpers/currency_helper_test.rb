require "test_helper"

class CurrencyHelperTest < ActionView::TestCase
  test "prices in USD for English and the generic (Mexican/US) Spanish locale" do
    [ :en, :es ].each do |locale|
      I18n.with_locale(locale) do
        assert_equal 9.99, localized_price(9.99)
      end
    end
  end

  test "converts to EUR for Spain, Germany, and Italy" do
    [ :"es-ES", :de, :it ].each do |locale|
      I18n.with_locale(locale) do
        assert_equal 9.99 * ExchangeRateService.usd_to_eur, localized_price(9.99)
      end
    end
  end

  test "converts to JPY for Japanese" do
    I18n.with_locale(:ja) do
      assert_equal 9.99 * ExchangeRateService.usd_to_jpy, localized_price(9.99)
    end
  end

  test "localized_currency formats the converted amount using the locale's currency" do
    I18n.with_locale(:en) { assert_equal "$9.99", localized_currency(9.99) }
    I18n.with_locale(:de) { assert_match(/€\z/, localized_currency(9.99)) }
    I18n.with_locale(:ja) { assert_match(/\A¥/, localized_currency(9.99)) }
  end
end
