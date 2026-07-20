defmodule Quicksort do
  def sort([]), do: []
  def sort([pivot | tail]) do
    {lesser, greater} = Enum.split_with(tail, &(&1 <= pivot))
    sort(lesser) ++ [pivot] ++ sort(greater)
  end
end
