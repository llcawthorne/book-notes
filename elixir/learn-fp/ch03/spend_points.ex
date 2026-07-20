defmodule SpendPoints do
  def total_points(%{
    strength: strength_value,
    dexterity: dexterity_value,
    intelligence: intelligence_value
  }) do
    strength_value * 2 + (dexterity_value + intelligence_value) * 3
  end
end
