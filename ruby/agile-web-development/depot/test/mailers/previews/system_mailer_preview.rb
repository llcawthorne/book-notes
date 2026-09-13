# Preview all emails at http://localhost:3000/rails/mailers/system_mailer
class SystemMailerPreview < ActionMailer::Preview
  # Preview this email at http://localhost:3000/rails/mailers/system_mailer/error_notification
  def error_notification
    SystemMailer.error_notification("Attempt to access invalid cart 999")
  end
end
