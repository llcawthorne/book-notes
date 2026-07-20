defmodule MyList do
  def max([]), do: []
  def max([head | tail]), do: max_item(tail, head)
  defp max_item([], item), do: item
  defp max_item([head | tail], item) when head > item, do: max_item(tail, head)
  defp max_item([_head | tail], item), do: max_item(tail, item)
  def min([]), do: []
  def min([head | tail]), do: min_item(tail, head)
  defp min_item([], item), do: item
  defp min_item([head | tail], item) when head < item, do: min_item(tail, head)
  defp min_item([_head | tail], item), do: min_item(tail, item)
end
