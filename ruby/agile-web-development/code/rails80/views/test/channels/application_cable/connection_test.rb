#---
# Excerpted from "Agile Web Development with Rails 8",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material,
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose.
# Visit https://pragprog.com/titles/rails8 for more book information.
#---
require "test_helper"

class ApplicationCable::ConnectionTest < ActionCable::Connection::TestCase
  # test "connects with cookies" do
  #   cookies.signed[:user_id] = 42
  #
  #   connect
  #
  #   assert_equal connection.user_id, "42"
  # end
end
