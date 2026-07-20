# Functional Programming Usage Rules

This playground demonstrates functional programming patterns using the Funx library. When working with this codebase, follow these principles to stay functional and learn effectively.

## Critical: Use Funx Library Usage Rules

The Funx library includes comprehensive usage rules for each module:
- `deps/funx/lib/usage-rules.md` - Complete index of available guidance
- `deps/funx/lib/monad/either/usage-rules.md` - Error handling patterns
- `deps/funx/lib/monad/maybe/usage-rules.md` - Optional value handling
- And many more (see the index)

**Always consult the relevant Funx usage rules** when working with monads, predicates, or other functional patterns.

## Domain-Driven Design First

**Critical Learning**: Domain modeling conversations come before coding.

### Example Domain Discussion

When adding new features, ask domain questions first:
- *"What's the relationship between entities?"*
- *"Who has the authority to perform this operation?"*  
- *"Should entity A do this, or does entity B handle it?"*
- *"Are these requirements intrinsic or contextual?"*

**Key Principle:**
- **🎯 Don't ask**: "How do I write this with Maybe/Either?"
- **🎯 Ask**: "What are the domain rules, and which patterns best express them?"

Functional programming shines when it **accurately models business logic**.

## Core Functional Patterns

### Domain Model Structure

Every domain entity follows this functional pattern:

```elixir
defmodule MyEntity do
  import Funx.Predicate
  import Funx.Monad
  alias Funx.Monad.{Either, Maybe}
  alias Funx.Errors.ValidationError

  # Type definition with enforce_keys
  @type t :: %__MODULE__{id: pos_integer(), name: String.t()}
  @enforce_keys [:id, :name]
  defstruct [:id, :name]

  # Domain constants
  @default_name "Default"

  # Constructor & Change Functions (never fail, auto-save)
  def make(name, opts \\ []) do
    %__MODULE__{id: unique_id(), name: name}
    |> heal()
    |> MyEntity.Repo.save()
    |> Either.to_try!()
  end
  
  def change(entity, attrs) do
    entity
    |> struct(attrs)
    |> heal()
    |> MyEntity.Repo.save()
    |> Either.to_try!()
  end
  
  def unsafe_change(entity, attrs), do: entity |> struct(attrs)

  # Validation Functions (Either-wrapped, collect errors)
  def validate(entity), do: entity |> Either.validate([&ensure_name/1])
  
  def ensure_name(entity) do
    entity
    |> Either.lift_predicate(p_not(&invalid_name?/1), fn e -> "Invalid name: #{e.name}" end)
    |> Either.map_left(&ValidationError.new/1)
  end

  # Predicates (boolean checks, grouped together)
  def invalid_name?(%__MODULE__{name: name}), do: name == @default_name

  # Self-Healing (transforms invalid -> valid)
  def heal(entity), do: %__MODULE__{entity | name: heal_name(entity.name)}
  defp heal_name(name) when is_binary(name) and byte_size(name) > 0, do: name
  defp heal_name(_), do: @default_name

  # Field Accessors (encapsulation)  
  def name(%__MODULE__{name: name}), do: name

  # Business Rules (Maybe for capability checks)
  def some_capability?(entity), do: entity |> Maybe.lift_predicate(&has_capability?/1)
end
```

### Repository Pattern

```elixir
defmodule MyEntity.Repo do
  import Funx.Monad
  import Funx.Utils, only: [curry: 1]
  alias Funx.Monad.Either

  def save(entity) do
    insert_entity = curry(&Store.insert_item/2)
    entity |> MyEntity.validate() |> bind(insert_entity.(@table_name))
  end

  def get(id), do: Store.get_item(@table_name, id) |> map(fn data -> struct(MyEntity, data) |> MyEntity.heal() end)
end
```

## CRITICAL: Stay Functional

**Never use these imperative patterns:**
- **No case statements** in functional pipelines - use `Either.lift_predicate/3` instead
- **No manual Either.left/Either.right construction** - use monadic functions
- **No fighting the monads** - let them handle the control flow

**Always use these functional patterns:**
- **Either.traverse/2** for validating lists (fail-fast on missing items)
- **Either.traverse_a/2** for collecting ALL errors
- **curry/curry_r** to compose functions in pipelines
- **Extract predicates** into pure boolean functions
- **Long pipelines** with `|>` for point-free style

### Functional Composition Examples

```elixir
# Good: Long pipeline (preferred style)
%MyEntity{}
|> heal()
|> MyEntity.Repo.save()
|> Either.to_try!()

# Good: Either.lift_predicate instead of case
entity |> Either.lift_predicate(&valid?/1, &error_message/1)

# Good: Cross-domain validation with traverse
Team.Repo.get(team_id)
|> bind(fn team ->
  team.member_ids
  |> Either.traverse(&Member.Repo.get/1)      # Fail fast on missing
  |> bind(Either.traverse_a(validate_member)) # Collect ALL errors
end)

# Good: Pure predicate extraction
defp member_meets_requirement?(requirement, member) do
  Member.score(member) >= requirement.minimum_score
end
```

