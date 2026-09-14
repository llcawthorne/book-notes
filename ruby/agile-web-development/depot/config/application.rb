require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Depot
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 8.0

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks])

    # Territory locales (e.g. "es-ES" for Spain) fall back to their base
    # language, and any locale falls back to config.i18n.default_locale, for
    # keys their own config/locales/*.yml file doesn't define -- so es-ES
    # only needs to override what's actually different (currency format),
    # reusing the existing Spanish UI text for everything else.
    config.i18n.fallbacks = true

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # Rails defaults to UTC when this isn't set, which is why the sidebar's
    # "page loaded at" timestamp (Time.current) was showing UTC instead of
    # local time.
    config.time_zone = "Eastern Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")
  end
end
