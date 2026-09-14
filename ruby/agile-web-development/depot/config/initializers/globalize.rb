# Fall back to the default locale (English) when a translation is missing
# for the current locale, e.g. a product with no German description yet
# still shows its English one. Built from I18n.available_locales so a new
# config/locales/*.yml file picks up fallback support automatically --
# no per-locale wiring here when another language is added later.
#
# Territory variants (e.g. "es-ES" for Spain, layered on top of the plain
# "es" used for Mexican/US Spanish speakers) fall back to their base
# language before English -- so es-ES reuses the existing Spanish
# description instead of dropping all the way to English -- as long as
# both the variant and its base language have their own locale files.
#
# Globalize.fallbacks is backed by RequestStore (thread/execution-local
# storage), which Rails clears at the start of every request, job, and
# runner invocation -- so it can't just be set once here at boot. Use the
# executor's to_run hook instead, which fires at the start of every one of
# those, to set it fresh each time.
Rails.application.executor.to_run do
  Globalize.fallbacks = I18n.available_locales.index_with do |locale|
    base_language = locale.to_s.split("-").first.to_sym

    chain = [ locale ]
    chain << base_language if base_language != locale && I18n.available_locales.include?(base_language)
    chain << I18n.default_locale

    chain.uniq
  end
end
