#---
# Excerpted from "Ash Framework",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material,
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose.
# Visit https://pragprog.com/titles/ldash for more book information.
#---
# The final version of this file at the end of this chapter can be found at
# https://github.com/sevenseacat/tunez/blob/end-of-chapter-10/lib/tunez/music/album.ex

# ------------------------------------------------------------------------------
# Context: Adding a new change to send notifications for all create actions
changes do
  change Tunez.Accounts.Changes.SendNewAlbumNotifications, on: [:create]
  # ...
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Context: Adding the relationship from Track -> Notification
relationships do
  # ...

  has_many :notifications, Tunez.Accounts.Notification
end
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Context: Writing a new `destroy` action to cascade deletes for notifications
actions do
  defaults [:read]

  destroy :destroy do
    primary? true
    change cascade_destroy(:notifications, return_notifications?: true,
      after_action?: false)
  end

  # ...
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Context: Current policies that determine if a user can delete an album
policies do
  bypass actor_attribute_equals(:role, :admin) do
    authorize_if always()
  end

  # ...

  policy action_type([:update, :destroy]) do
    authorize_if expr(
      ^actor(:role) == :editor and created_by_id == ^actor(:id)
    )
  end
end
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Context: Extracting policy logic to an expression for reuse
calculations do
  # ...

  calculate :can_manage_album?,
            :boolean,
            expr(
              ^actor(:role) == :admin or
              (^actor(:role) == :editor and created_by_id == ^actor(:id))
            )
end
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Context: Using the new calculation in the update/destroy policy
policy action_type([:update, :destroy]) do
  authorize_if expr(can_manage_album?)
end
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Context: Remove database cascades from Artist -> Album
defmodule Tunez.Music.Album do
  # ...

  postgres do
    # ...

    references do
      reference :artist, index?: true
    end
  end
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Context: Enabling AshOban
defmodule Tunez.Music.Album do
  use Ash.Resource,
    otp_app: :tunez,
    domain: Tunez.Music,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshOban, AshGraphql.Resource, AshJsonApi.Resource],
    authorizers: [Ash.Policy.Authorizer]
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Context: Configuring a trigger for the `send_new_album_notifications` action
defmodule Tunez.Music.Album do
  # ...

  oban do
    triggers do
      trigger :send_new_album_notifications do
        action :send_new_album_notifications
        queue :default
        scheduler_cron false
      end
    end
  end
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Context: Creating a new action to run as a background job
actions do
  # ...

  update :send_new_album_notifications do
    change Tunez.Accounts.Changes.SendNewAlbumNotifications
  end
end
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Context: Authorizing the `send_new_album_notifications` action using AshOban
policies do
  bypass AshOban.Checks.AshObanInteraction do
    authorize_if always()
  end

  # ...
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Context: Running the Oban job after creating an album
changes do
  change run_oban_trigger(:send_new_album_notifications), on: [:create]
  # ...
end
# ------------------------------------------------------------------------------
