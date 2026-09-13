class OrderMailer < ApplicationMailer
  default from: "Sam Ruby <depot@example.com>"
  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.order_mailer.received.subject
  #
  def received(order)
    @order = order

    mail to: order.email, subject: "Pragmatic Store Order Confirmation"
  end

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.order_mailer.shipped.subject
  #
  def shipped(order)
    @order = order

    mail to: order.email, subject: "Pragmatic Store Order Shipped"
  end

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.order_mailer.payment_failed.subject
  #
  def payment_failed(order, error_message)
    @order = order
    @error_message = error_message

    mail to: order.email, subject: "Pragmatic Store Payment Failed"
  end
end
