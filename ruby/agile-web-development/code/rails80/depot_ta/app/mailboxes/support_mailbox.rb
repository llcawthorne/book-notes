#---
# Excerpted from "Agile Web Development with Rails 8",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material,
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose.
# Visit https://pragprog.com/titles/rails8 for more book information.
#---
class SupportMailbox < ApplicationMailbox
  def process
    puts "START SupportMailbox#process:"
    puts "From : #{mail.from_address}"
    puts "Subject: #{mail.subject}"
    puts "Body : #{mail.body}"
    puts "END SupportMailbox#process:"
  end
end
