defmodule Dispatch.Repo do
  import Funx.Monad
  import Funx.Filterable
  import Funx.Utils, only: [curry: 1, curry_r: 1]

  alias Funx.Monad.Either
  alias Funx.List
  alias Dispatch
  alias Store

  @table_name :dispatches

  def create_table do
    Store.create_table(@table_name)
  end

  def save(%Dispatch{} = dispatch) do
    insert_dispatch = curry(&Store.insert_item/2)

    dispatch
    |> Dispatch.validate()
    |> bind(insert_dispatch.(@table_name))
  end

  def get(id) when is_integer(id) do
    to_dispatch_struct = curry_r(&struct/2).(Dispatch)

    Store.get_item(@table_name, id)
    |> map(to_dispatch_struct)
    |> map(&Dispatch.heal/1)
    |> Either.map_left(fn _ -> :not_found end)
  end

  def list() do
    Store.get_all_items(@table_name)
    |> map(fn items ->
      items
      |> map(fn data -> struct(Dispatch, data) |> Dispatch.heal() end)
      |> List.sort()
    end)
    |> Either.get_or_else([])
  end

  def list_by_team(team_id) when is_integer(team_id) do
    list()
    |> filter(fn dispatch -> dispatch.team_id == team_id end)
  end

  def list_active() do
    list()
    |> filter(&Dispatch.active?/1)
  end

  def delete(%Dispatch{id: id}) do
    Store.delete_item(@table_name, id)
    |> Either.get_or_else(:ok)
  end
end
