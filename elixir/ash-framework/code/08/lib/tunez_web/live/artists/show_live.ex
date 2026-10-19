#---
# Excerpted from "Ash Framework",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material,
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose.
# Visit https://pragprog.com/titles/ldash for more book information.
#---
# The final version of this file at the end of this chapter can be found at
# https://github.com/sevenseacat/tunez/blob/end-of-chapter-8/lib/tunez_web/live/artists/show_live.ex

# ------------------------------------------------------------------------------
# Context: Loading track lists for albums
defmodule TunezWeb.Artists.ShowLive do
  # ...

  def handle_params(%{"id" => artist_id}, _url, socket) do
    artist =
      Tunez.Music.get_artist_by_id!(artist_id,
        load: [albums: [:tracks]],
        actor: socket.assigns.current_user
      )

      # ...
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Context: Rendering real track lists for albums
    </.header>
    <.track_details tracks={@album.tracks} />
  </div>
</div>
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Context: Using the track number in the UI
<tr :for={track <- @tracks}>
  <th class="whitespace-nowrap w-1 p-3">
    {String.pad_leading("#{track.number}", 2, "0")}.
  </th>
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Context: Loading formatted durations for albums
def handle_params(%{"id" => artist_id}, _url, socket) do
  artist =
    Tunez.Music.get_artist_by_id!(artist_id,
      load: [albums: [:duration, :tracks]],
      actor: socket.assigns.current_user
    )
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Context: Rendering formatted durations for albums
<.h2>
  {@album.name} ({@album.year_released})
  <span :if={@album.duration} class="text-base">({@album.duration})</span>
</.h2>
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Context: Rendering formatted durations for tracks
<tr :for={track <- @tracks}>
  <% # ... %>
  <td class="whitespace-nowrap w-1 text-right p-2">{track.duration}</td>
</tr>
# ------------------------------------------------------------------------------
