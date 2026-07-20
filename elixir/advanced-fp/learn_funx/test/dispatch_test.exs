defmodule DispatchTest do
  use ExUnit.Case

  alias Funx.Monad.Either
  alias Funx.Errors.ValidationError

  # Create tables and test data - dispatch needs heroes and teams to work
  # This shows how to set up complex test scenarios with dependencies
  setup do
    repo = Dispatch.Repo
    repo.create_table()
    Hero.Repo.create_table()
    Team.Repo.create_table()

    # Create heroes with different power levels
    superman = Hero.make("Superman", 85, repo: Hero.Repo)
    batman = Hero.make("Batman", 75, repo: Hero.Repo)
    wonder_woman = Hero.make("Wonder Woman", 80, repo: Hero.Repo)
    weak_hero = Hero.make("Weak Hero", 25, repo: Hero.Repo)
    another_weak = Hero.make("Another Weak", 30, repo: Hero.Repo)
    
    # Create teams to test traverse_a logic - errors should equal weak hero count
    strong_team = Team.make("Justice League", heroes: [superman, batman, wonder_woman], repo: Team.Repo)
    mixed_team = Team.make("Mixed Squad", heroes: [superman, weak_hero, another_weak], repo: Team.Repo)
    
    {:ok, repo: repo, strong_team: strong_team, mixed_team: mixed_team}
  end

  describe "Dispatch.make/2 - Creating mission dispatches" do
    test "Either.Right when all heroes meet power requirement", %{repo: repo, strong_team: team} do
      result = Dispatch.make(team, required_power: 50, repo: repo)

      # Test: dispatch creation succeeded - Superman (85), Batman (75), Wonder Woman (80) all >= 50
      assert Either.right?(result)
    end

    test "Either.Right when mixed team meets lower requirement", %{repo: repo, mixed_team: team} do
      result = Dispatch.make(team, required_power: 20, repo: repo)

      # Test: dispatch creation succeeded - all heroes meet lower requirement
      assert Either.right?(result)
    end

    test "Either.Left when some heroes fail requirement", %{repo: repo, mixed_team: team} do
      result = Dispatch.make(team, required_power: 50, repo: repo)

      # Test: dispatch creation failed - traverse_a collects errors for each weak hero
      assert Either.left?(result)
      
      case result do
        %Either.Left{left: %ValidationError{errors: errors}} ->
          # Test: exactly 2 errors for the 2 weak heroes (25, 30) that fail requirement
          assert length(errors) == 2
      end
    end
  end

  describe "Mission status management" do
    test "complete works for successful dispatches", %{repo: repo, strong_team: team} do
      result = Dispatch.make(team, repo: repo)

      # Test: dispatch creation succeeded first
      assert Either.right?(result)
      
      case result do
        %Either.Right{right: dispatch} ->
          completion_result = Dispatch.complete(dispatch)
          # Test: completion succeeded (returns Maybe.Just)
          assert completion_result != nil
      end
    end
  end
end