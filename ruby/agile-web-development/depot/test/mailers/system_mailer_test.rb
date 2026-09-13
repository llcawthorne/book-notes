require "test_helper"

class SystemMailerTest < ActionMailer::TestCase
  test "error_notification" do
    mail = SystemMailer.error_notification("Attempt to access invalid cart 999")
    assert_equal "Pragmatic Store Application Error", mail.subject
    assert_equal [ "admin@example.com" ], mail.to
    assert_equal [ "depot@example.com" ], mail.from
    assert_match "Attempt to access invalid cart 999", mail.body.encoded
  end
end
