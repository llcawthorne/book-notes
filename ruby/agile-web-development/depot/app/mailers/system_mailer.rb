class SystemMailer < ApplicationMailer
  default from: "Sam Ruby <depot@example.com>"

  def error_notification(message)
    @message = message
    @occurred_at = Time.current

    mail to: "admin@example.com", subject: "Pragmatic Store Application Error"
  end
end
