class OrderMailer < ApplicationMailer
  default from: "Sam Ruby <depot@example.com>"

  # Wrapping the whole action body -- not just the view render -- in
  # I18n.with_locale matters here: mail() renders the templates immediately
  # when called, so the subject (t(".subject")) and the body must both be
  # produced while the locale override is active. This runs in a background
  # job (see ChargeOrderJob), which has no request to inherit I18n.locale
  # from, hence order.locale being captured at checkout time in the first
  # place (OrdersController#create).
  def received(order)
    I18n.with_locale(order.locale) do
      @order = order
      mail to: order.email, subject: t(".subject")
    end
  end

  def shipped(order)
    I18n.with_locale(order.locale) do
      @order = order
      mail to: order.email, subject: t(".subject")
    end
  end

  def payment_failed(order, error_message)
    I18n.with_locale(order.locale) do
      @order = order
      @error_message = error_message
      mail to: order.email, subject: t(".subject")
    end
  end
end
