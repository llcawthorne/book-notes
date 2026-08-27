#---
# Excerpted from "Agile Web Development with Rails 8",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material,
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose.
# Visit https://pragprog.com/titles/rails8 for more book information.
#---
class CreateSupportRequests < ActiveRecord::Migration[8.0]
  def change
    create_table :support_requests do |t|
      t.string :email, comment: "Email of the submitter"
      t.string :subject, comment: "Subject of their support email"
      t.text :body, comment: "Body of their support email"
      t.references :order,
                    foreign_key: true,
                    comment: "their most recent order, if applicable"
      t.timestamps
    end
  end
end
