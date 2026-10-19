#---
# Excerpted from "Ash Framework",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material,
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose.
# Visit https://pragprog.com/titles/ldash for more book information.
#---
# The final version of this file at the end of this chapter can be found at
# https://github.com/sevenseacat/tunez/blob/end-of-chapter-9/lib/tunez/accounts/user.ex

# ------------------------------------------------------------------------------
# Context: Linking users and the artists they follow
relationships do
  has_many :follower_relationships, Tunez.Music.ArtistFollower do
    destination_attribute :follower_id
  end

  many_to_many :followed_artists, Tunez.Music.Artist do
    join_relationship :follower_relationships
    source_attribute_on_join_resource :follower_id
  end
end
# ------------------------------------------------------------------------------
