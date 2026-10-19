#---
# Excerpted from "Ash Framework",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material,
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose.
# Visit https://pragprog.com/titles/ldash for more book information.
#---
# The final version of this file at the end of this chapter can be found at
# https://github.com/sevenseacat/tunez/blob/end-of-chapter-10/lib/tunez/accounts.ex

# ------------------------------------------------------------------------------
# Context: Defining the code interface for the `Notification.for_user` action
resources do
  # ...

  resource Tunez.Accounts.Notification do
    define :notifications_for_user, action: :for_user
  end
end
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Context: Defining the code interface for the `Notification.destroy` action
resources do
  # ...

  resource Tunez.Accounts.Notification do
    define :notifications_for_user, action: :for_user
    define :dismiss_notification, action: :destroy
  end
end
# ------------------------------------------------------------------------------
