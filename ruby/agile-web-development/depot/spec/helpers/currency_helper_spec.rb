require "rails_helper"

RSpec.describe CurrencyHelper, type: :helper do
  describe "#localized_price" do
    it "leaves the price in USD for English and the generic (Mexican/US) Spanish locale" do
      [ :en, :es ].each do |locale|
        I18n.with_locale(locale) do
          expect(helper.localized_price(9.99)).to eq(9.99)
        end
      end
    end

    it "converts to EUR for Spain, Germany, and Italy" do
      [ :"es-ES", :de, :it ].each do |locale|
        I18n.with_locale(locale) do
          expect(helper.localized_price(9.99)).to eq(9.99 * ExchangeRateService.usd_to_eur)
        end
      end
    end

    it "converts to JPY for Japanese" do
      I18n.with_locale(:ja) do
        expect(helper.localized_price(9.99)).to eq(9.99 * ExchangeRateService.usd_to_jpy)
      end
    end
  end

  describe "#localized_currency" do
    it "formats the converted amount using the locale's currency" do
      I18n.with_locale(:en) { expect(helper.localized_currency(9.99)).to eq("$9.99") }
      I18n.with_locale(:de) { expect(helper.localized_currency(9.99)).to match(/€\z/) }
      I18n.with_locale(:ja) { expect(helper.localized_currency(9.99)).to match(/\A¥/) }
    end
  end
end
