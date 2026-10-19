#---
# Excerpted from "Ash Framework",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material,
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose.
# Visit https://pragprog.com/titles/ldash for more book information.
#---
# The final version of this file at the end of this chapter can be found at
# https://github.com/sevenseacat/tunez/blob/end-of-chapter-9/lib/tunez/music.ex

# ------------------------------------------------------------------------------
# Context: Defining the code interface for the `ArtistFollower.create` action
resources do
  # ...

  resource Tunez.Music.ArtistFollower do
    define :follow_artist, action: :create, args: [:artist]
  end
end
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Context: Adding a `follow_artist` mutation to the GraphQL API
graphql do
  # ...

  mutations do
    # ...
    create Tunez.Music.ArtistFollower, :follow_artist, :create
  end
end
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
resource Tunez.Music.ArtistFollower do
  define :follow_artist do
    action :create
    args [:artist]

    custom_input :artist, :struct do
      constraints instance_of: Tunez.Music.Artist
      transform to: :artist_id, using: & &1.id
    end
  end
end
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Context: Defining the code interface for the `ArtistFollower.destroy` action
resource Tunez.Music.ArtistFollower do
  # ...
  define :unfollow_artist do
    action :destroy
    args [:artist]
    require_reference? false

    custom_input :artist, :struct do
      constraints instance_of: Tunez.Music.Artist
      transform to: :artist_id, using: & &1.id
    end
  end
end
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Context: Updating the code interface to unwrap the bulk result
resource Tunez.Music.ArtistFollower do
  # ...
  define :unfollow_artist do
    action :destroy
    args [:artist]
    get? true

    # ...
  end
end
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Context: Loading the follow status for each artist in the artist catalog
resource Tunez.Music.Artist do
  # ...

  define :search_artists,
    action: :search,
    args: [:query],
    
    
    
    
    
    
    
    
    default_options: [
      load: [
        :followed_by_me, :album_count, :latest_album_year_released, 
        :cover_image_url
      ]
    ]
end
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Context: Loading the follower count for each artist in the artist catalog
resource Tunez.Music.Artist do
  # ...

  define :search_artists,
    action: :search,
    args: [:query],
    default_options: [
      load: [
        :follower_count, :followed_by_me, :album_count,
        :latest_album_year_released, :cover_image_url
      ]
    ]
end
# ------------------------------------------------------------------------------
