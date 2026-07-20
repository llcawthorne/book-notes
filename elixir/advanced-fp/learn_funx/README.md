# Learn Funx

A practice environment for learning functional programming in Elixir with your LLM as a tutor.
It complements the *Advanced Functional Programming with Elixir* book and the Funx library by providing hands-on code that feels like a real project—non-trivial, imperfect, and full of design choices and oversights to explore and improve.

## Ecosystem

- **[Advanced Functional Programming with Elixir](https://pragprog.com/titles/jkelixir/advanced-functional-programming-with-elixir)** — a book that provides the structured learning path and theory.
- **[Interactive Livebooks](https://github.com/JKWA/funpark_notebooks)** — notebooks for every chapter, runnable in your browser or with Docker.
- **[Funx library](https://hex.pm/packages/funx)** — universal functional patterns in Elixir, with usage rules for LLMs.  
- **[Learn Funx](https://github.com/JKWA/learn_funx)** — a practice environment for using your LLM as a tutor.  
- **[Discord](https://discord.gg/mFaCAy9Sqd)** — community space to discuss *Advanced Functional Programming with Elixir* (the book), the Funx library, and Learn Funx.
## Quick Start

```bash
git clone https://github.com/JKWA/learn_funx
cd learn_funx  
mix deps.get
```

Then launch your LLM (Claude, ChatGPT, or another assistant) and tell it to look for the usage-rules in this project and in Funx.

## Working with LLMs

LLMs (ChatGPT, Claude, etc.) are powerful learning partners, but they need guidance.

**Start with context:**

Tell your LLM something like:

> “There are usage rules for this project and the Funx library. Follow those functional patterns.”

**Use an iterative approach:**

1. **Talk first** – Discuss the idea before coding
2. **Small experiments** – “Let’s try just this one rule”
3. **Course correction** – Steer when they drift toward imperative logic
4. **Pattern recognition** – Let them discover and reinforce good structure
5. **Scale up** – Only expand once the pattern is solid

This keeps things focused and prevents over-engineering.

**Example conversation flow:**

1. “How should we handle validation with Either?”
2. “Show just one rule, in isolation”
3. “Good, but remember the usage rules about avoiding case statements”
4. “Now apply the same pattern across the others”

**Keep them on track:**

* Reintroduce usage rules as sessions grow longer
* Watch for imperative habits creeping in
* Ask for small, targeted changes instead of large rewrites

## Learning Path

This project contains non-trivial code written in a functional style. It isn’t a polished demo. Like any real codebase, it’s full of design choices and oversights that you can explore and learn from with the help of an LLM.

**1. Explore by hand**

* Walk through `example.txt` in the root directory and paste commands into IEx

**2. Use questions to guide learning**

* See `questions.md` in the root for learning goals and prompts
* Use them with LLMs or for self-assessment

**3. Modify and extend**

* Add new entities, rules, or capabilities
* Ask where the patterns hold and where they get in the way

## Contributing

Contributions are welcome! This is a learning resource, so anything that helps others understand functional programming better is especially appreciated.

**Ways to contribute:**

* Improve domain logic or fix bugs
* Enhance learning content (`example.txt`, `questions.md`, `CLAUDE.md`)
* Add test cases that clarify behavior
* Refine documentation or usage instructions
* Propose new domain features that highlight core concepts
* Improve guidance for LLM-based workflows

See [`CONTRIBUTORS.md`](CONTRIBUTORS.md) for details and contributor recognition.
