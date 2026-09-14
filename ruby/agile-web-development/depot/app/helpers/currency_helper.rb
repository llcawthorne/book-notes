module CurrencyHelper
  # Which ExchangeRateService method converts a customer-facing locale's
  # price away from the USD stored on the product. Locales absent from
  # this map (English, and the generic "es" for Mexican/US Spanish
  # speakers) are left in dollars.
  CURRENCY_CONVERSIONS = {
    "es-ES": :usd_to_eur,
    de:      :usd_to_eur,
    it:      :usd_to_eur,
    ja:      :usd_to_jpy
  }.freeze

  def localized_price(usd_amount)
    conversion = CURRENCY_CONVERSIONS[I18n.locale]
    conversion ? usd_amount * ExchangeRateService.public_send(conversion) : usd_amount
  end

  def localized_currency(usd_amount)
    number_to_currency(localized_price(usd_amount))
  end
end
