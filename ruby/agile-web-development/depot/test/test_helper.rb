ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"
require "mocha/minitest"

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # ExchangeRateService makes a real HTTP call in .request_rates; stub it
    # globally so no test ever depends on network access. Tests that care
    # about the fetch/fallback/caching behavior itself re-stub this locally.
    setup do
      ExchangeRateService.stubs(:request_rates).returns(ExchangeRateService::FALLBACK_RATES)
    end

    # Add more helper methods to be used by all tests here...
    def login_as(user)
      get users_path
      post session_path, params: {
        email_address: user.email_address,
        password: "password"
      }
    end

    def logout
      delete session_path
    end

    # Kept as a reference for stubbing without a mocking dependency. Prefer
    # Mocha (Pago.stubs/.expects) for new tests -- see test/models/order_test.rb.
    # Minitest 6 dropped minitest/mock, so this can't use Object#stub either;
    # it redefines Pago's class method by hand and restores it after.
    def with_pago_result(result)
      original_make_payment = Pago.method(:make_payment)
      Pago.define_singleton_method(:make_payment) { |**| result }
      yield
    ensure
      Pago.define_singleton_method(:make_payment, original_make_payment)
    end
  end
end
