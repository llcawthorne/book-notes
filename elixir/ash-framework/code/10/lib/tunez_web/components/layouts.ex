#---
# Excerpted from "Ash Framework",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material,
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose.
# Visit https://pragprog.com/titles/ldash for more book information.
#---
# The final version of this file at the end of this chapter can be found at
# https://github.com/sevenseacat/tunez/blob/end-of-chapter-10/lib/tunez_web/components/layouts.ex

# ------------------------------------------------------------------------------
# Context: Rendering the NotificationsLive liveview for displaying notifications
<%= if @current_user do %>
  {live_render(@socket, TunezWeb.NotificationsLive, sticky: true,
    id: :notifications_container)}
  <% # ... %>
# ------------------------------------------------------------------------------