## Either vs Maybe Usage

- **Either**: When you need specific error context ("validation failed", "invalid email")
- **Maybe**: For simple presence/absence ("dispatchable", "not found")

## Key Learning Points

### Never-Fail vs Validation
- **Constructor never fails**: `make/3` + healing + auto-save ensures valid structures
- **Validation is separate**: `validate/1` checks business rules, returns errors
- **Two concerns**: Data integrity (healing) vs domain rules (validation)

### Functional Composition
- **Kleisli functions**: `a -> Maybe a` compose beautifully with `traverse/2`
- **Monadic chains**: `map/2` for transformations, `bind/2` for chaining
- **Protocol polymorphism**: Same operations work across different types

### Testing Strategy
- Use `unsafe_change/2` to create invalid entities for testing
- Test both happy path and error accumulation
- Verify self-healing behavior

## Essential Usage Rules for LLMs

When working on this project, you must consult **two layers** of usage rules:

### 1. This Project's Usage Rules (this file)
Functional programming patterns and principles for this playground

### 2. Funx Library Usage Rules  
**Main Index**: `deps/funx/lib/usage-rules.md` - Complete list of available guidance

**Key modules**:
- `deps/funx/lib/monad/either/usage-rules.md` - Error handling patterns
- `deps/funx/lib/monad/maybe/usage-rules.md` - Optional value handling
- `deps/funx/lib/monad/usage-rules.md` - Core monadic composition
- `deps/funx/lib/predicate/usage-rules.md` - Logical composition
- And more (see index)

**CRITICAL**: Always consult the relevant Funx usage rules when working with monads, predicates, or functional patterns.

## Working with This Playground

**Context**: This is a **learning-focused playground** for functional programming.

**Always start by reading usage rules:**
1. Read this file for functional programming principles
2. Consult relevant Funx usage rules for specific patterns
3. Look at existing code (Hero, Team, Dispatch) for examples

**Guidelines for LLMs:**
- **Follow functional programming principles meticulously** - this repo demonstrates best practices
- **Educational clarity over performance** - code should teach, not optimize
- **Complete patterns** - show the full Domain Model + Repository pattern
- **Functional purity** - demonstrate proper monadic composition, avoid imperative patterns
- **Self-documenting code** - structure and naming should make patterns obvious

**When Adding Features:**
- **Consult usage rules first** - both local and Funx library rules
- **Follow established domain model pattern** (see Hero.ex as template)
- **Add to both domain and repository layers** for completeness  
- **Include predicates, validation, healing, and business rules**
- **Focus on demonstrating concepts** - this is educational

**Working with Users:**
- **Encourage domain discussions** before jumping to implementation
- **Reference usage rules** when explaining patterns or making suggestions  
- **Show connections** between domain concepts and functional patterns
- **Suggest experimentation** - this is a playground for learning
- **Point out anti-patterns** if you see imperative code creeping in

## Project Structure

### Core Domain Model
- `lib/hero.ex` - Complete domain entity with all Funx patterns
- `lib/team.ex` - Aggregate pattern with hero management
- `lib/dispatch.ex` - Cross-domain validation with business rules
- `lib/*/repo.ex` - Repository pattern with monadic composition
- `lib/store.ex` - Generic storage abstraction with Either handling

### Learning Resources
- `example.txt` - Interactive commands to copy/paste into IEx
- `usage-rules.md` - This file - functional programming guidance
- `CLAUDE.md` - Claude-specific technical guidance

## Learning Path

1. **Start with Hero.ex** - Complete domain model showing all patterns
2. **Try `example.txt` commands** - See patterns in action interactively  
3. **Examine repositories** - Functional persistence with monadic composition
4. **Read both usage rules** - Understand principles behind the code
5. **Experiment freely** - Modify, extend, break things and learn

## Interactive Examples

```elixir
# In iex -S mix:
# Create tables first
Hero.Repo.create_table()
Team.Repo.create_table() 
Dispatch.Repo.create_table()

# Create heroes with self-healing
superman = Hero.make("Superman", 85, powers: [:flight, :strength])
weak_hero = Hero.make("Weak", -10, powers: [:hope])  # Gets healed to minimum

# Create teams (stores hero_ids, not full objects)
team = Team.make("Justice League", heroes: [superman, weak_hero])

# Try cross-domain validation (will collect ALL errors)
Dispatch.make(team, mission: "Impossible Mission", required_power: 90)
```

Remember: This is a learning environment. The patterns here are designed to teach functional programming concepts through realistic domain modeling and hands-on experimentation.