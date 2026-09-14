class ApplicationController < ActionController::Base
  around_action :set_i18n_locale_from_params

  include Authentication
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  include ActiveStorage::SetCurrent

  # I18n.locale is thread-local, not request-local -- a plain
  # `I18n.locale = params[:locale]` would leak into whatever request the
  # same thread handles next (a real concern on a threaded server, not just
  # a test-isolation quirk). I18n.with_locale scopes the change to this
  # action and restores the prior locale afterward either way.
  def set_i18n_locale_from_params
    if params[:locale]
      if I18n.available_locales.map(&:to_s).include?(params[:locale])
        I18n.with_locale(params[:locale]) { yield }
        return
      else
        flash.now[:notice] =
          "#{params[:locale]} translation not available"
        logger.error flash.now[:notice]
      end
    end

    yield
  end

  private
    # Log the failure and let the system administrator know it happened,
    # in addition to whatever user-facing recovery the caller does next.
    def notify_admin_of_error(message)
      logger.error message
      SystemMailer.error_notification(message).deliver_later
    end
end
