#---
# Excerpted from "Ash Framework",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material,
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose.
# Visit https://pragprog.com/titles/ldash for more book information.
#---
# The final version of this file at the end of this chapter can be found at
# https://github.com/sevenseacat/tunez/blob/end-of-chapter-10/lib/tunez/music.ex

# ------------------------------------------------------------------------------
# Context: Adding a code interface function for ArtistFollower.for_artist
resource Tunez.Music.ArtistFollower do
  # ...

  define :followers_for_artist, action: :for_artist, args: [:artist_id]
end
# ------------------------------------------------------------------------------
