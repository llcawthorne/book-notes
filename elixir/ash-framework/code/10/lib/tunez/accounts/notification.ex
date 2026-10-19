#---
# Excerpted from "Ash Framework",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material,
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose.
# Visit https://pragprog.com/titles/ldash for more book information.
#---
# The final version of this file at the end of this chapter can be found at
# https://github.com/sevenseacat/tunez/blob/end-of-chapter-10/lib/tunez/accounts/notification.ex

# ------------------------------------------------------------------------------
# Context: Setting up the attributes and relationships for the resource
postgres do
  # ...

  references do
    reference :user, index?: true, on_delete: :delete
    reference :album, on_delete: :delete
  end
end

attributes do
  uuid_primary_key :id

  create_timestamp :inserted_at
end

relationships do
  belongs_to :user, Tunez.Accounts.User do
    allow_nil? false
  end

  belongs_to :album, Tunez.Music.Album do
    allow_nil? false
  end
end
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Context: Adding a create action so notifications can be created when new albums
# are created
actions do
  create :create do
    accept [:user_id, :album_id]
  end
end
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Context: Authorization for the new `create` action
defmodule Tunez.Accounts.Notification do
  use Ash.Resource,
    # ...
    authorizers: [Ash.Policy.Authorizer]

  policies do
    policy action(:create) do
      forbid_if always()
    end
  end

  # ...
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Context: Adding a read action, to read all notifications for a given user
actions do
  # ...

  read :for_user do
    prepare build(load: [album: [:artist]], sort: [inserted_at: :desc])
    filter expr(user_id == ^actor(:id))
  end
end
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Context: Authorizing the new `for_user` action
policies do
  policy action(:for_user) do
    authorize_if actor_present()
  end

  # ...
end
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Context: Adding a destroy action for dismissing notifications
actions do
  defaults [:destroy]

  # ...
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Context: Authorizing the new `destroy` action
policies do
  # ...

  policy action(:destroy) do
    authorize_if relates_to_actor_via(:user)
  end
end
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Context: Enabling the pubsub notifier mechanism
defmodule Tunez.Accounts.Notification do
  use Ash.Resource,
    otp_app: :tunez,
    domain: Tunez.Accounts,
    data_layer: AshPostgres.DataLayer,
    authorizers: [Ash.Policy.Authorizer],
    notifiers: [Ash.Notifier.PubSub]
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Context: Sending pubsub broadcasts after every Notification create
defmodule Tunez.Accounts.Notification do
  # ...

  pub_sub do
    prefix "notifications"
    module TunezWeb.Endpoint
    publish :create, [:user_id]
  end
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Context: Limiting what data is sent as part of a pubsub notification
pub_sub do
  prefix "notifications"
  module TunezWeb.Endpoint

  transform fn notification ->
    Map.take(notification.data, [:id, :user_id, :album_id])
  end

  publish :create, [:user_id]
end
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Context: Sending pubsub broadcasts after every Notification destroy
pub_sub do
  # ...

  publish :create, [:user_id]
  publish :destroy, [:user_id]
end
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Context: Removing the database cascade to run dependent deletes in code
postgres do
  # ...

  references do
    reference :user, index?: true, on_delete: :delete
    reference :album
  end
end
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Context: Adding a default read action
actions do
  defaults [:read, :destroy]
  # ...
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Context: Adding a policy for the default read action
policies do
  policy action(:read) do
    authorize_if expr(album.can_manage_album?)
  end

  # ...

  policy action(:destroy) do
    authorize_if expr(album.can_manage_album?)
    authorize_if relates_to_actor_via(:user)
  end
# ------------------------------------------------------------------------------
