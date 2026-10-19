#---
# Excerpted from "Ash Framework",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material,
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose.
# Visit https://pragprog.com/titles/ldash for more book information.
#---
# The final version of this file at the end of this chapter can be found at
# https://github.com/sevenseacat/tunez/blob/end-of-chapter-10/lib/tunez/music/artist.ex

# ------------------------------------------------------------------------------
# Context: Writing a new `destroy` action to cascade deletes for albums
defmodule Tunez.Music.Artist do
  # ...

  actions do
    defaults [:create, :read]

    destroy :destroy do
      primary? true
      change cascade_destroy(:albums, return_notifications?: true,
        after_action?: false)
    end

    # ...
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Context: The final version of the update action, after the `UpdatePreviousNames`
# change is made fully-atomic
update :update do
  accept [:name, :biography]
  change Tunez.Music.Changes.UpdatePreviousNames
end
# ------------------------------------------------------------------------------
