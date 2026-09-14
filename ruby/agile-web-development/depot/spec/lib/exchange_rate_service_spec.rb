require "rails_helper"

RSpec.describe ExchangeRateService do
  describe ".usd_to_eur and .usd_to_jpy" do
    it "return whatever the live rates request returns" do
      allow(described_class).to receive(:request_rates).and_return("EUR" => 0.85, "JPY" => 150.0)

      expect(described_class.usd_to_eur).to eq(0.85)
      expect(described_class.usd_to_jpy).to eq(150.0)
    end

    it "cache the fetched rates for a day instead of fetching on every call" do
      with_real_cache do
        expect(described_class).to receive(:fetch_live_rates).once.and_return("EUR" => 0.85, "JPY" => 150.0)

        expect(described_class.usd_to_eur).to eq(0.85)
        expect(described_class.usd_to_jpy).to eq(150.0)
      end
    end
  end

  describe ".fetch_live_rates" do
    it "falls back to the fixed rates if the live rates request raises" do
      allow(described_class).to receive(:request_rates).and_raise(Timeout::Error)

      expect(described_class.fetch_live_rates).to eq(described_class::FALLBACK_RATES)
    end
  end

  describe ".request_rates" do
    it "parses the rates out of a successful Frankfurter response" do
      stub_http_response(success: true, body: '{"amount":1.0,"base":"USD","rates":{"EUR":0.86,"JPY":154.0}}')

      expect(described_class.request_rates).to eq("EUR" => 0.86, "JPY" => 154.0)
    end

    it "raises if the response isn't successful" do
      stub_http_response(success: false, code: "503")

      expect { described_class.request_rates }.to raise_error(RuntimeError)
    end

    it "raises if the response is missing an expected currency" do
      stub_http_response(success: true, body: '{"amount":1.0,"base":"USD","rates":{"EUR":0.86}}')

      expect { described_class.request_rates }.to raise_error(RuntimeError)
    end
  end

  # Test env runs with :null_store (see config/environments/test.rb), which
  # never actually caches -- swap in a real store to exercise the caching
  # behavior specifically.
  def with_real_cache
    original_cache = Rails.cache
    Rails.cache = ActiveSupport::Cache::MemoryStore.new
    yield
  ensure
    Rails.cache = original_cache
  end

  def stub_http_response(success:, body: nil, code: nil)
    # Undo rails_helper's blanket .request_rates stub so the real method
    # body -- the thing these specs exist to exercise -- actually runs.
    allow(described_class).to receive(:request_rates).and_call_original

    http = instance_double(Net::HTTP)
    allow(http).to receive(:use_ssl=)
    allow(http).to receive(:open_timeout=)
    allow(http).to receive(:read_timeout=)

    response = instance_double(Net::HTTPResponse)
    allow(response).to receive(:is_a?).with(Net::HTTPSuccess).and_return(success)
    allow(response).to receive(:body).and_return(body) if body
    allow(response).to receive(:code).and_return(code) if code

    allow(http).to receive(:get).and_return(response)
    allow(Net::HTTP).to receive(:new).and_return(http)
  end
end
