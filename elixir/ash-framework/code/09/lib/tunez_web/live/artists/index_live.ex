#---
# Excerpted from "Ash Framework",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material,
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose.
# Visit https://pragprog.com/titles/ldash for more book information.
#---
# The final version of this file at the end of this chapter can be found at
# https://github.com/sevenseacat/tunez/blob/end-of-chapter-9/lib/tunez_web/live/artists/index_live.ex

# ------------------------------------------------------------------------------
# Context: Showing the follow status for each artist in the artist card
<.link navigate={~p"/artists/#{@artist.id}"}>
  <.follow_icon :if={@artist.followed_by_me} />
  <.cover_image image={@artist.cover_image_url} />
</.link>
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Context: Showing the follower count for each artist in the artist card
<p class="flex justify-between">
  <.link ...>{@artist.name}</.link>
  <.follower_count_display count={@artist.follower_count} />
</p>
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Context: Enabling sorting artists by followed status and follower count
defp sort_options do
  [
    # ...
    {"latest album release", "--latest_album_year_released"},
    {"popularity", "-follower_count"},
    {"followed artists first", "-followed_by_me"}
  ]
end
# ------------------------------------------------------------------------------
