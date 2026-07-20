# Learn Funx — Questions to Guide Your Exploration

This document contains guided questions to help you explore functional programming concepts through the Funx library. When working with an LLM, start by asking it to review the usage rules in this project and the Funx library (`deps/funx/lib/usage-rules.md`) for complete context.

## Table of Contents

- [🟢 Beginner — Core Functional Concepts](#-beginner--core-functional-concepts)
- [🟡 Intermediate — Composing Patterns](#-intermediate--composing-patterns)  
- [🔴 Advanced — Architectural Principles](#-advanced--architectural-principles)
- [🧪 Sample Code — Concepts in Practice](#-sample-code--concepts-in-practice)
- [📚 Attribution and Ecosystem](#-attribution-and-ecosystem)

## 🟢 Beginner — Core Functional Concepts

**💡 Tip:** Ask your LLM to review the usage rules first for complete context and accurate answers.

### `Eq`

- What's the point of implementing `Eq` when I can just use `==`?
- When would I want different ways to check if things are equal?
- How do I combine multiple equality checks together?
- I keep seeing `contramap`—what does it actually do?

### `Ord`

- Why implement custom ordering instead of just sorting by a field?
- What's `contramap` doing differently here than with `Eq`?
- How does lexicographic ordering work when I combine multiple comparisons?
- When should I care about custom sorting behavior?

### Predicate

- What's a predicate, and why not just use regular boolean functions?
- I see `p_not`—is this different from just using `!`?
- How do `p_all` and `p_any` work? When would I use each?
- What's the benefit of composing predicates instead of writing one big validation?

### Fold

- What does "folding" actually mean?
- Why fold instead of pattern matching?
- When should I fold versus stay in the monad?
- What's this "catamorphism" thing about?

### Currying and Point-Free Style

- When do we need currying?
- How is currying different from Elixir’s `&fun/2` capture syntax?
- Why `curry_r` instead of regular `curry`?
- What does "point-free" mean, and why would I want it?

### Functional vs Imperative

- What makes code "functional" versus "imperative"?
- Why avoid `case` statements in pipelines?
- What does "data flows through transformations" really mean?
- Why are long pipelines better than nested function calls?

## 🟡 Intermediate — Composing Patterns

### Monoids

- What are monoids good for?
- Why do callers seldom see monoids?
- Why are monoids so powerful for composition?
- How do we use monoids with `Eq`, `Ord`, and `Predicate`?

### Monads

- What’s a Kleisli function, and how is it special?
- When do I use `map` versus `bind`?
- How does `bind` eliminate defensive coding?
- Why doesn’t Elixir have separate `Functor` and `Applicative` protocols?

### Maybe vs Either

- When do I need `Either` versus `Maybe`?
- How does `fold` work differently on each?
- Why not just use `Either` everywhere since it carries more info?
- What breaks when I mix `Either` and `Maybe` in pipelines?

### Collection Strategies

- How is `traverse` different from `map`?
- What is `traverse_a` good for?
- Why does `traverse_a` need a list of errors instead of a single error?
- How does `validate` work?

## 🔴 Advanced — Architectural Principles

### Monadic Composition

- How does `lift_predicate` help make illegal states unrepresentable in a monad chain?
- Which functions need Kleisli functions versus regular functions?
- Why prefer long pipelines over other approaches?
- How do I decide which monad to use?

### `Effect` Monad

- What's the difference between `Effect` and `Either`?
- Why is `Effect` computation deferred or lazy?
- How does `Effect` combine `Reader` and `Either` patterns?
- What happens when I call `run/2` on an `Effect`?
- How do I lift regular functions into an `Effect`?
- What’s the difference between `sequence` and `sequence_a` for `Effect`s?
- When might `Effect` be a poor choice?

### Testing Functional Code

- Why test monadic behavior instead of raw field values?
- How do I create invalid test data safely?
- Why use `fold` in assertions instead of pattern matching?
- What does testing success and failure reveal about domain logic?

## 🧪 Sample Code — Concepts in Practice

### Self-Healing Constructors

- Why doesn’t `Hero.make("", -10)` throw an error?
- How is `Hero.make` different from `Hero.validate`?
- When would I want a constructor that never fails?
- What happens to invalid data in `Hero.make`?

### Cross-Domain Validation

- How does `Dispatch.make` validate heroes from just a team parameter?
- Why does `Dispatch` use `traverse` followed by `traverse_a`?
- What’s the business logic behind this two-step validation?
- Why can’t I dispatch weak heroes even if most are strong?

### Repository Pattern

- Why do repos use `curry(&Store.insert_item/2)` instead of calling directly?
- How does currying help with dependency injection?
- Why store `hero_ids` instead of full `Hero` structs in teams?
- How does this prevent circular dependencies?

### Domain Architecture

- Why do `Hero` and `Team` heal, but `Dispatch` returns `Either`?
- How does the `Hero → Team → Dispatch` relationship show different validation strategies?
- What determines whether a constructor should heal or validate?
- How does this architecture handle changing requirements?

### Testing the Sample Code

- What’s `unsafe_change` for, and why is it only used in tests?
- Why test `Either.right?` instead of checking status fields?
- How do the test patterns reveal what’s important to verify?
- Why create multiple heroes or teams in test setup?

## 📚 Attribution and Ecosystem

### Attribution

- Where does the context for your answers come from?
- What are other sources to learn about functional programming?
- Can you recommend any books?

### Elixir Ecosystem Context

- How do we tackle functional programming in a dynamically typed system?
- What other FP libraries exist in the Elixir ecosystem?
- How does Elixir’s actor model influence FP design?
- What’s the difference between keeping errors within the context versus "just letting it fail"?
