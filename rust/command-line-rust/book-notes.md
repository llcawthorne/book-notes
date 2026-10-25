# Command-Line Rust

## Chapter 1 - Truth or Consequences

- Functions are defined using `fn`, `println!` is a macro and will print text to
  STDOUT, and the body of a function is enclosed in curly braces

  ```rs
  // 01_hello/src/main.rs
  fn main() {
      println!("Hello, world!");
  }
  ```

- There are three types of comment. `//` for an ordinary comment. `///` for a
  doc comment on the item below it. And `//!` for a doc comment for the whole
  file or module (usually at the top of main.rs or lib.rs). Markdown works in
  doc comments.
- Create a new `hello` project with `cargo new hello`. To match the author's
  directories, we then `mv hello 01_hello`. The project name will be saved as
  `hello`, since it is what we named it on creation. *Cargo.toml* is a
  configuration file for this project. The *src* directory is for Rust source
  code files. And *main.rs* is the default starting point for Rust programs.
  `cargo run` will compile and run the program in one command. If you don't
  care about status messages, you could `cargo run --quiet` or `-q`. If you
  wonder what you can do with cargo, just run `cargo` for USAGE. After you
  `cargo run` or `cargo build` (or `cargo b`), you will have a `hello` executable
  in *target/debug*. By default Cargo builds a *debug* target. The Cargo.toml
  specifies the executable is `hello`:

  ```toml
  # 01_hello/Cargo.toml
  [package]
  name = "hello"
  version = "0.1.0"
  edition = "2021"

  [dependencies]
  ```

- Note we changed the edition to "2021" to match the book. The current default is
  "2024". You can learn more about keys and their definitions in Cargo.toml at
  <https://doc.rust-lang.org/cargo/reference/manifest.html>.
- Rust libraries are called *crates* and they are expected to use *semantic
  version numbers* in the form *major.minor.patch*, so that 1.2.4 is major
  verison 1, minor version 2, patch version 4. A change in a major version
  indicates a breaking change in the crate's public API.
- Rust is expression-based. A `;` turns an expression into a statement,
  discarding its value. The last expression in a block, written without a
  `;`, becomes the block's value (e.g. a function's return value). With a
  trailing `;`, the block evaluates to `()` instead.
- *Inside-out* or *unit testing* is when you write tests for the functions inside
  your program. We will start using it in Chapter 4. *Outside-in* or *integration
  testing* is when you write tests that run your programs as the user might.
  We will begin writing integration tests now, even for `hello`.
  The convention in Rust projects is to create a *tests* drectory parallel to the
  *src* directory. Unit tests go in the same file as the code. Integration tests
  go in `tests/` and are compiled as a separate program that only have access to
  your crate's public API.

  ```rs
  // 01_hello/tests/cli.rs
  #[test]
  fn works() {
      assert!(true);
  }
  ```

- If you want to see the test fail, change `true` to `false`.
- All tests in this book will use `assert!` to verify that some expectation is
  `true` or `assert_eq!` to verify that something is an expected value. Here we
  are asserting `true`, which will always succeed. Run this test with 
  `cargo test`. `cargo test -q` produces less output, and you can edit your
  `~/.cargo/config.toml` to make `cargo t` always run `cargo test -q` with:

  ```rs
  // ~/.cargo/config.toml
  [alias]
  t = "test -q"
  ```

- A popular alternative test runner is `cargo-nextest` installed with
  `cargo install cargo-nextest` and run with `cargo nextest run` unless you setup
  an alias. You could add an alias like the following for really quiet testing:

  ```rs
  // ~/.cargo/config.toml
  [alias]
  nt = "nextest run --cargo-quiet --status-level fail --final-status-level fail"
  ```

- `cargo nt` then prints:
  - nothing while compiling (--cargo-quiet), unless there’s a build error
  - nothing for passing tests (--status-level fail)
  - full output for any failure, both as it happens and again at the end 
    (--final-status-level fail)
  - one summary line, like Summary [0.4s] 12 tests run: 12 passed
