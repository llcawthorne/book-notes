require "test_helper"

class OrderMailerTest < ActionMailer::TestCase
  test "received" do
    mail = OrderMailer.received(orders(:one))
    assert_equal "Pragmatic Store Order Confirmation", mail.subject
    assert_equal [ "dave@example.org" ], mail.to
    assert_equal [ "depot@example.com" ], mail.from
    assert_match /1 x The Pragmatic Programmer/, mail.body.encoded
  end

  test "shipped" do
    mail = OrderMailer.shipped(orders(:one))
    assert_equal "Pragmatic Store Order Shipped", mail.subject
    assert_equal [ "dave@example.org" ], mail.to
    assert_equal [ "depot@example.com" ], mail.from
    assert_match %r{
      <td[^>]*>\s*1\s*<\/td>\s*
      <td>&times;<\/td>\s*
      <td[^>]*>\s*The\sPragmatic\sProgrammer\s*</td>
    }x, mail.body.encoded
  end

  test "payment_failed" do
    mail = OrderMailer.payment_failed(orders(:one), "Card declined")
    assert_equal "Pragmatic Store Payment Failed", mail.subject
    assert_equal [ "dave@example.org" ], mail.to
    assert_equal [ "depot@example.com" ], mail.from
    assert_match "Card declined", mail.body.encoded
  end

  test "received renders in the order's captured locale, currency included" do
    orders(:one).update!(locale: "de")

    mail = OrderMailer.received(orders(:one))

    assert_equal "Pragmatic Store Bestellbestätigung", mail.subject
    assert_match "Vielen Dank für Ihre kürzliche Bestellung", mail.body.encoded
    assert_match "€", mail.body.encoded
  end

  test "received does not leak the order's locale into the current thread" do
    orders(:one).update!(locale: "de")
    OrderMailer.received(orders(:one))

    assert_equal :en, I18n.locale
  end
end
