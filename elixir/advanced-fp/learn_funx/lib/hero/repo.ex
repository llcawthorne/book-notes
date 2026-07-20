defmodule Hero.Repo do
  import Funx.Monad
  import Funx.Utils, only: [curry: 1]

  alias Funx.Monad.Either
  alias Funx.List
  alias Hero
  alias Store

  @table_name :hero

  def create_table do
    Store.create_table(@table_name)
  end

  def save(%Hero{} = hero) do
    insert_hero = curry(&Store.insert_item/2)

    hero
    |> Hero.validate()
    |> bind(insert_hero.(@table_name))
  end

  def get(id) when is_integer(id) do
    Store.get_item(@table_name, id)
    |> map(fn data -> struct(Hero, data) end)
    |> map(&Hero.heal/1)
    |> Either.map_left(fn _ -> :not_found end)
  end

  def list() do
    Store.get_all_items(@table_name)
    |> map(fn items ->
      items
      |> map(fn data -> struct(Hero, data) |> Hero.heal() end)
      |> List.sort()
    end)
    |> Either.get_or_else([])
  end

  def delete(%Hero{id: id}) do
    Store.delete_item(@table_name, id)
    |> Either.get_or_else(:ok)
  end
end
