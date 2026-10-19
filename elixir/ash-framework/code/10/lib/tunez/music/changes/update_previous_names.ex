#---
# Excerpted from "Ash Framework",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material,
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose.
# Visit https://pragprog.com/titles/ldash for more book information.
#---
# The final version of this file at the end of this chapter can be found at
# https://github.com/sevenseacat/tunez/blob/end-of-chapter-10/lib/tunez/music/changes/update_previous_names.ex

# ------------------------------------------------------------------------------
# Context: The current non-atomic version of the change
def change(changeset, _opts, _context) do
  Ash.Changeset.before_action(changeset, fn changeset ->
    new_name = Ash.Changeset.get_attribute(changeset, :name)
    previous_name = Ash.Changeset.get_data(changeset, :name)
    previous_names = Ash.Changeset.get_data(changeset, :previous_names)

    names =
      [previous_name | previous_names]
      |> Enum.uniq()
      |> Enum.reject(fn name -> name == new_name end)

    Ash.Changeset.force_change_attribute(changeset, :previous_names, names)
  end)
end
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Context: The new fully-atomic version, that can be run entirely in the data layer!
@impl true
def atomic(_changeset, _opts, _context) do
  {:atomic,
    %{
      previous_names:
        {:atomic,
        expr(
          fragment(
            "array_remove(array_prepend(?, ?), ?)",
            name, previous_names, ^atomic_ref(:name)
          )
        )}
    }}
end
# ------------------------------------------------------------------------------
