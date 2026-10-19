#---
# Excerpted from "Ash Framework",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material,
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose.
# Visit https://pragprog.com/titles/ldash for more book information.
#---
# The final version of this file at the end of this chapter can be found at
# https://github.com/sevenseacat/tunez/blob/end-of-chapter-10/lib/tunez_web/live/notifications_live.ex

# ------------------------------------------------------------------------------
# Context: Replacing the hardcoded list with a read action
def mount(_params, _session, socket) do
  notifications = Tunez.Accounts.notifications_for_user!(
    actor: socket.assigns.current_user
  )
  {:ok, assign(socket, notifications: notifications)}
end
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Context: Loading the current user in the nested liveview process
defmodule TunezWeb.NotificationsLive do
  use TunezWeb, :live_view

  on_mount {TunezWeb.LiveUserAuth, :current_user}

  def mount(_params, _session, socket) do
    # ...
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Context: To actually process the notification dismissal
def handle_event("dismiss-notification", %{"id" => id}, socket) do
  notification = Enum.find(socket.assigns.notifications, &(&1.id == id))

  Tunez.Accounts.dismiss_notification(
    notification,
    actor: socket.assigns.current_user
  )

  notifications = Enum.reject(socket.assigns.notifications, &(&1.id == id))
  {:noreply, assign(socket, notifications: notifications)}
end
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Context: Subscribing to pubsub messages for new notifications
def mount(_params, _session, socket) do
  # ...

  if connected?(socket) do
    "notifications:#{socket.assigns.current_user.id}"
    |> TunezWeb.Endpoint.subscribe()
  end

  {:ok, assign(socket, notifications: notifications)}
end
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Context: Receiving the pubsub messages
def handle_info(%{topic: "notifications:" <> _}, socket) do
  notifications = Tunez.Accounts.notifications_for_user!(
    actor: socket.assigns.current_user
  )

  {:noreply, assign(socket, notifications: notifications)}
end
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Context: Cleaning up the logic for dismissing a notification - removing the
# notification will be handled via another pubsub message
def handle_event("dismiss-notification", %{"id" => id}, socket) do
  notification = Enum.find(socket.assigns.notifications, &(&1.id == id))

  Tunez.Accounts.dismiss_notification(
    notification,
    actor: socket.assigns.current_user
  )

  {:noreply, socket}
end
# ------------------------------------------------------------------------------
