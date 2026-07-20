defmodule HeroTest do
  use ExUnit.Case

  alias Funx.Monad.Either
  alias Funx.Errors.ValidationError

  # Create tables before each test and inject repo for dependency control
  # This allows tests to explicitly control which repo implementation is used
  setup do
    repo = Hero.Repo
    repo.create_table()
    Team.Repo.create_table()
    Dispatch.Repo.create_table()
    {:ok, repo: repo}
  end

  describe "Hero.make/3 - Never-fail constructors with self-healing" do
    test "creates hero with valid inputs and auto-saves", %{repo: repo} do
      hero = Hero.make("Superman", 85, repo: repo)

      assert hero.name == "Superman"
      assert hero.power_level == 85
      assert is_integer(hero.id) and hero.id > 0
    end

    test "self-heals empty name to valid default", %{repo: repo} do
      hero = Hero.make("", 50, repo: repo)
      # Healed to something valid
      assert hero.name != ""
      assert is_binary(hero.name)
    end

    test "self-heals invalid power levels to valid range", %{repo: repo} do
      low_hero = Hero.make("Flash", -10, repo: repo)
      high_hero = Hero.make("Superman", 200, repo: repo)

      # Healed above minimum
      assert low_hero.power_level > 0
      # Healed to maximum or below
      assert high_hero.power_level <= 100
    end

    test "filters invalid powers from list", %{repo: repo} do
      hero =
        Hero.make("Aquaman", 70, powers: [:water_control, "invalid", 123, :telepathy], repo: repo)

      # Should only contain valid atoms, filtering out strings/numbers
      assert Enum.all?(hero.powers, &is_atom/1)
      assert :water_control in hero.powers
      assert :telepathy in hero.powers
    end
  end

  describe "Hero.validate/1 - Either monad for detailed validation" do
    test "Either.Right for valid data", %{repo: repo} do
      hero = Hero.make("Superman", 85, repo: repo)
      result = Hero.validate(hero)

      # Test: validation succeeded
      assert Either.right?(result)

      case result do
        %Either.Right{right: validated_hero} ->
          assert validated_hero == hero
      end
    end

    test "Either.Left with ValidationError for invalid data", %{repo: repo} do
      hero = Hero.unsafe_change(Hero.make("Test", 50, repo: repo), %{name: ""})
      result = Hero.validate(hero)

      # Test: validation failed
      assert Either.left?(result)

      case result do
        %Either.Left{left: %ValidationError{errors: errors}} ->
          assert is_list(errors)
          assert length(errors) >= 1
      end
    end

    test "Either.validate collects ALL errors (not fail-fast)", %{repo: repo} do
      hero = Hero.unsafe_change(Hero.make("Test", 50, repo: repo), %{name: "", power_level: 101})
      result = Hero.validate(hero)

      # Test: validation failed
      assert Either.left?(result)

      case result do
        %Either.Left{left: %ValidationError{errors: errors}} ->
          # Test: collected both errors
          assert length(errors) == 2
      end
    end
  end

  describe "Hero.change/2 - Self-healing updates with auto-save" do
    test "changes valid attributes and auto-saves", %{repo: repo} do
      hero = Hero.make("Batman", 80, repo: repo)
      updated_hero = Hero.change(hero, %{name: "Dark Knight", power_level: 85, repo: repo})

      assert updated_hero.name == "Dark Knight"
      assert updated_hero.power_level == 85
      # ID preserved
      assert updated_hero.id == hero.id
    end

    test "heals invalid changes during update", %{repo: repo} do
      hero = Hero.make("Batman", 80, repo: repo)
      updated_hero = Hero.change(hero, %{name: "", power_level: 150, repo: repo})

      # Healed to valid name
      assert updated_hero.name != ""
      # Healed to valid range
      assert updated_hero.power_level <= 100
    end

    test "prevents ID changes for data integrity", %{repo: repo} do
      hero = Hero.make("Batman", 80, repo: repo)
      original_id = hero.id
      updated_hero = Hero.change(hero, %{id: 999, name: "New Name", repo: repo})

      # ID unchanged
      assert updated_hero.id == original_id
      # Other change applied
      assert updated_hero.name == "New Name"
    end
  end

  describe "Hero.unsafe_change/2 - Testing helper for creating invalid data" do
    test "allows invalid data without healing (useful for testing)", %{repo: repo} do
      hero = Hero.make("Batman", 80, repo: repo)
      invalid_hero = Hero.unsafe_change(hero, %{name: "", power_level: 200})

      # Data is actually invalid (not healed)
      assert invalid_hero.name == ""
      assert invalid_hero.power_level == 200

      # Now we can test healing
      healed_hero = Hero.heal(invalid_hero)
      # Healed to valid name
      assert healed_hero.name != ""
      # Healed to valid range
      assert healed_hero.power_level <= 100
    end
  end
end
