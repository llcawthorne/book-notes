#---
# Excerpted from "Ash Framework",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material,
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose.
# Visit https://pragprog.com/titles/ldash for more book information.
#---
# The final version of this file at the end of this chapter can be found at
# https://github.com/sevenseacat/tunez/blob/end-of-chapter-10/lib/tunez/accounts/changes/send_new_album_notifications.ex

# ------------------------------------------------------------------------------
# Context: Setting up the initial change module
defmodule Tunez.Accounts.Changes.SendNewAlbumNotifications do
  use Ash.Resource.Change

  @impl true
  def change(changeset, _opts, _context) do
    # Create notifications here!
    changeset
  end
end
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Context: Using a bulk action to generate notifications after creating an album
def change(changeset, _opts, _context) do
  Ash.Changeset.after_action(changeset, fn _changeset, album ->
    album = Ash.load!(album, artist: [:follower_relationships])

    album.artist.follower_relationships
    |> Enum.map(fn %{follower_id: follower_id} ->
      %{album_id: album.id, user_id: follower_id}
    end)
    |> Ash.bulk_create!(Tunez.Accounts.Notification, :create)

    {:ok, album}
  end)
end
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Context: Bypassing the authorization for the system `Notification.create`
album.artist.follower_relationships
|> Enum.map(fn %{follower_id: follower_id} ->
  %{album_id: album.id, user_id: follower_id}
end)
|> Ash.bulk_create!(Tunez.Accounts.Notification, :create,
  authorize?: false
)
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Context: Rewriting the change to use streaming for loading data
def change(changeset, _opts, _context) do
  changeset
  |> Ash.Changeset.after_action(fn _changeset, album ->
    Tunez.Music.followers_for_artist!(album.artist_id, stream?: true)
    |> Stream.map(fn %{follower_id: follower_id} ->
      %{album_id: album.id, user_id: follower_id}
    end)
    |> Ash.bulk_create!(Tunez.Accounts.Notification, :create,
      authorize?: false
    )

    {:ok, album}
  end)
end
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Context: Enabling Ash notifications to be generated and sent
def change(changeset, _opts, _context) do
  changeset
  |> Ash.Changeset.after_action(fn _changeset, album ->
    Tunez.Music.followers_for_artist!(album.artist_id, stream?: true)
    |> Stream.map(fn %{follower_id: follower_id} ->
      %{album_id: album.id, user_id: follower_id}
    end)
    |> Ash.bulk_create!(Tunez.Accounts.Notification, :create,
      authorize?: false, notify?: true
    )

    {:ok, album}
  end)
end
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Context: Making the module atomic
defmodule Tunez.Accounts.Changes.SendNewAlbumNotifications do
  # ...

  @impl true
  def atomic(changeset, opts, context) do
    {:ok, change(changeset, opts, context)}
  end
end
# ------------------------------------------------------------------------------
