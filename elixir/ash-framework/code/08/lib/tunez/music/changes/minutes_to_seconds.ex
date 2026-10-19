#---
# Excerpted from "Ash Framework",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material,
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose.
# Visit https://pragprog.com/titles/ldash for more book information.
#---
# The final version of this file at the end of this chapter can be found at
# https://github.com/sevenseacat/tunez/blob/end-of-chapter-8/lib/tunez/music/changes/minutes_to_seconds.ex

# ------------------------------------------------------------------------------
# Context: Defining a change module to convert minutes+seconds to seconds
defmodule Tunez.Music.Changes.MinutesToSeconds do
  use Ash.Resource.Change

  @impl true
  def change(changeset, _opts, _context) do
  end
end
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Context: The logic for converting a `duration` argument to a seconds format
def change(changeset, _opts, _context) do
  {:ok, duration} = Ash.Changeset.fetch_argument(changeset, :duration)

  with :ok <- ensure_valid_format(duration),
       :ok <- ensure_valid_value(duration) do
    changeset
    |> Ash.Changeset.change_attribute(:duration_seconds, to_seconds(duration))
  else
    {:error, :format} ->
      Ash.Changeset.add_error(changeset, field: :duration,
        message: "use MM:SS format"
      )

    {:error, :value} ->
      Ash.Changeset.add_error(changeset, field: :duration,
        message: "must be at least 1 second long"
      )
  end
end

defp ensure_valid_format(duration) do
  if String.match?(duration, ~r/^\d+:\d{2}$/) do
    :ok
  else
    {:error, :format}
  end
end

defp ensure_valid_value(v) when v in ["0:00", "00:00"], do: {:error, :value}
defp ensure_valid_value(_value), do: :ok

defp to_seconds(duration) do
  [minutes, seconds] = String.split(duration, ":", parts: 2)
  String.to_integer(minutes) * 60 + String.to_integer(seconds)
end
# ------------------------------------------------------------------------------
