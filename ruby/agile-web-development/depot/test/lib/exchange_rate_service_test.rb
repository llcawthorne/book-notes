require "test_helper"

class ExchangeRateServiceTest < ActiveSupport::TestCase
  test "usd_to_eur and usd_to_jpy return whatever the live rates request returns" do
    ExchangeRateService.stubs(:request_rates).returns("EUR" => 0.85, "JPY" => 150.0)

    assert_equal 0.85, ExchangeRateService.usd_to_eur
    assert_equal 150.0, ExchangeRateService.usd_to_jpy
  end

  test "falls back to the fixed rates if the live rates request raises" do
    ExchangeRateService.stubs(:request_rates).raises(Timeout::Error)

    assert_equal ExchangeRateService::FALLBACK_RATES, ExchangeRateService.fetch_live_rates
  end

  test "request_rates parses the rates out of a successful Frankfurter response" do
    stub_http_response(success: true, body: '{"amount":1.0,"base":"USD","rates":{"EUR":0.86,"JPY":154.0}}')

    assert_equal({ "EUR" => 0.86, "JPY" => 154.0 }, ExchangeRateService.request_rates)
  end

  test "request_rates raises if the response isn't successful" do
    stub_http_response(success: false, code: "503")

    assert_raises(RuntimeError) { ExchangeRateService.request_rates }
  end

  test "request_rates raises if the response is missing an expected currency" do
    stub_http_response(success: true, body: '{"amount":1.0,"base":"USD","rates":{"EUR":0.86}}')

    assert_raises(RuntimeError) { ExchangeRateService.request_rates }
  end

  test "caches the fetched rates for a day instead of fetching on every call" do
    with_real_cache do
      ExchangeRateService.expects(:fetch_live_rates).once.returns("EUR" => 0.85, "JPY" => 150.0)

      assert_equal 0.85, ExchangeRateService.usd_to_eur
      assert_equal 150.0, ExchangeRateService.usd_to_jpy
    end
  end

  private

    # Test env runs with :null_store (see config/environments/test.rb),
    # which never actually caches -- swap in a real store to exercise
    # the caching behavior specifically.
    def with_real_cache
      original_cache = Rails.cache
      Rails.cache = ActiveSupport::Cache::MemoryStore.new
      yield
    ensure
      Rails.cache = original_cache
    end

    def stub_http_response(success:, body: nil, code: nil)
      # Undo test_helper's blanket .request_rates stub so the real method
      # body -- the thing these tests exist to exercise -- actually runs.
      ExchangeRateService.unstub(:request_rates)

      http = mock("http")
      http.stubs(:use_ssl=)
      http.stubs(:open_timeout=)
      http.stubs(:read_timeout=)

      response = mock("response")
      response.stubs(:is_a?).with(Net::HTTPSuccess).returns(success)
      response.stubs(:body).returns(body) if body
      response.stubs(:code).returns(code) if code

      http.stubs(:get).returns(response)
      Net::HTTP.stubs(:new).returns(http)
    end
end