- Note when using `cargo-nextest` doctests aren't run, so you would still want to
  run `cargo test --doc` occasionally to exercise them if you have any.
- Let's make our first test useful

  ```rs
  use std::process::Command;

  #[test]
  fn runs() {
      let mut cmd = Command::new("ls");
      let res = cmd.output();
      assert!(res.is_ok());
  }
  ```

- Import `std::process::Command` imports `Command` from the *standard library*
  which you can tell from `std`. We use `Command::new` to run `ls`, and we use
  the `mut` keyword to signify it can change. We store the output in `res` as a
  `Result` and verify that it is an `Ok` variant.
- We can change the command to `hello`, but it will fail because the `hello`
  program can't be found. `std::process::Command` only runs commands on the PATH.
  We need a way to execute binaries that exist only in  the current crate. We aregoing to add the `assert_cmd` development dependency to Cargo.toml and use it.

  ```toml
  # 01_hello/Cargo.toml
  [package]
  name = "hello"
  version = "0.1.0"
  edition = "2021"

  [dependencies]

  [dev-dependencies]
  assert_cmd = "2.0.13"
  pretty_assertions = "1.4.0"
  ```
  
  ```rs
  // 01/hello/test/cli.rs
  use assert_cmd::Command;

  #[test]
  fn runs() {
      let mut cmd = Command::cargo_bin("hello").unwrap();
      cmd.assert().success();
  }
  ```

- This is a command to run `hello` in the current crate, `unwrap` the `Result`
  to cause a panic and fail if it isn't found, and use `Assert::success` to
  ensure the command succeeded. Our test now passes.
- Command-line program should report final exit status of 0 for success (think
  zero errors) or any number from 1 to 255 otherwise. Every program we write in
  this book will be expected to return zero when they terminate normally and
  non-zero in case of error. You can see the return value of the last run program
  with `echo $?`. `true` always returns 0, and `false` always non-zero, so let's
  write both ourselves:

  ```rs
  // 01_hello/src/bin/true.rs
  fn main() {
      std::process::exit(0);
  }

  // 01_hello/src/bin/false.rs
  fn main() {
      std::process::exit(1);
  }

  // 01/hello/test/cli.rs
  #[test]
  fn true_ok() {
      let mut cmd = Command::cargo_bin("true").unwrap();
      cmd.assert().success()
  }

  #[test]
  fn false_not_ok() {
      let mut cmd = Command::cargo_bin("false").unwrap();
      cmd.assert().failure();
  }
  ```

- We can run new exe's with `cargo run --quiet --bin true` and
  `cargo run --quiet --bin false`, and `cargo b` generates three executables now.
  If you run the programs and run `echo $?` you will see 1 or 0. `cargo test`
  runs all three of our tests. You'll note their order is random because they are
  run in parallel. To run in order use `cargo test -- --test-threads=1`. Since we
  don't have any unit tests, we can reduce output by running:
  `cargo test -q --test cli`. Test shows separate unit test runs for each binary
  so a regular `cargo test -q` shows four different results, three of 0 tests.
- You could also write false with `std::process::abort();` as the body.
- It's more interesting to check the output of `hello`, so let's do that now:

  ```rs
  #[test]
  fn runs() {
      let mut cmd = Command::cargo_bin("hello").unwrap();
      cmd.assert().success().stdout("Hello, world!\n");
  }
  ```

- Return codes make it safe to chain programs such as `true && ls`. `ls` only
  executes if `true` returns 0. `false && ls` doesn't execute the `ls`.
