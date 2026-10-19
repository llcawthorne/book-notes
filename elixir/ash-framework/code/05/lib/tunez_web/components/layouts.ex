#---
# Excerpted from "Ash Framework",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material,
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose.
# Visit https://pragprog.com/titles/ldash for more book information.
#---
# The final version of this file at the end of this chapter can be found at
# https://github.com/sevenseacat/tunez/blob/end-of-chapter-5/lib/tunez_web/components/layouts.ex

# ------------------------------------------------------------------------------
# Context: Adding current user information/sign in and register buttons to the top navigation
<div class="flex items-center w-full p-4 pb-2 border-b-2 border-primary-600">
  <div class="flex-1 mr-4">
    <% # ... %>
  </div>
  <.user_info current_user={@current_user} socket={@socket} />
</div>
# ------------------------------------------------------------------------------
