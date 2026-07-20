defmodule Dispatch do
  import Funx.Predicate
  import Funx.Monad
  import Funx.Utils, only: [curry: 1]
  alias Funx.Monad.{Either, Maybe}
  alias Funx.Errors.ValidationError

  @type t :: %__MODULE__{
          id: pos_integer(),
          team_id: pos_integer(),
          dispatched_at: DateTime.t(),
          mission: String.t(),
          status: atom(),
          required_power: pos_integer()
        }

  @enforce_keys [:id, :team_id, :dispatched_at, :mission, :status, :required_power]
  defstruct [:id, :team_id, :dispatched_at, :mission, :status, :required_power]

  # Domain Constants
  @default_mission "Emergency Response"
  @valid_statuses [:active, :completed, :failed, :recalled]
  @default_status :active
  @default_required_power 50

  # Constructor & Change Functions
  def make(%Team{} = team, opts \\ []) do
    id = :erlang.unique_integer([:positive])
    repo = Keyword.get(opts, :repo, Dispatch.Repo)
    required_power = Keyword.get(opts, :required_power, @default_required_power)
    mission = Keyword.get(opts, :mission, @default_mission)

    %__MODULE__{
      id: id,
      team_id: team.id,
      dispatched_at: DateTime.utc_now(),
      mission: mission,
      status: @default_status,
      required_power: required_power
    }
    |> heal()
    |> repo.save()
  end

  def change(%__MODULE__{} = dispatch, attrs) when is_map(attrs) do
    attrs = Map.delete(attrs, :id) |> Map.delete(:dispatched_at)
    repo = Map.get(attrs, :repo, Dispatch.Repo)
    attrs = Map.delete(attrs, :repo)

    dispatch
    |> struct(attrs)
    |> heal()
    |> repo.save()
  end

  def unsafe_change(%__MODULE__{} = dispatch, attrs) when is_map(attrs) do
    attrs = Map.delete(attrs, :id) |> Map.delete(:dispatched_at)
    dispatch |> struct(attrs)
  end

  # Validation Functions
  def validate(%__MODULE__{} = dispatch) do
    dispatch
    |> Either.validate([
      &ensure_team_id/1,
      &ensure_mission/1,
      &ensure_status/1,
      &ensure_team_has_heroes/1,
      &ensure_team_capability/1
    ])
  end

  def ensure_team_id(%__MODULE__{} = dispatch) do
    dispatch
    |> Either.lift_predicate(
      p_not(&invalid_team_id?/1),
      fn d -> "Dispatch has invalid team_id #{d.team_id}, must be positive integer" end
    )
    |> Either.map_left(&ValidationError.new/1)
  end

  def ensure_mission(%__MODULE__{} = dispatch) do
    dispatch
    |> Either.lift_predicate(
      p_not(&empty_mission?/1),
      fn d -> "Dispatch with mission '#{d.mission}' cannot have empty mission" end
    )
    |> Either.map_left(&ValidationError.new/1)
  end

  def ensure_status(%__MODULE__{} = dispatch) do
    dispatch
    |> Either.lift_predicate(
      p_not(&invalid_status?/1),
      fn d ->
        "Dispatch has invalid status #{inspect(d.status)}, must be one of #{inspect(@valid_statuses)}"
      end
    )
    |> Either.map_left(&ValidationError.new/1)
  end

  def ensure_team_has_heroes(%__MODULE__{} = dispatch) do
    Team.Repo.get(dispatch.team_id)
    |> bind(fn team ->
      dispatch
      |> Either.lift_predicate(
        fn _ -> length(team.hero_ids) > 0 end,
        fn _ -> "Cannot dispatch empty team - at least one hero required" end
      )
    end)
    |> Either.map_left(&ValidationError.new/1)
  end

  def ensure_team_capability(%__MODULE__{} = dispatch) do
    validate_hero = curry(&ensure_hero_meets_power_requirement/2).(dispatch)

    Team.Repo.get(dispatch.team_id)
    |> bind(fn team ->
      team.hero_ids
      |> Either.traverse(&Hero.Repo.get/1)
      |> bind(fn heroes ->
        heroes
        |> Either.traverse_a(validate_hero)
        |> map(fn _ -> dispatch end)
      end)
    end)
    |> Either.map_left(&ValidationError.new/1)
  end

  defp ensure_hero_meets_power_requirement(%__MODULE__{} = dispatch, %Hero{} = hero) do
    hero
    |> Either.lift_predicate(
      fn h -> hero_meets_power_requirement?(dispatch, h) end,
      fn h ->
        "Hero '#{Hero.name(h)}' has insufficient power (#{Hero.power_level(h)} < #{dispatch.required_power})"
      end
    )
  end

  defp hero_meets_power_requirement?(%__MODULE__{required_power: required_power}, %Hero{} = hero) do
    Hero.power_level(hero) >= required_power
  end

  # Business Rule Functions
  def complete(%__MODULE__{} = dispatch) do
    dispatch
    |> Maybe.lift_predicate(&active?/1)
    |> map(fn d -> change(d, %{status: :completed}) end)
  end

  def recall(%__MODULE__{} = dispatch) do
    dispatch
    |> Maybe.lift_predicate(&active?/1)
    |> map(fn d -> change(d, %{status: :recalled}) end)
  end

  # Predicates
  def invalid_team_id?(%__MODULE__{team_id: team_id}), do: not is_integer(team_id) or team_id <= 0
  def default_mission?(%__MODULE__{mission: mission}), do: mission == @default_mission
  def empty_mission?(%__MODULE__{mission: mission}), do: mission == nil or byte_size(mission) == 0
  def invalid_status?(%__MODULE__{status: status}), do: status not in @valid_statuses
  def active?(%__MODULE__{status: status}), do: status == :active

  # Self-Healing Functions
  def heal(%__MODULE__{} = dispatch) do
    %__MODULE__{
      dispatch
      | team_id: heal_team_id(dispatch.team_id),
        mission: heal_mission(dispatch.mission),
        status: heal_status(dispatch.status),
        required_power: heal_required_power(dispatch.required_power)
    }
  end

  defp heal_team_id(team_id) when is_integer(team_id) and team_id > 0, do: team_id
  defp heal_team_id(_), do: 1

  defp heal_mission(mission) when is_binary(mission) and byte_size(mission) > 0, do: mission
  defp heal_mission(_), do: @default_mission

  defp heal_status(status) when status in @valid_statuses, do: status
  defp heal_status(_), do: @default_status

  defp heal_required_power(power) when is_integer(power) and power > 0, do: power
  defp heal_required_power(_), do: @default_required_power

  # Field Accessors
  def id(%__MODULE__{id: id}), do: id
  def team_id(%__MODULE__{team_id: team_id}), do: team_id
  def dispatched_at(%__MODULE__{dispatched_at: dispatched_at}), do: dispatched_at
  def mission(%__MODULE__{mission: mission}), do: mission
  def status(%__MODULE__{status: status}), do: status
  def required_power(%__MODULE__{required_power: power}), do: power
end

defimpl Funx.Eq, for: Dispatch do
  alias Funx.Eq
  alias Dispatch
  def eq?(%Dispatch{id: v1}, %Dispatch{id: v2}), do: Eq.eq?(v1, v2)
  def not_eq?(%Dispatch{id: v1}, %Dispatch{id: v2}), do: not eq?(v1, v2)
end

defimpl Funx.Ord, for: Dispatch do
  alias Funx.Ord
  alias Dispatch
  def lt?(%Dispatch{dispatched_at: v1}, %Dispatch{dispatched_at: v2}), do: Ord.lt?(v1, v2)
  def le?(%Dispatch{dispatched_at: v1}, %Dispatch{dispatched_at: v2}), do: Ord.le?(v1, v2)
  def gt?(%Dispatch{dispatched_at: v1}, %Dispatch{dispatched_at: v2}), do: Ord.gt?(v1, v2)
  def ge?(%Dispatch{dispatched_at: v1}, %Dispatch{dispatched_at: v2}), do: Ord.ge?(v1, v2)
end
