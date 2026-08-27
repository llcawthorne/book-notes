#---
# Excerpted from "Agile Web Development with Rails 8",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material,
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose.
# Visit https://pragprog.com/titles/rails8 for more book information.
#---
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
      <td[^>]*>1<\/td>\s*
      <td>&times;<\/td>\s*
      <td[^>]*>\s*The\sPragmatic\sProgrammer\s*</td>
    }x, mail.body.to_s
  end
end
