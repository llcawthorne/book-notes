defmodule TeamTest do
  use ExUnit.Case

  alias Funx.Monad.Either
  alias Funx.Errors.ValidationError

  # Create tables before each test and inject repo for dependency control
  # This allows tests to explicitly control which repo implementation is used
  setup do
    repo = Team.Repo
    repo.create_table()
    Hero.Repo.create_table()
    {:ok, repo: repo}
  end

  describe "Team.make/2 - Never-fail constructors with self-healing" do
    test "creates team with valid inputs and auto-saves", %{repo: repo} do
      team = Team.make("Justice League", repo: repo)

      assert team.name == "Justice League"
      assert team.hero_ids == []
      assert is_integer(team.id) and team.id > 0
    end

    test "self-heals empty name to valid default", %{repo: repo} do
      team = Team.make("", repo: repo)
      # Team fixes invalid data automatically
      assert team.name != ""
      assert is_binary(team.name)
    end

    test "creates team with heroes", %{repo: repo} do
      hero1 = Hero.make("Superman", 85, repo: Hero.Repo)
      hero2 = Hero.make("Batman", 80, repo: Hero.Repo)

      team = Team.make("Justice League", heroes: [hero1, hero2], repo: repo)

      assert team.name == "Justice League"
      assert length(team.hero_ids) == 2
      assert Hero.id(hero1) in team.hero_ids
      assert Hero.id(hero2) in team.hero_ids
    end
  end

  describe "Team.validate/1 - Either monad for detailed validation" do
    test "Either.Right for valid data", %{repo: repo} do
      team = Team.make("Justice League", repo: repo)
      result = Team.validate(team)

      # Test: validation succeeded
      assert Either.right?(result)

      case result do
        %Either.Right{right: validated_team} ->
          assert validated_team == team
      end
    end

    test "Either.Left with ValidationError for invalid data", %{repo: repo} do
      team = Team.unsafe_change(Team.make("Test", repo: repo), %{name: ""})
      result = Team.validate(team)

      # Test: validation failed
      assert Either.left?(result)

      case result do
        %Either.Left{left: %ValidationError{errors: errors}} ->
          assert is_list(errors)
          assert length(errors) >= 1
      end
    end
  end

  describe "Team.change/2 - Self-healing updates with auto-save" do
    test "changes valid attributes and auto-saves", %{repo: repo} do
      team = Team.make("Avengers", repo: repo)
      updated_team = Team.change(team, %{name: "New Avengers", repo: repo})

      assert updated_team.name == "New Avengers"
      # ID preserved
      assert updated_team.id == team.id
    end

    test "heals invalid changes during update", %{repo: repo} do
      team = Team.make("Avengers", repo: repo)
      updated_team = Team.change(team, %{name: "", repo: repo})

      # Team fixes invalid data automatically
      assert updated_team.name != ""
    end

    test "prevents ID changes for data integrity", %{repo: repo} do
      team = Team.make("Avengers", repo: repo)
      original_id = team.id
      updated_team = Team.change(team, %{id: 999, name: "New Name", repo: repo})

      # ID unchanged
      assert updated_team.id == original_id
      # Other change applied
      assert updated_team.name == "New Name"
    end
  end

  describe "Team.unsafe_change/2 - Testing helper for creating invalid data" do
    test "allows invalid data without healing (useful for testing)", %{repo: repo} do
      team = Team.make("Avengers", repo: repo)
      invalid_team = Team.unsafe_change(team, %{name: ""})

      # Data is actually invalid (not healed)
      assert invalid_team.name == ""

      # Now we can test healing
      healed_team = Team.heal(invalid_team)
      # Team fixes invalid data automatically
      assert healed_team.name != ""
    end
  end

  describe "Team management functions" do
    test "add_hero adds hero to team", %{repo: repo} do
      team = Team.make("Justice League", repo: repo)
      hero = Hero.make("Superman", 85, repo: Hero.Repo)

      updated_team = Team.add_hero(team, hero)

      assert Hero.id(hero) in updated_team.hero_ids
      assert length(updated_team.hero_ids) == 1
    end

    test "remove_hero removes hero from team", %{repo: repo} do
      hero = Hero.make("Superman", 85, repo: Hero.Repo)
      team = Team.make("Justice League", heroes: [hero], repo: repo)

      updated_team = Team.remove_hero(team, hero)

      assert Hero.id(hero) not in updated_team.hero_ids
      assert length(updated_team.hero_ids) == 0
    end
  end
end