- Second edition changes. Here's the whole `runs()` test from second edition:

  ```rs
  use assert_cmd::Command;
  use pretty_assertions::assert_eq;

  #[test]
  fn runs() {
      let mut cmd = Command::cargo_bin("hello").unwrap();
      let output = cmd.output().expect("hello binary should run");
      assert!(output.status.success());
      let stdout = String::from_utf8(output.stdout)
          .expect("stdout should be valid UTF-8");
      assert_eq!(stdout, "Hello, world!\n");
  }
  ```
- The main changes from the 1st edition are using `expect()` and
  `String::from_utf8`.
- Read the `expect()` message as the reason you expect success ("should..."),
  not as an expected result. `.unwrap()` does the same with a generic message.
- `let output = cmd.output().expect("hello binary should run");` runs the
  binary. `output()` returns a `Result`: on `Ok`, `expect` unwraps the value
  into `output`; on `Err`, it panics, printing the message and the error, which
  fails the test.
- `cmd` must be `mut` because `output()` takes `&mut self` (it modifies `cmd`
  while running it). Rust decides this from the method's signature.
- `output` is a struct. We assert its `status` is `success()`.
- `output.stdout` is raw bytes (`Vec<u8>`), which may not be valid UTF-8, so
  `String::from_utf8` returns a `Result` too. We convert it to a `String` and
  assert it equals `"Hello, world!\n"`.
- `assert_eq!` here comes from `pretty_assertions`, which shows a colored diff
  on failure. It and `assert_cmd` were added as dev dependencies with
  `cargo add --dev assert_cmd@2 pretty_assertions@1` (or by editing
  `Cargo.toml`).

## Chapter 2 - Test for Echo

- We are going to write `echo`, which prints its arguments to STDOUT. If given
  the `-n` option, it will not print a trailing newline.
- The return type of a Rust function can be indicated by an arrow and the type,
  such as `-> u32`. The lack of a return type implies that the function returns
  the *unit* type. Exit codes are not the same as return values.
- `std::env` contains functions to interact with the environment. We will use
  `std:;env::args` to get the command-line arguments. We says it returns `Args`
  by `pub fn agrs() -> Args`. If you go to the link for the `Args` documentation,
  you'll find it is a *struct*. We can print the arguments like so:

  ```rs
  fn main() {
      println!("{:?}", std::env::args());
  }
  ```
- Note that we cannot use `println!(std::env::args())` because `println!`
  requires a string literal (the format string) as its first argument. We
  also cannot use `println!("{}", std::env::args())` because `Args` cannot be
  formatted with the default formatter, which would require it to implement
  `std::fmt::Display`. The `Args` documentation at
  <https://doc.rust-lang.org/stable/std/env/struct.Args.html> confirms that
  `Display` is not one of its implemented traits. However, `Debug` is
  implemented, so we can use `"{:?}"` to print a `Debug` version of the
  structure, as the compiler message helpfully tells us. That compiles and
  runs:

  ```sh
  $ cargo run
     Compiling echor v0.1.0 (/Users/llcawthorne/git/book-notes/rust/command-line-rust/02_echor)
      Finished `dev` profile [unoptimized + debuginfo] target(s) in 0.23s
       Running `target/debug/echor`
  Args { inner: ["target/debug/echor"] }

  $ cargo run Hello world
      Finished `dev` profile [unoptimized + debuginfo] target(s) in 0.00s
       Running `target/debug/echor Hello world`
  Args { inner: ["target/debug/echor", "Hello", "world"] }

  $ cargo run -- -n Hello world
      Finished `dev` profile [unoptimized + debuginfo] target(s) in 0.01s
       Running `target/debug/echor -n Hello world`
  Args { inner: ["target/debug/echor", "-n", "Hello", "world"] }
  ```

- Note that `cargo run Hello world -n` works, but `cargo run -n Hello world` does
  not since `-n` is interpreted as an argument to `cargo run`, so we need to run
  this as `cargo run -- -n Hello world` to pass a `-n` argument first.
- The book now goes in to argparsing, but I don't have the second version which
  is significantly updated. so I am going to stop here until I can fix that.
