#---
# Excerpted from "Ash Framework",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material,
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose.
# Visit https://pragprog.com/titles/ldash for more book information.
#---
# The final version of this file at the end of this chapter can be found at
# https://github.com/sevenseacat/tunez/blob/end-of-chapter-9/lib/tunez/music/artist.ex

# ------------------------------------------------------------------------------
# Context: Linking artists and their followers
relationships do
  # ...

  has_many :follower_relationships, Tunez.Music.ArtistFollower

  many_to_many :followers, Tunez.Accounts.User do
    join_relationship :follower_relationships
    destination_attribute_on_join_resource :follower_id
  end
end
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Context: Does the current user follow the given artist?
calculations do
  calculate :followed_by_me,
            :boolean,
            expr(exists(follower_relationships, follower_id == ^actor(:id)))
end
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Context: Counting the number of followers for an artist
aggregates do
  # ...

  count :follower_count, :follower_relationships
end
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Context: Allowing the follower information to be used in a sort input
calculations do
  calculate :followed_by_me,
            :boolean,
            expr(exists(follower_relationships, follower_id == ^actor(:id))) do
    public? true
  end
end

aggregates do
  # ...

  count :follower_count, :follower_relationships do
    public? true
  end
end
# ------------------------------------------------------------------------------
