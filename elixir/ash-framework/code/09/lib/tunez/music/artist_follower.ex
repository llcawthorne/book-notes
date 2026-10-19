#---
# Excerpted from "Ash Framework",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material,
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose.
# Visit https://pragprog.com/titles/ldash for more book information.
#---
# The final version of this file at the end of this chapter can be found at
# https://github.com/sevenseacat/tunez/blob/end-of-chapter-9/lib/tunez/music/artist_follower.ex

# ------------------------------------------------------------------------------
# Context: Linking the resource to the artist being followed and the user doing
# the following
defmodule Tunez.Music.ArtistFollower do
  # ...

  relationships do
    belongs_to :artist, Tunez.Music.Artist do
      primary_key? true
      allow_nil? false
    end

    belongs_to :follower, Tunez.Accounts.User do
      primary_key? true
      allow_nil? false
    end
  end
end
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Context: Deleting ArtistFollowers when the artist or follower is deleted
postgres do
  # ...

  references do
    reference :artist, on_delete: :delete, index?: true
    reference :follower, on_delete: :delete
  end
end
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Context: Setting up basic actions and policies
defmodule Tunez.Music.ArtistFollower do
  use Ash.Resource,
    # ...
    authorizers: [Ash.Policy.Authorizer]

  # ...

  actions do
    defaults [:read]
  end

  policies do
    policy action_type(:read) do
      authorize_if always()
    end
  end
end
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Context: Setting up a create action so a user can follow an artist
create :create do
  accept [:artist_id]

  change relate_actor(:follower, allow_nil?: false)
end
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Context: Adding a policy to define who can follow artists
policies do
  # ...

  policy action_type(:create) do
    authorize_if actor_present()
  end
end
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Context: Adding a filter to restrict which follower relationships are deleted
destroy :destroy do
  argument :artist_id, :uuid do
    allow_nil? false
  end

  change filter(expr(artist_id == ^arg(:artist_id) &&
    follower_id == ^actor(:id)))
end
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Context: Adding a policy to restrict which follower relationships can be deleted
policies do
  # ...

  policy action_type(:destroy) do
    authorize_if actor_present()
  end
end
# ------------------------------------------------------------------------------
