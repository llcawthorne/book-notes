#---
# Excerpted from "Ash Framework",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material,
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose.
# Visit https://pragprog.com/titles/ldash for more book information.
#---
# The final version of this file at the end of this chapter can be found at
# https://github.com/sevenseacat/tunez/blob/end-of-chapter-9/lib/tunez_web/live/artists/show_live.ex

# ------------------------------------------------------------------------------
# Context: Loading the user's follow status for an artist
def handle_params(%{"id" => artist_id}, _url, socket) do
  artist =
    Tunez.Music.get_artist_by_id!(artist_id,
      load: [:followed_by_me, albums: [:duration, :tracks]],
      actor: socket.assigns.current_user
    )
  # ...
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Context: Showing the user's follow status in the page header
<.h1>
  {@artist.name}
  <.follow_toggle on={@artist.followed_by_me} />
</.h1>
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Context: Process the "follow" event when the user follows an artist
def handle_event("follow", _params, socket) do
  socket =
    case Tunez.Music.follow_artist(socket.assigns.artist,
            actor: socket.assigns.current_user
          ) do
      {:ok, _} ->
        update(socket, :artist, & %{&1 | followed_by_me: true})

      {:error, _} ->
        put_flash(socket, :error, "Could not follow artist")
    end

  {:noreply, socket}
end
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Context: Process the "unfollow" event when the user unfollows an artist
def handle_event("unfollow", _params, socket) do
  socket =
    case Tunez.Music.unfollow_artist(socket.assigns.artist,
            actor: socket.assigns.current_user
          ) do
      :ok ->
        update(socket, :artist, & %{&1 | followed_by_me: false})

      {:error, _} ->
        put_flash(socket, :error, "Could not unfollow artist")
    end

  {:noreply, socket}
end
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Context: Conditionally showing option to follow artists
<.h1>
  {@artist.name}
  <.follow_toggle
    :if={Tunez.Music.can_follow_artist?(@current_user, @artist)}
    on={@artist.followed_by_me}
  />
</.h1>
# ------------------------------------------------------------------------------
