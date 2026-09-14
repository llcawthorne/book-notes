require "net/http"
require "json"

# Fetches real USD exchange rates from Frankfurter (frankfurter.dev), a
# free wrapper around the European Central Bank's daily reference rates --
# no API key or registration required. It covers ~30 currencies (EUR, JPY,
# GBP, MXN, and more); this app only prices in the two it actually
# displays. Cached for a day since the source data itself only updates
# once a day, and falls back to a fixed approximation if the request
# fails for any reason, so a network hiccup degrades to "slightly stale
# price" instead of a broken storefront.
#
# Every automated test stubs .request_rates (see test/test_helper.rb and
# spec/rails_helper.rb) so the suite never makes a real network call.
class ExchangeRateService
  FALLBACK_RATES = { "EUR" => 0.92, "JPY" => 149.50 }.freeze

  FRANKFURTER_URI = URI(
    "https://api.frankfurter.dev/v1/latest?base=USD&symbols=#{FALLBACK_RATES.keys.join(',')}"
  )

  CACHE_KEY = "exchange_rate_service/usd_rates"

  def self.usd_to_eur
    rates.fetch("EUR")
  end

  def self.usd_to_jpy
    rates.fetch("JPY")
  end

  def self.rates
    Rails.cache.fetch(CACHE_KEY, expires_in: 1.day) { fetch_live_rates }
  end

  def self.fetch_live_rates
    request_rates
  rescue StandardError => e
    Rails.logger.error "ExchangeRateService: falling back to the fixed rates after #{e.class}: #{e.message}"
    FALLBACK_RATES
  end

  def self.request_rates
    http = Net::HTTP.new(FRANKFURTER_URI.host, FRANKFURTER_URI.port)
    http.use_ssl = true
    http.open_timeout = 5
    http.read_timeout = 5

    response = http.get(FRANKFURTER_URI.request_uri)
    raise "unexpected response #{response.code}" unless response.is_a?(Net::HTTPSuccess)

    rates = JSON.parse(response.body)["rates"]
    unless rates.is_a?(Hash) && FALLBACK_RATES.keys.all? { |currency| rates.key?(currency) }
      raise "response didn't include all expected rates"
    end

    rates
  end
end
