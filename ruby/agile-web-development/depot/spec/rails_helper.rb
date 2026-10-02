# This file is copied to spec/ when you run 'rails generate rspec:install'
require 'spec_helper'
ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
# Prevent database truncation if the environment is production
abort("The Rails environment is running in production mode!") if Rails.env.production?
# Uncomment the line below in case you have `--require rails_helper` in the `.rspec` file
# that will avoid rails generators crashing because migrations haven't been run yet
# return unless Rails.env.test?
require 'rspec/rails'
require 'capybara/rspec'
require 'rspec/retry'
# Add additional requires below this line. Rails is not loaded until this point!

# Requires supporting ruby files with custom matchers and macros, etc, in
# spec/support/ and its subdirectories. Files matching `spec/**/*_spec.rb` are
# run as spec files by default. This means that files in spec/support that end
# in _spec.rb will both be required and run as specs, causing the specs to be
# run twice. It is recommended that you do not name files matching this glob to
# end with _spec.rb. You can configure this pattern with the --pattern
# option on the command line or in ~/.rspec, .rspec or `.rspec-local`.
#
# The following line is provided for convenience purposes. It has the downside
# of increasing the boot-up time by auto-requiring all files in the support
# directory. Alternatively, in the individual `*_spec.rb` files, manually
# require only the support files necessary.
#
Rails.root.glob('spec/support/**/*.rb').sort_by(&:to_s).each { |f| require f }

# Ensures that the test database schema matches the current schema file.
# If there are pending migrations it will invoke `db:test:prepare` to
# recreate the test database by loading the schema.
# If you are not using ActiveRecord, you can remove these lines.
begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  abort e.to_s.strip
end
RSpec.configure do |config|
  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_paths = [
    Rails.root.join('test/fixtures')
  ]

  # rspec-rails defaults raw file fixtures (file_fixture, and the
  # ActiveStorage::FixtureSet.blob calls in test/fixtures/active_storage/
  # blobs.yml) to spec/fixtures/files, independently of fixture_paths above
  # -- since this app keeps everything under test/fixtures, that default
  # pointed nowhere and silently broke any fixture image attachment.
  config.file_fixture_path = "test/fixtures/files"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true

  # Minitest gets this automatically from Rails 8's executor_around_test_case
  # default, which is how config/initializers/globalize.rb's
  # Rails.application.executor.to_run hook (setting Globalize.fallbacks) ends
  # up applied in those tests. RSpec doesn't wrap examples in the executor on
  # its own, so without this, model specs would see no fallback configured --
  # even though every real request or job always runs inside the executor.
  config.around do |example|
    Rails.application.executor.wrap { example.run }
  end

  # ExchangeRateService makes a real HTTP call in .request_rates; stub it
  # globally so no spec ever depends on network access. Specs that care
  # about the fetch/fallback/caching behavior itself re-stub this locally.
  config.before do
    allow(ExchangeRateService).to receive(:request_rates).and_return(ExchangeRateService::FALLBACK_RATES)
  end

  config.include ActiveSupport::Testing::TimeHelpers

  # You can uncomment this line to turn off ActiveRecord support entirely.
  # config.use_active_record = false

  # RSpec Rails uses metadata to mix in different behaviours to your tests,
  # for example enabling you to call `get` and `post` in request specs. e.g.:
  #
  #     RSpec.describe UsersController, type: :request do
  #       # ...
  #     end
  #
  # The different available types are documented in the features, such as in
  # https://rspec.info/features/8-0/rspec-rails
  #
  # You can also infer these behaviours automatically by location, e.g.
  # /spec/models would pull in the same behaviour as `type: :model` but this
  # behaviour is considered legacy and will be removed in a future version.
  #
  # To enable this behaviour uncomment the line below.
  # config.infer_spec_type_from_file_location!

  # Filter lines from Rails gems in backtraces.
  config.filter_rails_from_backtrace!
  # arbitrary gems may also be filtered via:
  # config.filter_gems_from_backtrace("gem name")

  # System specs spin up a real browser and are slow, so skip them by default.
  # Run `bin/rails spec:all` (or `INCLUDE_SYSTEM=1 bin/rails spec`) to include them.
  config.filter_run_excluding type: :system unless ENV["INCLUDE_SYSTEM"]

  config.include RequestHelpers, type: :request
  config.include SystemHelpers, type: :system

  # System specs drive the app from a real browser hitting a Puma server
  # thread, separate from the example's own thread. The fixture transaction's
  # connection must not be locked to the example's thread or that second
  # thread deadlocks waiting for it (mirrors what Rails' minitest parallelize
  # executor does for ActionDispatch::SystemTestCase).
  config.before(:context, type: :system) do
    self.class.lock_threads = false
  end

  # System specs pull in ActionDispatch::Integration::Runner, whose url
  # helpers (e.g. `store_index_url`) delegate through method_missing to a
  # separate integration_session that defaults its host to "www.example.com".
  # Force the driver on first so Capybara's server is booted, then point the
  # session at it, or `visit some_url` sends the real browser off to the
  # unreachable internet instead of the local test app.
  config.before(:each, type: :system) do
    # The default :selenium_chrome_headless driver doesn't set a window size,
    # so Chrome falls back to a small one. Combined with this app's fixed
    # sidebar, that makes Selenium's native (coordinate-based) click miss
    # elements it can plainly see, silently landing nowhere. Match Minitest's
    # ApplicationSystemTestCase driver, which sets an explicit size.
    unless instance_variable_get(:@driver)
      driven_by :selenium, using: :headless_chrome, screen_size: [ 1400, 1400 ]
    end
    server = Capybara.current_session.server
    self.host = "#{server.host}:#{server.port}" if server
  end

  # Browser automation carries a baseline flake rate -- Capybara + Selenium +
  # headless Chrome occasionally miss a click or race a page transition for
  # reasons that don't trace back to the app or the spec. Retry system specs
  # a couple of times before failing the run instead of chasing full
  # determinism out of every click.
  config.verbose_retry = true
  config.display_try_failure_messages = true
  config.retry_count_condition = ->(example) { example.metadata[:type] == :system ? 3 : 1 }
end

Capybara.default_max_wait_time = 10
