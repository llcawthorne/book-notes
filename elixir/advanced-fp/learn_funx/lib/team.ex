defmodule Team do
  import Funx.Predicate
  import Funx.Monad
  alias Funx.Monad.Either
  alias Funx.Errors.ValidationError
  alias Funx.List

  @type t :: %__MODULE__{
          id: pos_integer(),
          name: String.t(),
          hero_ids: [pos_integer()]
        }

  @enforce_keys [:id, :name, :hero_ids]
  defstruct [:id, :name, hero_ids: []]

  # Domain Constants
  @default_name "Unnamed Team"

  # Constructor & Change Functions
  def make(name, opts \\ []) do
    id = :erlang.unique_integer([:positive])
    repo = Keyword.get(opts, :repo, Team.Repo)

    heroes = Keyword.get(opts, :heroes, [])
    hero_ids = map(heroes, &Hero.id/1)

    %__MODULE__{
      id: id,
      name: name,
      hero_ids: hero_ids
    }
    |> heal()
    |> repo.save()
    |> Either.to_try!()
  end

  def change(%__MODULE__{} = team, attrs) when is_map(attrs) do
    attrs = Map.delete(attrs, :id)
    repo = Map.get(attrs, :repo, Team.Repo)
    attrs = Map.delete(attrs, :repo)

    team
    |> struct(attrs)
    |> heal()
    |> repo.save()
    |> Either.to_try!()
  end

  def unsafe_change(%__MODULE__{} = team, attrs) when is_map(attrs) do
    attrs = Map.delete(attrs, :id)
    team |> struct(attrs)
  end

  # Validation Functions
  def validate(%__MODULE__{} = team) do
    team
    |> Either.validate([
      &ensure_name/1,
      &ensure_hero_ids/1
    ])
  end

  def ensure_name(%__MODULE__{} = team) do
    team
    |> Either.lift_predicate(
      p_not(&empty_name?/1),
      fn t -> "Team with name '#{t.name}' cannot have empty name" end
    )
    |> Either.map_left(&ValidationError.new/1)
  end

  def ensure_hero_ids(%__MODULE__{} = team) do
    team
    |> Either.lift_predicate(
      p_not(&invalid_hero_ids?/1),
      fn t -> "Team '#{t.name}' has invalid hero_ids list" end
    )
    |> Either.map_left(&ValidationError.new/1)
  end

  # Predicates
  def default_name?(%__MODULE__{name: name}), do: name == @default_name
  def empty_name?(%__MODULE__{name: name}), do: name == nil or byte_size(name) == 0
  def invalid_hero_ids?(%__MODULE__{hero_ids: hero_ids}), do: not is_list(hero_ids)

  # Self-Healing Functions
  def heal(%__MODULE__{} = team) do
    %__MODULE__{
      team
      | name: heal_name(team.name),
        hero_ids: heal_hero_ids(team.hero_ids)
    }
  end

  defp heal_name(name) when is_binary(name) and byte_size(name) > 0, do: name
  defp heal_name(_), do: @default_name

  defp heal_hero_ids(hero_ids) when is_list(hero_ids), do: hero_ids
  defp heal_hero_ids(_), do: []

  # Team Management Functions
  def add_hero(%__MODULE__{} = team, %Hero{} = hero) do
    hero_ids = List.union([Hero.id(hero)], team.hero_ids)
    change(team, %{hero_ids: hero_ids})
  end

  def remove_hero(%__MODULE__{} = team, %Hero{} = hero) do
    hero_ids = List.difference(team.hero_ids, [Hero.id(hero)])
    change(team, %{hero_ids: hero_ids})
  end

  def change_name(%__MODULE__{} = team, new_name) when is_binary(new_name) do
    change(team, %{name: new_name})
  end

  # Field Accessors
  def id(%__MODULE__{id: id}), do: id
  def name(%__MODULE__{name: name}), do: name
  def hero_ids(%__MODULE__{hero_ids: hero_ids}), do: hero_ids
end

defimpl Funx.Eq, for: Team do
  alias Funx.Eq
  alias Team
  def eq?(%Team{id: v1}, %Team{id: v2}), do: Eq.eq?(v1, v2)
  def not_eq?(%Team{id: v1}, %Team{id: v2}), do: not eq?(v1, v2)
end

defimpl Funx.Ord, for: Team do
  alias Funx.Ord
  alias Team
  def lt?(%Team{name: v1}, %Team{name: v2}), do: Ord.lt?(v1, v2)
  def le?(%Team{name: v1}, %Team{name: v2}), do: Ord.le?(v1, v2)
  def gt?(%Team{name: v1}, %Team{name: v2}), do: Ord.gt?(v1, v2)
  def ge?(%Team{name: v1}, %Team{name: v2}), do: Ord.ge?(v1, v2)
end
