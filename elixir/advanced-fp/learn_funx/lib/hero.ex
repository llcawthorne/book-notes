defmodule Hero do
  import Funx.Predicate
  alias Funx.Monad.Either
  alias Funx.Errors.ValidationError

  @type t :: %__MODULE__{
          id: pos_integer(),
          name: String.t(),
          secret_identity: String.t() | nil,
          power_level: pos_integer(),
          powers: [atom()],
          team: String.t() | nil,
          active: boolean()
        }

  @enforce_keys [:id, :name, :power_level, :secret_identity, :powers, :team, :active]
  defstruct [
    :id,
    :name,
    :power_level,
    secret_identity: nil,
    powers: [],
    team: nil,
    active: true
  ]

  # Domain Constants
  @min_power_level 1
  @max_power_level 100
  @sufficient_power_level 50
  @default_name "Unknown Hero"

  # Constructor & Change Functions
  def make(name, power_level, opts \\ []) do
    id = :erlang.unique_integer([:positive])
    repo = Keyword.get(opts, :repo, Hero.Repo)

    %__MODULE__{
      id: id,
      name: name,
      power_level: power_level,
      secret_identity: Keyword.get(opts, :secret_identity),
      powers: Keyword.get(opts, :powers),
      team: Keyword.get(opts, :team),
      active: Keyword.get(opts, :active, true)
    }
    |> heal()
    |> repo.save()
    |> Either.to_try!()
  end

  def change(%__MODULE__{} = hero, attrs) when is_map(attrs) do
    attrs = Map.delete(attrs, :id)
    repo = Map.get(attrs, :repo, Hero.Repo)
    attrs = Map.delete(attrs, :repo)

    hero
    |> struct(attrs)
    |> heal()
    |> repo.save()
    |> Either.to_try!()
  end

  def unsafe_change(%__MODULE__{} = hero, attrs) when is_map(attrs) do
    attrs = Map.delete(attrs, :id)
    hero |> struct(attrs)
  end

  # Validation Functions
  def validate(%__MODULE__{} = hero) do
    hero
    |> Either.validate([
      &ensure_name/1,
      &ensure_power_level/1,
      &ensure_secret_identity/1,
      &ensure_powers/1,
      &ensure_team/1,
      &ensure_active/1
    ])
  end

  def ensure_name(%__MODULE__{} = hero) do
    hero
    |> Either.lift_predicate(
      p_not(&empty_name?/1),
      fn _ -> "Hero with name cannot have empty name" end
    )
    |> Either.map_left(&ValidationError.new/1)
  end

  def ensure_power_level(%__MODULE__{} = hero) do
    hero
    |> Either.lift_predicate(
      p_not(p_or(&power_low?/1, &power_high?/1)),
      fn h ->
        "Hero '#{h.name}' has invalid power level #{h.power_level}, must be between #{@min_power_level} and #{@max_power_level}"
      end
    )
    |> Either.map_left(&ValidationError.new/1)
  end

  def ensure_secret_identity(%__MODULE__{} = hero) do
    hero
    |> Either.lift_predicate(
      p_not(&invalid_secret_identity?/1),
      fn h -> "Hero '#{h.name}' has invalid secret identity, cannot be empty string" end
    )
    |> Either.map_left(&ValidationError.new/1)
  end

  def ensure_powers(%__MODULE__{} = hero) do
    hero
    |> Either.lift_predicate(
      p_not(&invalid_powers?/1),
      fn h ->
        invalid_powers = Enum.reject(h.powers, &is_atom/1)
        "Hero '#{h.name}' has invalid powers #{inspect(invalid_powers)}, must be atoms"
      end
    )
    |> Either.map_left(&ValidationError.new/1)
  end

  def ensure_team(%__MODULE__{} = hero) do
    hero
    |> Either.lift_predicate(
      p_not(&invalid_team?/1),
      fn h -> "Hero '#{h.name}' has invalid team, cannot be empty string" end
    )
    |> Either.map_left(&ValidationError.new/1)
  end

  def ensure_active(%__MODULE__{} = hero) do
    hero
    |> Either.lift_predicate(
      p_not(&invalid_active?/1),
      fn h ->
        "Hero '#{h.name}' has invalid active status #{inspect(h.active)}, must be boolean"
      end
    )
    |> Either.map_left(&ValidationError.new/1)
  end

  # Predicates
  def default_name?(%__MODULE__{name: name}), do: name == @default_name
  def empty_name?(%__MODULE__{name: name}), do: name == nil or byte_size(name) == 0
  def power_low?(%__MODULE__{power_level: level}), do: level < @min_power_level
  def power_high?(%__MODULE__{power_level: level}), do: level > @max_power_level
  def sufficient_power?(%__MODULE__{power_level: level}), do: level >= @sufficient_power_level

  def invalid_secret_identity?(%__MODULE__{secret_identity: identity}),
    do: is_binary(identity) and byte_size(identity) == 0

  def invalid_powers?(%__MODULE__{powers: powers}),
    do: is_list(powers) and Enum.any?(powers, &(not is_atom(&1)))

  def invalid_team?(%__MODULE__{team: team}), do: is_binary(team) and byte_size(team) == 0
  def invalid_active?(%__MODULE__{active: active}), do: not is_boolean(active)

  # Self-Healing Functions
  def heal(%__MODULE__{} = hero) do
    %__MODULE__{
      hero
      | name: heal_name(hero.name),
        power_level: heal_power_level(hero.power_level),
        powers: heal_powers(hero.powers),
        secret_identity: heal_optional_string(hero.secret_identity),
        team: heal_optional_string(hero.team),
        active: heal_boolean(hero.active)
    }
  end

  defp heal_name(name) when is_binary(name) and byte_size(name) > 0, do: name
  defp heal_name(_), do: @default_name

  defp heal_power_level(level) when is_integer(level) do
    cond do
      level < @min_power_level -> @min_power_level
      level > @max_power_level -> @max_power_level
      true -> level
    end
  end

  defp heal_power_level(_), do: @min_power_level

  defp heal_powers(powers) when is_list(powers), do: Enum.filter(powers, &is_atom/1)
  defp heal_powers(_), do: []

  defp heal_optional_string(value) when is_binary(value) and byte_size(value) > 0, do: value
  defp heal_optional_string(_), do: nil

  defp heal_boolean(value) when is_boolean(value), do: value
  defp heal_boolean(_), do: true

  # Field Accessors
  def id(%__MODULE__{id: id}), do: id
  def name(%__MODULE__{name: name}), do: name
  def power_level(%__MODULE__{power_level: level}), do: level
  def secret_identity(%__MODULE__{secret_identity: identity}), do: identity
  def powers(%__MODULE__{powers: powers}), do: powers
  def team(%__MODULE__{team: team_name}), do: team_name
  def active?(%__MODULE__{active: active}), do: active
end

defimpl Funx.Eq, for: Hero do
  alias Funx.Eq
  alias Hero
  def eq?(%Hero{id: v1}, %Hero{id: v2}), do: Eq.eq?(v1, v2)
  def not_eq?(%Hero{id: v1}, %Hero{id: v2}), do: not eq?(v1, v2)
end

defimpl Funx.Ord, for: Hero do
  alias Funx.Ord
  alias Hero
  def lt?(%Hero{name: v1}, %Hero{name: v2}), do: Ord.lt?(v1, v2)
  def le?(%Hero{name: v1}, %Hero{name: v2}), do: Ord.le?(v1, v2)
  def gt?(%Hero{name: v1}, %Hero{name: v2}), do: Ord.gt?(v1, v2)
  def ge?(%Hero{name: v1}, %Hero{name: v2}), do: Ord.ge?(v1, v2)
end
