# Rust Resources

Free (mostly) resources to come back to. Folders in this repo are noted where
I've set one up.

## Finding Things

- [docs.rs](https://docs.rs) - API docs and examples for every crate on
  crates.io, at `https://docs.rs/<crate>/latest/<crate>/`.
- [std docs](https://doc.rust-lang.org/std/) - the standard library (`String`,
  `Vec`, `HashMap`, `Option`, `Result`, ...).
- [crates.io](https://crates.io) - the package registry;
  [lib.rs](https://lib.rs) is a friendlier index of it, organized by category.
- `cargo doc --open` - builds docs for the current project and every
  dependency at the exact versions in `Cargo.lock`, and opens them offline.
- `K` in Neovim - hover docs for whatever's under the cursor.
- [The Little Book of Rust Books](https://lborb.github.io/book/) - a
  catalog of free online Rust books (official, unofficial, and by topic).
  Check here first when looking for a book on something specific.

## Already Working Through

- [The Rust Programming Language](https://rust-book.cs.brown.edu) (Brown
  version with quizzes) - `the-rust-programming-language/`
- [Rustlings](https://rustlings.rust-lang.org) - `rustlings/`
- [Rust by Example](https://doc.rust-lang.org/rust-by-example/) -
  `rust-by-example/`

## While Still in TRPL

- [100 Exercises to Learn Rust](https://rust-exercises.com) by Luca Palmieri
  (Zero to Production author). Every exercise is a failing test to make pass;
  builds up to a small ticketing system with traits, threads, and async. The
  site is more current than the epub. - `100-exercises/`
- [Comprehensive Rust](https://google.github.io/comprehensive-rust/) - Google's
  four-day internal course with exercises. Faster pass over TRPL's ground; good
  for review. - `comprehensive-rust/`
- [Rust Cookbook](https://rust-lang-nursery.github.io/rust-cookbook/) - short
  recipes for everyday tasks (files, JSON, HTTP, regex, concurrency). Reference,
  not a read-through.
- [Rust by Practice](https://practice.course.rs) - exercises and small projects
  covering nearly all of Rust (async, threads, sync primitives, std, tooling,
  data structures); make each exercise compile and run without errors or
  panics. Ranked easy to "super hard," solutions included, editable and
  runnable online. Some examples borrowed from Rust by Example. (The domain
  now redirects to practice-rust.beatai.org.)

## Projects

- [Hecto](https://www.flenker.blog/hecto/) - build a small text editor in Rust,
  step by step. Repo's `main` branch is the 2024 rewrite. - `hecto/`
- [Command Line Applications in Rust](https://rust-cli.github.io/book/) - short
  official book on CLI apps (clap, testing, packaging). Pairs with *Rust:
  Tools*. - `command-line-applications-in-rust/`
- [Tokio tutorial](https://tokio.rs/tokio/tutorial) - official async tutorial
  that builds mini-redis. Gentlest intro to async Rust; do it right before the
  Redis clone book. - `tokio-tutorial/`
- [Rust Projects - Write a Redis Clone](https://rust-projects-write-a-redis-clone.github.io)
  (`redis-clone/`)
- [Writing an OS in Rust](https://os.phil-opp.com) - after unsafe (TRPL ch20)
  and async. - `writing-an-os/`
- [Crafting Interpreters](https://craftinginterpreters.com) - written in Java
  and C; porting the Lox interpreter to Rust is a popular project. Pairs with
  the Monkey plans (`writing-an-interpreter/`).
- [Writing Interpreters in Rust: a Guide](https://rust-hosted-langs.github.io/book/)
  (`writing-interpreters-in-rust/`): building an interpreter plus its own
  garbage-collected memory allocator. Unfinished, especially the GC chapters.
- [Build a Lua Interpreter in Rust](https://wubingzheng.github.io/build-lua-in-rust/en/)
  (`build-lua-in-rust/`): written by someone who had just finished TRPL, using
  a Lua interpreter as their first big Rust project. Code for each chapter;
  machine-translated from Chinese, so the prose is rough.

## After TRPL

- [Learning Rust With Entirely Too Many Linked Lists](https://rust-unofficial.github.io/too-many-lists/)
  (`too-many-linked-lists/`): ownership, `Box`, `Rc`, `RefCell`, and unsafe
  via linked lists, over and over. Best after TRPL ch15.
- [Rust Atomics and Locks](https://marabos.nl/atomics/) by Mara Bos (free
  online) - concurrency from the ground up: atomics, memory ordering, building
  locks and channels.
- [Effective Rust](https://effective-rust.com) (free online) - 35 short items
  on idioms for people past the basics. Free counterpart to *Idiomatic Rust*
  (`idiomatic-rust/`).
- [Rust Design Patterns](https://rust-unofficial.github.io/patterns/) - idioms,
  patterns, and anti-patterns.
- [Rust API Guidelines](https://rust-lang.github.io/api-guidelines/) - how to
  design a library's public API.
- [The Rust Performance Book](https://nnethercote.github.io/perf-book/) by
  Nicholas Nethercote - profiling and optimization.
- [Rust Telemetry Workshop](https://rust-exercises.com/telemetry/) (Mainmatter,
  same site as 100 Exercises) - one-day hands-on course on observability:
  logging, tracing, and metrics with the Rust telemetry ecosystem. Exercises in
  github.com/mainmatter/rust-telemetry-workshop; solutions on its `solutions`
  branch.
- [API Development with Rust](https://rust-api.dev) - free book on REST APIs
  with axum and tokio: SQL and NoSQL persistence, JWT/OAuth, tracing and
  OpenTelemetry, metrics, caching, throttling, testing, CI/CD, and cloud
  deployment. Assumes TRPL. An axum counterpart to *Zero to Production*
  (actix-web).
- [The Rustonomicon](https://doc.rust-lang.org/nomicon/) - unsafe Rust and how
  the safe abstractions are built.

## Testing

### Naming Tests

Test names are function names, so no spaces. Nested modules give RSpec-style
`describe`/`context`/`it` names joined by `::`. Each module needs its own
`use super::*;`.

```rs
#[cfg(test)]
mod mode {                          // describe "mode"
    use super::*;

    mod when_the_list_is_empty {    // context "when the list is empty"
        use super::*;

        #[test]
        fn returns_none() {         // it "returns none"
            assert_eq!(mode(&[]), None);
        }
    }

    mod when_values_tie {
        use super::*;

        #[test]
        fn returns_the_smallest() {
            assert_eq!(mode(&[3, 1, 3, 1]), Some(1));
        }
    }
}
// cargo test prints: mode::when_the_list_is_empty::returns_none
//                    mode::when_values_tie::returns_the_smallest
```

### Testing Courses

- [Advanced Rust Testing](https://rust-exercises.com/advanced-testing/)
  (Mainmatter): one-day hands-on course past the built-in toolkit: better
  assertions with googletest, snapshot testing with insta, mocks with mockall,
  filesystem and database isolation (`sqlx::test`), HTTP mocking with
  wiremock, and writing test macros. Solutions on the repo's `solutions`
  branch.

### Testing Crates

- [rstest](https://docs.rs/rstest/latest/rstest/) - pytest-style fixtures and
  parametrized tests: `#[rstest]` with `#[case(...)]` lines runs one test per
  case (like Go's table-driven tests or Spock's `where:` blocks), and
  `#[fixture]` functions inject shared setup.

  ```rs
  use rstest::rstest;

  // #[case] = one test per row; `case::name` labels the generated test
  #[rstest]
  #[case::rectangle(Shape::Rectangle { width: 12.0, height: 6.0 }, 72.0)]
  #[case::circle(Shape::Circle { radius: 10.0 }, 314.159_265_358_979)]
  #[case::triangle(Shape::Triangle { base: 12.0, height: 6.0 }, 36.0)]
  fn area(#[case] shape: Shape, #[case] want: f64) {
      // floats: compare within a tolerance, not with assert_eq!
      let got = shape.area();
      assert!((got - want).abs() < 1e-9, "got {got}, want {want}");
  }
  // names: area::case_1_rectangle, area::case_2_circle, ...

  // #[values] = every combination: 3 x 2 = 6 tests
  #[rstest]
  fn scaling_keeps_area_positive(
      #[values(1.0, 2.5, 10.0)] width: f64,
      #[values(1.0, 0.5)] scale: f64,
  ) {
      let rect = Shape::Rectangle { width: width * scale, height: 4.0 };
      assert!(rect.area() > 0.0);
  }
  ```

  The docs have good examples of `#[fixture]`, `#[values]`, and `#[case]`:
  <https://docs.rs/rstest/latest/rstest/>

- [test-case](https://docs.rs/test-case/) - like `#[case]`, but each case gets
  a plain-English description string that becomes the test name. `=>` gives
  the expected return value (an implicit `assert_eq!`).

  ```rs
  use test_case::test_case;

  #[test_case(&[] => None ; "returns none for an empty list")]
  #[test_case(&[3, 1, 2] => Some(2.0) ; "returns the middle of an odd list")]
  #[test_case(&[4, 1, 3, 2] => Some(2.5) ; "averages the middle two")]
  fn median_works(v: &[i32]) -> Option<f64> {
      median(v)
  }
  // names: median_works::test_case_1_returns_none_for_an_empty_list, ...
  ```

- [approx](https://docs.rs/approx/) - `assert_relative_eq!` and
  `assert_abs_diff_eq!` for float comparisons, instead of hand-rolled
  tolerances.
- [pretty_assertions](https://docs.rs/pretty_assertions/) - drop-in
  `assert_eq!` with colored diffs; one `use` line per test module.
- [proptest](https://docs.rs/proptest/) - property-based testing, the Rust
  take on QuickCheck/Hypothesis.

### Multi-line Strings

Plain string literals already span lines, so check whether these are enough
before adding a dependency:

```rs
// A literal can span lines; the newline and the next line's indentation
// are part of the string.
let plain = "line one
    line two"; // "line one\n    line two"

// `\` at the end of a line continues the string and drops the next line's
// leading whitespace (and the newline). Good for wrapping one long line.
let wrapped = "one long sentence, \
               continued without indentation";
// "one long sentence, continued without indentation"

// Raw strings skip escape processing, like Go's backticks.
let raw = r#"C:\path\to "quoted" file"#;

// .trim() strips the leading/trailing whitespace of the whole string,
// but not the indentation of lines in the middle.
let edges = "
    keep my indentation
    "
.trim(); // "keep my indentation"
```

- [indoc](https://docs.rs/indoc/) - `indoc!` removes the common leading
  indentation at compile time, like Kotlin's `trimIndent()`. It also drops the
  newline right after the opening quote. `formatdoc!` is `format!` plus
  `indoc!`, and there are `printdoc!`/`eprintdoc!` too.

  ```rs
  use indoc::{formatdoc, indoc};

  let text = indoc! {"
      line one
        indented line
      line three
  "};
  // "line one\n  indented line\nline three\n"

  let name = "Lewis";
  let greeting = formatdoc! {"
      Hello, {name}!
        You have {count} new messages.
      ",
      count = 3,
  };
  // "Hello, Lewis!\n  You have 3 new messages.\n"
  ```

## Books Most Rust Developers Know

The core three are TRPL, *Programming Rust*, and *Rust for Rustaceans*.

- *Programming Rust* (Blandy, Orendorff & Tindall, O'Reilly, 2nd ed. 2021) -
  the other big comprehensive book; more thorough and systems-minded than
  TRPL, with excellent explanations of memory layout. Great as a reference or
  second pass (iterators and memory chapters especially).
- *Rust for Rustaceans* (Jon Gjengset, No Starch, 2021) - the standard "next
  book after TRPL": types and layout, API design, errors, testing, macros,
  async, unsafe, and FFI. Short but dense; read after *Rust: Tools*, around
  *Zero to Production*, once I've hit the problems it explains. Same author as
  Crust of Rust.
- *Rust Atomics and Locks* (Mara Bos, O'Reilly, 2023) - the concurrency book
  (free online; listed under After TRPL).
- *Zero to Production in Rust* (Luca Palmieri) - the backend/web book. -
  `zero-to-prod/`
- *Rust in Action* (Tim McNamara, Manning) - hands-on systems projects: a CPU
  emulator, key-value store, networking.

## Ongoing

- [Crust of Rust](https://www.youtube.com/playlist?list=PLqbS7AVVErFiWDOAVrPt7aYmnuuOLYvOa)
  by Jon Gjengset (YouTube) - long, careful dives into one intermediate topic
  each (lifetimes, iterators, smart pointers, channels). Best after the book.
- [This Week in Rust](https://this-week-in-rust.org) - weekly newsletter; has
  an RSS feed.
- [This Month in Rust OSDev](https://rust-osdev.com) - monthly; RSS at
  <https://rust-osdev.com/rss.xml>.

## Top Three to Slot In

1. *100 Exercises to Learn Rust* now, alongside TRPL.
2. The Tokio tutorial right before the Redis clone.
3. *Too Many Linked Lists* after TRPL ch15.
