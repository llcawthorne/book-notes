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
  `std::env::args` to get the command-line arguments. Its signature is
  `pub fn args() -> Args`. If you go to the link for the `Args` documentation,
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
- Command-line arguments like `-h` and `-n` are often called *flags* because they
  don't take a value. Flags have one meaning when present and the opposite when
  absent. All the other arguments are *positional* because their position
  relative to the name of the program (the first element in the arguments)
  determines their meaning.
- We need to add clap to our dependencies. The easy way is to edit *Cargo.toml*:

  ```toml
  # 02_echor/Cargo.toml
  [package]
  name = "echor"
  version = "0.1.0"
  edition = "2024"

  [dependencies]
  clap = "4.5.0"
  ```

- When you add a dependency, `cargo` places the source in *~/.cargo* and build
  artifacts in *target/debug/deps* directory of the project. Each project can use
  different versions of crates, and each program is built in a separate
  directory. This makes `target` a pretty large directory; currently 35 MB. If
  you aren't going to work with a project for a while, it can save disk space to
  run `cargo clean` which deletes the `target` directory.
- <https://docs.rs/> is a good place to read documentation on clap and other
  libraries.
- Clap offers two patterns for creating a parser called *derive* and *builder*.
  We will mostly use *derive* throughout this book, as we are following *main*,
  but here is an example of using clap with the *builder* pattern:

  ```rs
  // 02_echor/src/main.rs
  use clap::Command;

  fn main() {
      let _matches = Command::new("echor")
          .version("0.1.0")
          .author("Ken Youens-Clark <kyclark@gmail.com>")
          .about("Rust version of `echo`")
          .get_matches();
  }
  ```

- In the above example, the leading `_` in `_matches` is functional. It tells the
  compiler we do not plan to use the variable, so we do not get an unused
  variable warning.
- That code is enough to get the `-h` or `--help` option working for help and
  the `-V` and `--version` to display version information. We can handle our
  other arguments by defining the parameters using the `clap::Arg` struct:

  ```rs
  // 02_echor/src/main.rs
  use clap::{Arg, ArgAction, Command};

  fn main() {
      let matches = Command::new("echor")
          .version("0.1.0")
          .author("Ken Youens-Clark <kyclark@gmail.com>")
          .about("Rust version of `echo`")
          .arg(
              Arg::new("text")
                  .value_name("TEXT")
                  .help("Input text")
                  .required(true)
                  .num_args(1..),
          )
          .arg(
              Arg::new("omit_newline")
                  .short('n')
                  .action(ArgAction::SetTrue)
                  .help("Do not print newline"),
          )
          .get_matches();
      println!("{:#?}", matches);
  }
  ```

- Note here we are using `"{:#?}"` as a print format to pretty print the `Debug`
  value. For this structure, it generates a lot of pretty printed output. So we
  can run this and see this parses our arguments.
- Now we want to extract the `text` argument, which can be one or more strings.
  In the following code, we first call `ArgMatches::get_many` to retrieve
  multiple values for an argument. This call returns an `Option` since it may
  not succeed, but we know clap requires the user to provide at least one value,
  so it is safe to call `Option::unwrap`. The result is an `Iterator` of string
  values that need to be cloned. Finally, we use `Iterator::collect` to put the
  strings into a `Vec`.

  ```rs
  let text: Vec<String> =
      matches.get_many("text").unwrap().cloned().collect();
  ```

- The type annotation on `text` is required, because `Iterator::collect` can
  return many different types.
- There are two types of memory: stack and heap. Data types like integers that
  live on the stack can be easily copied. The strings of input to our program
  live on the heap with their address stored on the stack as a *pointer*, which
  is said to be a *reference* to the data. Objects on the heap can be very large,
  so to copy them you need to use an action called *clone* to acknowledge this.
  Here we are cloning our `String` values.
- Getting `omit_newline` is simpler, because it's a `bool`. We use
  `ArgMatches::get_flag`:

  ```rs
  let omit_newline = matches.get_flag("omit_newline");
  ```

- There is a `print!` macro that does not print a newline at the end (unlike
  `println!`).

  ```rs
  let ending = if omit_newline { "" } else { "\n" };
  print!("{}{ending}", text.join(" "));
  ```

- But since we use `ending` in only one place, we can instead write this:

  ```rs
  print!("{}{}", text.join(" "), if omit_newline { "" } else { "\n" });
  ```

- And with this we have a working `echo` program. But we need tests to make sure
  it really matches the original!
- We will use a number of dependencies for testing listed in `dev-dependencies`:

  ```toml
  # 02_echor/Cargo.toml
  [package]
  name = "echor"
  version = "0.1.0"
  edition = "2024"

  [dependencies]
  clap = "4.5.0"

  [dev-dependencies]
  anyhow = "1.0.79"
  assert_cmd = "2.0.13"
  predicates = "3.0.4"
  pretty_assertions = "1.4.0"
  ```

- And we'll start with a simple test that ensures our program dies with a "Usage"
  message when given no arguments.

  ```rs
  // 02_echor/tests/cli.rs
  use assert_cmd::Command;
  use predicates::prelude::*;

  #[test]
  fn dies_no_args() {
      let mut cmd = Command::cargo_bin("echor").unwrap();
      cmd.assert()
          .failure()
          .stderr(predicate::str::contains("Usage"));
  }
  ```

- The author suggests putting "dies" in the name of any test where the program is
  expected to fail. Then you can easily run them with `cargo test dies`.
- And we'll add a simple test to make sure our command succeeds with an argument:

  ```rs
  #[test]
  fn runs() {
      let mut cmd = Command::cargo_bin("echor").unwrap();
      cmd.arg("hello").assert().success();
  }
  ```

- The author makes expected outputs with a `mk-outs.sh` shell script included in
  his Git repo. We have copied that over and used it. We will write tests to
  compare output of our program to the expected output. We will need to add
  `use std::fs` to *tests/cli.rs* to bring in the standard filesystem module.

  ```rs
  #[test]
  fn hello1() {
      let outfile = "tests/expected/hello1.txt";
      let expected = fs::read_to_string(outfile).unwrap();
      let mut cmd = Command::cargo_bin("echor").unwrap();
      cmd.arg("Hello there").assert().success().stdout(expected);
  }
  ```

- `fs::read_to_string` is a convenient way to read an entire file, but only use
  it for files you know to be small in size.
- The author finds `anyhow::Result` easier to use than the default `Result`, and
  will begin using that and stop playing fast and loose with `unwrap`. Now our
  tests will return `anyhow::Result`. We also eliminated the `runs` test since
  other tests make sure our code runs now. Here is our current *cli.rs*:

  ```rs
  // 02_echor/tests/cli.rs
  use anyhow::Result;
  use assert_cmd::Command;
  use predicates::prelude::*;
  use std::fs;

  #[test]
  fn dies_no_args() -> Result<()> {
      let mut cmd = Command::cargo_bin("echor")?;
      cmd.assert()
          .failure()
          .stderr(predicate::str::contains("Usage"));
      Ok(())
  }

  #[test]
  fn hello1() -> Result<()> {
      let expected = fs::read_to_string("tests/expected/hello1.txt")?;
      let mut cmd = Command::cargo_bin("echor")?;
      cmd.arg("Hello there").assert().success().stdout(expected);
      Ok(())
  }
  ```

- **`anyhow::Result` vs Standard `Result`**:
  `anyhow::Result<T>` is a type alias for `core::result::Result<T, anyhow::Error>`
  where the error type `E` defaults to `anyhow::Error`.
  - **Universal `?` error conversion**: Any error implementing `std::error::Error`
    automatically converts into `anyhow::Error` via `?`, so you can mix different
    errors (`io::Error`, `FromUtf8Error`, `CargoError`, etc.) in the same function
    without custom error types or conversion boilerplate.
  - **Context chains**: Provides `.context("...")` and `.with_context(|| ...)` on
    `Result` to attach meaningful explanations, producing nested causal chains
    (`Caused by: ...`). Bring `anyhow::Context` into scope to use them. Use
    `with_context` when building dynamic messages with `format!`, as the closure
    evaluates lazily only if an `Err` occurs (avoiding string allocations on the
    happy path):

    ```rs
    use anyhow::{Context, Result};
    use std::fs;

    fn read_config(filename: &str) -> Result<String> {
        fs::read_to_string(filename)
            .with_context(|| format!("Failed to read config file '{filename}'"))
    }
    // If it fails, anyhow prints:
    // Error: Failed to read config file 'config.toml'
    //
    // Caused by:
    //     No such file or directory (os error 2)
    ```

  - **Backtraces**: Automatically captures backtraces on failure when
    `RUST_BACKTRACE=1`.
  - **Rule of Thumb**:

    | Use Case | Recommended | Why |
    | :--- | :--- | :--- |
    | **Libraries** (crates/APIs) | Concrete error types or `thiserror` | Callers can inspect and `match` on specific error variants programmatically. |
    | **Applications & Tests** (binaries, CLI tools, tests) | `anyhow` | You just want errors to bubble up cleanly with actionable context and messages. |

- Now we'll add a test to test with two arguments:

  ```rs
  #[test]
  fn hello2() -> Result<()> {
      let expected = fs::read_to_string("tests/expected/hello2.txt")?;
      let mut cmd = Command::cargo_bin("echor")?;
      cmd.args(vec!["Hello", "there"])
          .assert()
          .success()
          .stdout(expected);
      Ok(())
  }
  ```

- There's no better time to refactor than when tests are passing. So we are going
  to define a helper function. As you may have noticed, we're still asserting our
  output like the 1st edition of the book, so while writing a helper we are going
  to take the opportunity to use `pretty_assertions::assert_eq!` instead. We're
  also using `&[&str]` (a slice of string slices) for the arguments. Slices
  (`&[...]`) are borrowed views into contiguous sequences of elements; like
  vectors, but fixed in length. Here is our final test suite:

  ```rs
  // 02_echor/tests/cli.rs
  use anyhow::Result;
  use assert_cmd::Command;
  use predicates::prelude::*;
  use pretty_assertions::assert_eq;
  use std::fs;

  #[test]
  fn dies_no_args() -> Result<()> {
      let mut cmd = Command::cargo_bin("echor")?;
      cmd.assert()
          .failure()
          .stderr(predicate::str::contains("Usage"));
      Ok(())
  }

  fn run(args: &[&str], expected_file: &str) -> Result<()> {
      let expected = fs::read_to_string(expected_file)?;
      let output = Command::cargo_bin("echor")?
          .args(args)
          .output()
          .expect("fail");

      let stdout = String::from_utf8(output.stdout).expect("invalid UTF-8");
      assert_eq!(stdout, expected);
      Ok(())
  }

  #[test]
  fn hello1() -> Result<()> {
      run(&["Hello there"], "tests/expected/hello1.txt")
  }

  #[test]
  fn hello2() -> Result<()> {
      run(&["Hello", "there"], "tests/expected/hello2.txt")
  }

  #[test]
  fn hello1_no_newline() -> Result<()> {
      run(&["Hello  there", "-n"], "tests/expected/hello1.n.txt")
  }

  #[test]
  fn hello2_no_newline() -> Result<()> {
      run(&["-n", "Hello", "there"], "tests/expected/hello2.n.txt")
  }
  ```

- Now our tests are green, so we'll handle another large refactor. We are going
  to change clap to use the derive pattern. First we need to add the feature,
  either by updating the clap line in *Cargo.toml* to say
  `clap = { version = "4.5.0", features = ["derive"] }` or by running
  `cargo add clap --features derive`. In the derive pattern we define a struct
  to represent the command-line arguments. We will also be using doc comments
  (`///`) to document our arguments and these comments will appear in help as
  well. Here is a version of main that parses the arguments and prints out the
  resulting struct:

  ```rs
  // 02_echor/src/main.rs
  use clap::Parser;

  #[derive(Debug, Parser)]
  #[command(author, version, about)]
  /// Rust version of `echo`
  struct Args {
      /// Input text
      #[arg(required(true))]
      text: Vec<String>,

      /// Do not print newline
      #[arg(short('n'))]
      omit_newline: bool,
  }

  fn main() {
      let args = Args::parse();
      dbg!(args);
  }
  ```

- And after viewing the resulting struct, it's easy to see how to get this
  passing tests again.

  ```rs
  fn main() {
      let args = Args::parse();
      print!(
          "{}{}",
          args.text.join(" "),
          if args.omit_newline { "" } else { "\n" }
      );
  }
  ```

## Chapter 3 - On the Catwalk

- For this chapter we will implement `cat` in Rust. Given three files *a*, *b*,
  and *c*, `cat a b c > all` should stream all the lines from these three files
  into the new file *all*. If `-` is provided as a filename, the program should
  use stdin as input. If no files are given then it should default to using stdin
  as if `-` was provided. The program will accept a couple of different options,
  including two different ones to prefix lines with line number.
  `-b / --number-nonblank` will number non-blank lines and `-n / --number` will
  number all lines. The line number is right-justified in a field six characters
  wide followed by a tab character and then a line of text.
- In this chapter, we will just copy over the entire `tests` folder from the
  source repo. These tests don't look very different from the last chapter but
  have more variety of expected outputs.
- So let's handle our arguments first. I'm only going to cover the derive
  pattern, and you can see builder on the repo if you want it to compare.
  This will parse our arguments and pass our first test for `usage`:

  ```rs
  // 03_catr/src/main.rs
  use clap::Parser;

  #[derive(Debug, Parser)]
  #[command(author, version, about)]
  /// Rust version of `cat`
  struct Args {
      /// Input file(s)
      #[arg(value_name = "FILE", default_value = "-")]
      files: Vec<String>,

      /// Number lines
      #[arg(short('n'), long("number"), conflicts_with("number_nonblank_lines"))]
      number_lines: bool,

      /// Number non-blank lines
      #[arg(short('b'), long("number-nonblank"))]
      number_nonblank_lines: bool,
  }

  fn main() {
      let args = Args::parse();
      println!("{args:#?}");
  }
  ```

- This shows us our args. For the next step we will print each filename on a
  line:

  ```rs
  use anyhow::Result;
  use clap::Parser;

  // ...declare Args...

  fn main() {
      if let Err(e) = run(Args::parse()) {
          eprintln!("{e}");
          std::process::exit(1);
      }
  }

  fn run(args: Args) -> Result<()> {
      for filename in args.files {
          println!("{filename}");
      }
      Ok(())
  }
  ```

- Ok, so we aren't passing anymore tests yet, but we can provide our program a
  list of filenames and it parses them and prints them back out. We need to learn
  a little about opening files to do more. First we need some imports:

  ```rs
  use std::fs::File;
  use std::io::{self, BufRead, BufReader};
  ```

- Here is a function that takes a filename and returns either an error or a
  boxed value that implements the `BufRead` trait:

  ```rs
  fn open(filename: &str) -> Result<Box<dyn BufRead>> {
      match filename {
          "-" => Ok(Box::new(BufReader::new(io::stdin()))),
          _ => Ok(Box::new(BufReader::new(File::open(filename)?))),
      }
  }
  ```

- If `File::open` is successful, the result will be a *filehandle* of the type
  `std::fs::File`, which allows us to read the contents of a file. Both a
  filehandle and `std::io::stdin` implement the `Read` trait that a `BufReader`
  struct will use to implement the `BufRead` trait. This means the return value
  from `open` will respond to the `BufRead::lines` function to produce lines of
  text. This function will also remove any line endings.
- The return type includes the `dyn` keyword to say that the return type's trait
  is dynamically dispatched. This allows us to abstract over the idea of the
  input source and easily expand to read from a socket or webpage or any other
  source that implements `BufRead`. The return type is placed into a `Box`, which
  is a way to store a value on the heap. Without the `Box`, you would get the
  compilation error:

  ```text
  error[E0277]: the size for values of type `(dyn BufReader + 'static)`
  cannot be known at compilation time
  ```

- If a variable doesn't have a fixed, known size, then Rust can't store it on the
  stack. Instead we put it on the heap by putting the return value into a `Box`,
  which is a pointer with a known size.
- We can see that the `open` function works by adjusting `run` to call it:

  ```rs
  fn run(args: Args) -> Result<()> {
      for filename in args.files {
          match open(&filename) {
              Err(err) => eprintln!("Failed to open {filename}: {err}"),
              Ok(_) => println!("Opened {filename}"),
          }
      }
      Ok(())
  }
  ```

- Before we look at the final code to pass the tests, let's spend a little more
  time looking at the differences in this chapter's tests from the last.
- The imports are mostly the same except for `std::fs` and `rand`:

  ```rs
  use anyhow::Result;
  use assert_cmd::Command;
  use predicates::prelude::*;
  use pretty_assertions::assert_eq;
  use rand::{distributions::Alphanumeric, Rng};
  use std::fs;
  ```

- We declare some `const` values at the top of the module that we use throughout
  the crate. We used the convention of `ALL_CAPS` names to highlight that they
  are scoped throughout the crate:

  ```rs
  const PRG: &str = "catr";
  const EMPTY: &str = "tests/inputs/empty.txt";
  const FOX: &str = "tests/inputs/fox.txt";
  const SPIDERS: &str = "tests/inputs/spiders.txt";
  const BUSTLE: &str = "tests/inputs/the-bustle.txt";
  ```

- And then we use `rand` to generate a bad filename:

  ```rs
  fn gen_bad_file() -> String {
      loop {
          let filename: String = rand::thread_rng()
              .sample_iter(&Alphanumeric)
              .take(7)
              .map(char::from)
              .collect();

          if fs::metadata(&filename).is_err() {
              return filename;
          }
      }
  }
  ```

- `fs::metadata` will return `Err` on a non-existent file. We borrow the filename
  when passing it, then transfer ownership when we return. So we can use the
  non-existent file in `skips_bad_file`:

  ```rs
  #[test]
  fn skips_bad_file() -> Result<()> {
      let bad = gen_bad_file();
      let expected = format!("{bad}: .* [(]os error 2[)]");
      Command::cargo_bin(PRG)?
          .arg(&bad)
          .assert()
          .success()
          .stderr(predicate::str::is_match(expected)?);
      Ok(())
  }
  ```

- Notice we want `success` for a bad filename. `cat` just outputs an error to
  stderr on a bad file, but it doesn't crash or return non-zero.
- `run` hasn't changed much to run our utility and compare it to expected output:

  ```rs
  fn run(args: &[&str], expected_file: &str) -> Result<()> {
      let expected = fs::read_to_string(expected_file)?;
      let output = Command::cargo_bin(PRG)?.args(args).output().unwrap();
      assert!(output.status.success());

      let stdout = String::from_utf8(output.stdout).expect("invalid UTF-8");
      assert_eq!(stdout, expected);

      Ok(())
  }
  ```

- Note we're still unwrapping our exe output and using expect on the utf8
  conversion, but these should never fail in practice.
- We use `runs` like before:

  ```rs
  #[test]
  fn bustle() -> Result<()> {
      run(&[BUSTLE], "tests/expected/the-bustle.txt.out")
  }
  ```

- There's a similar `run_stdin` that runs with input set to stdin and pipes
  an input file to our program:

  ```rs
  fn run_stdin(
      input_file: &str,
      args: &[&str],
      expected_file: &str,
  ) -> Result<()> {
      let input = fs::read_to_string(input_file)?;
      let expected = fs::read_to_string(expected_file)?;
      let output = Command::cargo_bin(PRG)?
          .write_stdin(input)
          .args(args)
          .output()
          .unwrap();
      assert!(output.status.success());

      let stdout = String::from_utf8(output.stdout).expect("invalid UTF-8");
      assert_eq!(stdout, expected);
      Ok(())
  }
  ```

- And we can use `run_stdin` but it must have no args or `"-"` as an arg:

  ```rs
  #[test]
  fn bustle_stdin() -> Result<()> {
      run_stdin(BUSTLE, &["-"], "tests/expected/the-bustle.txt.stdin.out")
  }
  ```

- And the final solution for passing the 20 tests:

  ```rs
  // 03_catr/src/main.rs
  use anyhow::Result;
  use clap::Parser;
  use std::fs::File;
  use std::io::{self, BufRead, BufReader};

  #[derive(Debug, Parser)]
  #[command(author, version, about)]
  /// Rust version of `cat`
  struct Args {
      /// Input file(s)
      #[arg(value_name = "FILE", default_value = "-")]
      files: Vec<String>,

      /// Number lines
      #[arg(short('n'), long("number"), conflicts_with("number_nonblank_lines"))]
      number_lines: bool,

      /// Number non-blank lines
      #[arg(short('b'), long("number-nonblank"))]
      number_nonblank_lines: bool,
  }

  fn main() {
      if let Err(e) = run(Args::parse()) {
          eprintln!("{e}");
          std::process::exit(1);
      }
  }

  fn run(args: Args) -> Result<()> {
      for filename in args.files {
          match open(&filename) {
              Err(err) => eprintln!("Failed to open {filename}: {err}"),
              Ok(file) => {
                  let mut prev_num = 0;
                  for (line_num, line) in file.lines().enumerate() {
                      let line = line?;
                      if args.number_lines {
                          println!("{:>6}\t{line}", line_num + 1);
                      } else if args.number_nonblank_lines {
                          if line.is_empty() {
                              println!();
                          } else {
                              prev_num += 1;
                              println!("{prev_num:>6}\t{line}");
                          }
                      } else {
                          println!("{line}");
                      }
                  }
              }
          }
      }
      Ok(())
  }

  fn open(filename: &str) -> Result<Box<dyn BufRead>> {
      match filename {
          "-" => Ok(Box::new(BufReader::new(io::stdin()))),
          _ => Ok(Box::new(BufReader::new(File::open(filename)?))),
      }
  }
  ```

- Note when iterating over the result of `file.lines()`, you get back a `Result`
  rather than getting the lines directly. `std::io::Result` is the standard
  return type in `std::io` for any operation that might produce an error.
- In `println!` we can use `{line_num:>6}` to display our `line_num` in a six
  character field and right justified. `<6` would be left justified, and `^6`
  is centered. We instead use `{:>6}` and pass in the calculation `line_num + 1`
  since you can't put a calculation directly in a placeholder.
- `line` has an `is_empty` method we can use instead of using `line != ""`.
- I did the line counter by incrementing a mutable variable, but the book had an
  example of using an iterator. Using `Iterator::enumerate` is more idiomatic.
  It still uses a manual counter for numbering nonblank lines though.

## Chapter 4 - Head Aches

- `head` defaults to showing you the first 10 lines of 1 or more files and has
  `-n` option to control the number of lines shown and `-c` to instead show some
  number of bytes. If no files are provided, it processes stdin. When more than
  one file is specified, each file is preceded by a header.
- Our argument parser has some new features now, mostly around accepting
  numbers:

  ```rs
  // 04_headr/src/main.rs
  #[derive(Debug, Parser)]
  #[command(author, version, about)]
  /// Rust version of `head`
  struct Args {
      /// Input file(s)
      #[arg(value_name = "FILE", default_value = "-")]
      files: Vec<String>,

      /// Number of lines
      #[arg(
          short('n'),
          long,
          default_value = "10",
          value_name = "LINES",
          value_parser = clap::value_parser!(u64).range(1..),
      )]
      lines: u64,

      /// Number of bytes
      #[arg(
          short('c'),
          long,
          value_name = "BYTES",
          conflicts_with("lines"),
          value_parser = clap::value_parser!(u64).range(1..)
      )]
      bytes: Option<u64>,
  }
  ```

- I don't recall setting `value_name` and `value_parser` is definitely new.
  The `long` name defaults to the variable name but the `short` name defaults
  to the first letter of the variable name, and we want `n` and `c`. The
  `default_value` takes a string.
- We put most of our logic in a `run` function we call from `main` again, and
  we also re-use the `open` function from last chapter.
- The book points out several different ways you could handle the file. Here's
  a convenient way if we just wanted X lines and weren't worried about
  preserving file endings:

  ```rs
  fn run(args: Args) -> Result<()> {
      for filename in args.files {
          match open(&filename) {
              Err(err) => eprintln!("{filename}: {err}"),
              Ok(file) => {
                  for line in file.lines().take(args.lines as usize) {
                      println!("{}", line?);
                  }
              }
          }
      }
      Ok(())
  }
  ```

- And here's a clever way to read X bytes from a file without setting up a
  buffer in advance:

  ```rs
  let bytes: Result<Vec<_>, _> = file.bytes().take(num_bytes as usize).collect();
  print!("{}", String::from_utf8_lossy(&bytes?));
  ```

- You could also use the turbofish operator (`::<>`) to declare the type at the
  call site rather than in the variable type annotation:

  ```rs
  let bytes = file
      .bytes()
      .take(num_bytes as usize)
      .collect::<Result<Vec<_>, _>>();
  print!("{}", String::from_utf8_lossy(&bytes?));
  ```

- **Why use `read(&mut buffer)` and `read_line` over the iterator shortcuts?**
  1. **Bulk I/O vs. Byte-by-byte overhead**: `file.read(&mut buffer)` tells the OS
     to copy the bytes in a single bulk `read` system call directly into
     pre-allocated memory. In contrast, `file.bytes().take().collect()` calls an
     iterator for *every single byte*, wrapping each in a `Result<u8, io::Error>`
     and dynamically reallocating the `Vec` as it grows.
  2. **Preserving exact line endings**: `file.lines()` strips `\r\n` and `\n`,
     and `println!` always forces a Unix `\n`. If a file uses Windows CRLF
     (`\r\n`) or ends without a trailing newline, `file.lines()` + `println!`
     alters the output. `file.read_line(&mut line)` retains the exact line
     endings from the input.
- Here's the final code that preserves line endings and properly handles UTF8:

  ```rs
  // 04_headr/src/main.rs
  use anyhow::Result;
  use clap::Parser;
  use std::fs::File;
  use std::io::{self, BufRead, BufReader, Read};

  #[derive(Debug, Parser)]
  #[command(author, version, about)]
  /// Rust version of `head`
  struct Args {
      /// Input file(s)
      #[arg(value_name = "FILE", default_value = "-")]
      files: Vec<String>,

      /// Number of lines
      #[arg(
          short('n'),
          long,
          default_value = "10",
          value_name = "LINES",
          value_parser = clap::value_parser!(u64).range(1..),
      )]
      lines: u64,

      /// Number of bytes
      #[arg(
          short('c'),
          long,
          value_name = "BYTES",
          conflicts_with("lines"),
          value_parser = clap::value_parser!(u64).range(1..)
      )]
      bytes: Option<u64>,
  }

  fn main() {
      if let Err(e) = run(Args::parse()) {
          eprintln!("{e}");
          std::process::exit(1);
      }
  }

  fn run(args: Args) -> Result<()> {
      let num_files = args.files.len();

      for (file_num, filename) in args.files.iter().enumerate() {
          match open(&filename) {
              Err(err) => eprintln!("{filename}: {err}"),
              Ok(mut file) => {
                  if num_files > 1 {
                      println!(
                          "{}==> {filename} <==",
                          if file_num > 0 { "\n" } else { "" },
                      );
                  }
                  if let Some(num_bytes) = args.bytes {
                      let mut buffer = vec![0; num_bytes as usize];
                      let bytes_read = file.read(&mut buffer)?;
                      print!(
                          "{}",
                          String::from_utf8_lossy(&buffer[..bytes_read])
                      );
                  } else {
                      let mut line = String::new();
                      for _ in 0..args.lines {
                          let bytes = file.read_line(&mut line)?;
                          if bytes == 0 {
                              break;
                          }
                          print!("{line}");
                          line.clear();
                      }
                  }
              }
          }
      }
      Ok(())
  }

  fn open(filename: &str) -> Result<Box<dyn BufRead>> {
      match filename {
          "-" => Ok(Box::new(BufReader::new(io::stdin()))),
          _ => Ok(Box::new(BufReader::new(File::open(filename)?))),
      }
  }
  ```

## Chapter 5 - Word to Your Mother

- For this chapter we will be writing `wc` (word count). It will display the
  number of lines, words, and bytes found in text from STDIN or one or more
  files. It takes the options `-c` for bytes, `-l` for number of lines, `-m` for
  number of characters (which is the same as `-c` unless there are multibyte
  characters), and `-w` for number of words. When options are provided, it only
  displays the results for the options, but with no options it defaults to `-c`,
  `-l`, and `-w`. The order of output is always line, word, bytes/chars, and
  file name. The values are output in right-justified columns eight characters
  wide. If processing more than one file, it displays values for each file and
  a *total* line at the end of output for all files combined.
- Iterator Methods That Take A Closure
  - `Iterator::all` returns `true` if all evaluations of the closure for an
     item return `true`.
  - `Iterator::any` returns `true` if one evaluation of the closure for an item
     returns `true`.
  - `Iterator::filter` will find all elements for which the predicate is `true`.
  - `Iterator::map` will apply a closure to each element and return a
    `std::iter::Map` with the transformed elements.
  - `Iterator::find` will return the first element of an iterator that satisfies
    the predicate as `Some(value)` or `None` if all elements evaluate to `false`.
  - `Iterator::position` will return the index of the first element that
    satisfies the predicate as `Some(value)` or `None` if all elements evaluate
    to `false`.
  - `Iterator::cmp`, `Iterator::min_by`, and `Iterator::max_by` have predicates
    that accept pairs of items for comparison or to find the minimum and
    maximum.
- Our `count` function returns a `FileInfo` struct with the values. Here we
  derive `PartialEq` so we can use `assert_eq!` in our tests.

  ```rs
  #[derive(Debug, PartialEq)]
  struct FileInfo {
      num_lines: usize,
      num_words: usize,
      num_bytes: usize,
      num_chars: usize,
  }
  ```

- In our tests, we use `std::io::Cursor` to fake a filehandle for the `count`
  function. A `Cursor` is "used with in-memory buffers, anything implementing
  `AsRef<[u8]>`, to allow them to implement `Read` and/or `Write`, allowing
  these buffers to be used anywhere you might use a reader or writer that does
  actual I/O."
- We can place dependencies in the `test` module so they are only compiled when
  we test our program.

  ```rs
  #[cfg(test)]
  mod tests {
      use super::{FileInfo, count};
      use std::io::Cursor;

      #[test]
      fn test_count() {
          let text = "I don't want the world.\nI just want your half.\r\n";
          let info = count(Cursor::new(text));
          assert!(info.is_ok());
          let expected = FileInfo {
              num_lines: 2,
              num_words: 10,
              num_chars: 48,
              num_bytes: 48,
          };
          assert_eq!(info.unwrap(), expected);
      }
  }
  ```

- It was a smart decision making a `format_field` function that takes a number
  and a bool telling you whether we're showing it or not. We could easily pass
  it our value with our bool from `Args` for that value.

  ```rs
  fn format_field(value: usize, show: bool) -> String {
      if show {
          format!("{value:>8}")
      } else {
          "".to_string()
      }
  }
  ```

- `format_field` also got its own test for don't show, single digit, and two
  digit values.

  ```rs
  #[test]
  fn test_format_field() {
      assert_eq!(format_field(1, false), "");
      assert_eq!(format_field(3, true), "       3");
      assert_eq!(format_field(10, true), "      10");
  }
  ```

- Using `format_field` we are able to make one `println!` that works no matter
  what the arguments are:

  ```rs
  println!(
       "{}{}{}{}{}",
       format_field(info.num_lines, args.lines),
       format_field(info.num_words, args.words),
       format_field(info.num_bytes, args.bytes),
       format_field(info.num_chars, args.chars),
       if filename == "-" {
           "".to_string()
       } else {
           format!(" {filename}")
       }
  );
  ```

- Here's the entire solution:

  ```rs
  // 05_wcr/src/main.rs
  use anyhow::Result;
  use clap::Parser;
  use std::fs::File;
  use std::io::{self, BufRead, BufReader};

  #[derive(Debug, Parser)]
  #[command(author, version, about)]
  /// Rust version of `wc`
  struct Args {
      /// Input file(s)
      #[arg(value_name = "FILE", default_value = "-")]
      files: Vec<String>,

      /// Show line count
      #[arg(short, long)]
      lines: bool,

      /// Show word count
      #[arg(short, long)]
      words: bool,

      /// Show byte count
      #[arg(short('c'), long)]
      bytes: bool,

      /// Show character count
      #[arg(short('m'), long, conflicts_with("bytes"))]
      chars: bool,
  }

  #[derive(Debug, PartialEq)]
  struct FileInfo {
      num_lines: usize,
      num_words: usize,
      num_bytes: usize,
      num_chars: usize,
  }

  fn main() {
      if let Err(e) = run(Args::parse()) {
          eprintln!("{:?}", e);
          std::process::exit(1);
      }
  }

  fn run(mut args: Args) -> Result<()> {
      // Alter args as needed
      if [args.lines, args.words, args.bytes, args.chars]
          .iter()
          .all(|v| v == &false)
      {
          args.lines = true;
          args.words = true;
          args.bytes = true;
      }
      // println!("{args:#?}");

      let mut total_lines = 0;
      let mut total_words = 0;
      let mut total_bytes = 0;
      let mut total_chars = 0;

      for filename in &args.files {
          match open(filename) {
              Err(err) => eprintln!("{filename}: {err}"),
              Ok(file) => {
                  let info = count(file)?;
                  println!(
                      "{}{}{}{}{}",
                      format_field(info.num_lines, args.lines),
                      format_field(info.num_words, args.words),
                      format_field(info.num_bytes, args.bytes),
                      format_field(info.num_chars, args.chars),
                      if filename == "-" {
                          "".to_string()
                      } else {
                          format!(" {filename}")
                      }
                  );

                  total_lines += info.num_lines;
                  total_words += info.num_words;
                  total_bytes += info.num_bytes;
                  total_chars += info.num_chars;
              }
          }
      }

      if args.files.len() > 1 {
          println!(
              "{}{}{}{} total",
              format_field(total_lines, args.lines),
              format_field(total_words, args.words),
              format_field(total_bytes, args.bytes),
              format_field(total_chars, args.chars),
          )
      }

      Ok(())
  }

  fn open(filename: &str) -> Result<Box<dyn BufRead>> {
      match filename {
          "-" => Ok(Box::new(BufReader::new(io::stdin()))),
          _ => Ok(Box::new(BufReader::new(File::open(filename)?))),
      }
  }

  fn count(mut file: impl BufRead) -> Result<FileInfo> {
      let mut num_lines = 0;
      let mut num_words = 0;
      let mut num_bytes = 0;
      let mut num_chars = 0;
      let mut line = String::new();

      loop {
          let line_bytes = file.read_line(&mut line)?;
          if line_bytes == 0 {
              break;
          }
          num_bytes += line_bytes;
          num_lines += 1;
          num_words += line.split_whitespace().count();
          num_chars += line.chars().count();
          line.clear();
      }

      Ok(FileInfo {
          num_lines,
          num_words,
          num_bytes,
          num_chars,
      })
  }

  fn format_field(value: usize, show: bool) -> String {
      if show {
          format!("{value:>8}")
      } else {
          "".to_string()
      }
  }

  #[cfg(test)]
  mod tests {
      use super::*;
      use std::io::Cursor;

      #[test]
      fn test_count() {
          let text = "I don't want the world.\nI just want your half.\r\n";
          let info = count(Cursor::new(text));
          assert!(info.is_ok());
          let expected = FileInfo {
              num_lines: 2,
              num_words: 10,
              num_chars: 48,
              num_bytes: 48,
          };
          assert_eq!(info.unwrap(), expected);
      }

      #[test]
      fn test_format_field() {
          assert_eq!(format_field(1, false), "");
          assert_eq!(format_field(3, true), "       3");
          assert_eq!(format_field(10, true), "      10");
      }
  }
  ```

## Chapter 6 - Den of Uniquity

- `uniq` is a tool to find the distinct lines of text from either a file or
  STDIN. It has a number of features, but we will only implement the reading of
  a file or STDIN, writing to a file or STDOUT, and count the lines for the `-c`
  flag. When displaying count, the count is right-justified in a field four
  characters wide and is followed by a single space and then the line of text.
- The tests are structured a little differently for this one. First, we have a
  `Test` struct with three `&'static str` fields for `input`, `out`, and
  `out_count`. `out` is the output when the program is run with `input`, and
  `out_count` is the output when the program is run with `input` and the `-c`
  option. There are several test runners. `run` runs the program with `input`
  and checks STDOUT to match `output`. `run_count` does the same but runs with
  `-c` and compares STDOUT to `out_count`. `run_stdin` supplies the input via
  STDIN and compares STDOUT to `out`. `run_stdin_count` does the same but with
  `-c` option and `out_count`. `run_outfile` runs with `input`, writes to a
  `tempfile::NamedTempFile`, and compares the file to `out`. It uses
  `let outfile = NamedTempFile::new()?;` to create the named temp file and
  `let outpath = &outfile.path().to_str().unwrap();` to get its path. The temp
  file is automatically removed when you finish the test. There are also helpers
  for processing STDIN while writing to a temp file and for doing both these
  last two tests with `-c` and comparing results to `out_count`.
- To capture a dynamic value from the environment, you need a closure. The
  following closes over `args.count`:

  ```rs
  let print = |num: u64, text: &str| {
      if num > 0 {
          if args.count {
              print!("{num:>4} {text}");
          } else {
              print!("{text}");
          }
      }
  };
  ```

- That was our first draft of `print`. We had to make it `mut` because the
  `out_file` handle is borrowed as a mutable value and used in `write!`:

  ```rs
  let mut print = |num: u64, text: &str| -> Result<()> {
      if num > 0 {
          if args.count {
              write!(out_file, "{num:>4} {text}")?;
          } else {
              write!(out_file, "{text}")?;
          }
      }
      Ok(())
  };
  ```

- Final code:

  ```rs
  // 06_uniqr/src/main.rs
  use anyhow::{Result, anyhow};
  use clap::Parser;
  use std::{
      fs::File,
      io::{self, BufRead, BufReader, Write},
  };

  #[derive(Debug, Parser)]
  #[command(author, version, about)]
  /// Rust version of `uniq`
  struct Args {
      /// Input file
      #[arg(value_name = "IN_FILE", default_value = "-")]
      in_file: String,

      /// Output file
      #[arg(value_name = "OUT_FILE")]
      out_file: Option<String>,

      /// Show counts
      #[arg(short, long)]
      count: bool,
  }

  fn main() {
      if let Err(e) = run(Args::parse()) {
          eprintln!("{e}");
          std::process::exit(1);
      }
  }

  fn run(args: Args) -> Result<()> {
      let mut file = open(&args.in_file).map_err(|e| anyhow!("{}: {e}", args.in_file))?;

      let mut out_file: Box<dyn Write> = match &args.out_file {
          Some(out_name) => Box::new(File::create(out_name)?),
          _ => Box::new(io::stdout()),
      };

      let mut print = |num: u64, text: &str| -> Result<()> {
          if num > 0 {
              if args.count {
                  write!(out_file, "{num:>4} {text}")?;
              } else {
                  write!(out_file, "{text}")?;
              }
          }
          Ok(())
      };

      let mut line = String::new();
      let mut previous = String::new();
      let mut count: u64 = 0;

      loop {
          let bytes = file.read_line(&mut line)?;
          if bytes == 0 {
              break;
          }

          if line.trim_end() != previous.trim_end() {
              print(count, &previous)?;
              previous = line.clone();
              count = 0;
          }

          count += 1;
          line.clear();
      }

      print(count, &previous)?;
      Ok(())
  }

  fn open(filename: &str) -> Result<Box<dyn BufRead>> {
      match filename {
          "-" => Ok(Box::new(BufReader::new(io::stdin()))),
          _ => Ok(Box::new(BufReader::new(File::open(filename)?))),
      }
  }
  ```

## Chapter 7 - Finders Keepers

- Now we will write a Rust version of the `find` utility. If run with no
  restrictions, it will recursively search one or more paths for entries such as
  files, symbolic links, sockets, and directories. Our version will locate
  files, directories, or links (selected by `-t`)
  in one or more directories having names that
  match one or more regular expressions. Remember that an `*` in a regular
  expression needs to be escaped with a backslash, `find . -name \*.csv`, or
  surrounded by quotes, `find . -name "*.csv"`. You also need to escape
  parentheses in expressions: `find . \( -type f -o -type l \) -name "*.csv"`.
  Items in expressions are and'ed together by default, but you can still
  specify both `-a` and `-and`. You can or items with `-o` or `-or`. You can
  positionally list multiple search paths.
- We will have two new dependencies in this project: `regex` and `walkdir`.
- Per
  [Rust naming conventions](https://rust-lang.github.io/api-guidelines/naming.html),
  types, structs, traits, and `enum` variants use `UpperCamelCase`, also called
  `PascalCase`.
- We are going to use an enum for `-t`. So it can be parsed, we need to
  implement `ValueEnum` trait from `clap`:

  ```rs
  #[derive(Debug, Eq, PartialEq, Clone)]
  enum EntryType {
      Dir,
      File,
      Link,
  }

  impl ValueEnum for EntryType {
      fn value_variants<'a>() -> &'a [Self] {
          &[EntryType::Dir, EntryType::File, EntryType::Link]
      }

      fn to_possible_value(&self) -> Option<PossibleValue> {
          Some(match self {
              EntryType::Dir => PossibleValue::new("d"),
              EntryType::File => PossibleValue::new("f"),
              EntryType::Link => PossibleValue::new("l"),
          })
      }
  }
  ```

- `value_variants` method returns the allowed variants. `to_possible_value`
  converts one of the `enum` variants to strings.
- The lifetime annotation on `value_variants` is actually tied to a subtle
  feature called **Rvalue Static Promotion**. Basically, if an expression is
  made entirely of compile-time constants (pure enum variants, numbers, string
  literals) that require no cleanup/drop logic, it promotes that data to static
  read-only memory. So the lifetime is actually `'static` and guaranteed to
  outlive any requested lifetime `'a`.
- Fun fact! We didn't even need to implement this ourselves with modern clap. It
  could've been derived:

  ```rs
  #[derive(Debug, Eq, PartialEq, Clone, ValueEnum)]
  enum EntryType {
      #[value(name = "d")]
      Dir,
      #[value(name = "f")]
      File,
      #[value(name = "l")]
      Link,
  }
  ```

- Note our `findr` uses real regexes and not the idiosyncratic `find` expression
  language. `find . -name "*.csv"` finds csv's and is equivalent to
  `findr . --name ".*\\.csv$"` or `findr . --name ".*[.]csv$"`. You could also
  use `findr . --name '.*\.csv$'` to avoid escaping the backslash. Remember `*`
  in a regex is zero or more of the previous character, so `.*` is zero or more
  of any character. The author could have made it more `find`-like by using
  the `glob` or `globset` crate, but he chose to teach the `regex` crate.
- Here's a final solution that passes all tests:

  ```rs
  // 07-findr/src/main.rs
  use anyhow::Result;
  use clap::{ArgAction, Parser, ValueEnum, builder::PossibleValue};
  use regex::Regex;
  use walkdir::{DirEntry, WalkDir};

  #[derive(Debug, Parser)]
  #[command(author, version, about)]
  /// Rust version of `find`
  struct Args {
      /// Search path(s)
      #[arg(value_name = "PATH", default_value = ".")]
      paths: Vec<String>,

      /// Names
      #[arg(
          short,
          long = "name",
          value_name = "NAME",
          value_parser(Regex::new),
          action(ArgAction::Append),
          num_args(0..)
      )]
      names: Vec<Regex>,

      /// Entry type [possible values: d, f, l]
      #[arg(
          short('t'),
          long("type"),
          value_name = "TYPE",
          action(ArgAction::Append),
          num_args(0..)
      )]
      entry_types: Vec<EntryType>,
  }

  #[derive(Debug, Eq, PartialEq, Clone)]
  enum EntryType {
      Dir,
      File,
      Link,
  }

  impl ValueEnum for EntryType {
      fn value_variants<'a>() -> &'a [Self] {
          &[EntryType::Dir, EntryType::File, EntryType::Link]
      }

      fn to_possible_value(&self) -> Option<PossibleValue> {
          Some(match self {
              EntryType::Dir => PossibleValue::new("d"),
              EntryType::File => PossibleValue::new("f"),
              EntryType::Link => PossibleValue::new("l"),
          })
      }
  }

  fn main() {
      if let Err(e) = run(Args::parse()) {
          eprintln!("{e}");
          std::process::exit(1);
      }
  }

  fn run(args: Args) -> Result<()> {
      for path in args.paths {
          for entry in WalkDir::new(path) {
              match entry {
                  Err(e) => eprintln!("{e}"),
                  Ok(entry) => {
                      if (args.entry_types.is_empty()
                          ||  args.entry_types.iter().any(|entry_type| {
                              match entry_type {
                                  EntryType::Link => {
                                      entry.file_type().is_symlink()
                                  }
                                  EntryType::Dir => entry.file_type().is_dir(),
                                  EntryType::File => {
                                      entry.file_type().is_file()
                                  }
                              }
                          }))
                          && (args.names.is_empty()
                              || args.names.iter().any(|re| {
                                  re.is_match(
                                      &entry.file_name().to_string_lossy(),
                                  )
                              }))
                      {
                          println!("{}", entry.path().display());
                      }
                  }
              }
          }
      }
      Ok(())
  }
  ```

- This passes all tests, as long as you `#[ignore]` the author's unreadable
  dir test which causes a race condition when run in parallel. But we want to
  refactor. Specifically, we want a less convoluted way to select the entries
  to display. That big if statement is pretty gnarly looking! And really, these
  are *filter* operations, so we could use `Iterator::filter`.

  ```rs
  fn run(args: Args) -> Result<()> {
      let type_filter = |entry: &DirEntry| {
          args.entry_types.is_empty()
              || args.entry_types.iter().any(|entry_type| match entry_type {
                  EntryType::Link => entry.file_type().is_symlink(),
                  EntryType::Dir => entry.file_type().is_dir(),
                  EntryType::File => entry.file_type().is_file(),
              })
      };

      let name_filter = |entry: &DirEntry| {
          args.names.is_empty()
              || args
                  .names
                  .iter()
                  .any(|re| re.is_match(&entry.file_name().to_string_lossy()))
      };

      for path in &args.paths {
          let entries = WalkDir::new(path)
              .into_iter()
              .filter_map(|e| match e {
                  Err(e) => {
                      eprintln!("{e}");
                      None
                  }
                  Ok(entry) => Some(entry),
              })
              .filter(type_filter)
              .filter(name_filter)
              .map(|entry| entry.path().display().to_string())
              .collect::<Vec<_>>();

          println!("{}", entries.join("\n"));
      }

      Ok(())
  }
  ```

- This version doesn't creep so much to the right and uses filter where it's
  appropriate. We used closures so we can capture values from `args`. We
  use its `entry_types` and `names` with calls to `is_empty` and `any`.
- It's worth pointing out that in our main pipeline for `entries`, we start with
  an iterator over `Result`s from `WalkDir` then use `filter_map` to print out
  errors while converting them to `Option`s. The `filter_map` itself eliminates
  the `None`s and unpacks the `Some(entry)`s. Then we have an iterator of
  `DirEntry` to `filter` twice and `map` (to convert them from `DirEntry` to
  `String`) before collecting it into a `Vec` we can join. Quite a processing
  pipeline! This version is also far easier to add additional `filter` calls to
  in the future if we wanted to handle file size, modification time, ownership,
  etc.
- **Bonus Idiom:** If you ever want to silently discard `Err` values from an
  iterator of `Result`s without logging them, you can write
  `.filter_map(Result::ok)`. The `Result::ok` method turns `Result<T, E>` into
  `Option<T>` (`Ok(val)` $\to$ `Some(val)`, `Err(_)` $\to$ `None`), which
  `filter_map` then automatically filters and unpacks in one clean, zero-cost step!
- You can mark tests `#[cfg(not(windows))]` to only run on non-Windows systems
  and `#[cfg(windows)]` to only run on Windows. The author used conditional
  compilation on `format_file_name` to append `.windows` to the expected output
  filename on Windows systems, since line endings and path outputs differ
  between platforms.

## Chapter 8 - Shave and a Haircut

- Next we'll do a Rust version of `cut`, which can excise text from a file or
  STDIN. The selected text could be some range of bytes or characters or might
  be fields denoted by a delimiter like a comma or tab that creates field
  boundaries. For example, the selection `3, 1, 5-7` should cause the program
  to print the third, first and fifth through seventh bytes, characters, or
  fields, in that order.
- We add a check to make sure `delimiter` is only a single character when we
  are parsing our arguments. It uses a *raw string* so the contained double
  quotes do not require escaping. Rust supports `r#"string"#` for raw strings
  containing quotes and `r"string"` for raw strings containing backslashes and
  no quotes.

  ```rs
  fn run(args: Args) -> Result<()> {
      let delim_bytes = args.delimiter.as_bytes();
      if delim_bytes.len() != 1 {
          bail!(r#"--delim "{}" must be a single byte"#, args.delimiter);
      }
      let delimiter: u8 = *delim_bytes.first().unwrap();
      println!("{delimiter}");
      Ok(())
  }
  ```

- In this code we also use the `Deref::deref` operator `*` in the expression
  `*delim_bytes` to dereference the variable, which is a `&u8`.
- We also define a type alias `PositionList` to describe the fields, bytes, or
  characters that we want to display from the input files. This is a
  `Vec<Range<usize>>` or a vector of `std::ops::Range` structs to represent
  spans of positive integer values. We will put this type in a new enum to
  say which of `Fields`, `Bytes`, or `Chars` we should extract:

  ```rs
  use std::ops::Range;

  type PositionList = Vec<Range<usize>>;

  #[derive(Debug)]
  pub enum Extract {
      Fields(PositionList),
      Bytes(PositionList),
      Chars(PositionList),
  }
  ```

- The `tests` module can have other names. The author uses `unit_tests` so he
  can easily run `cargo test unit` to run all unit tests. But we can accomplish
  the same thing through `cargo test --bin cutr` or `cargo test tests::`.
- The author also chose to provide 20 different assertions in a single unit
  test, but in our code we've split these out into separate tests.
- After writing our unit tests for `parse_pos` we write a `parse_index` function
  that parses a string into a positive index value one less than the given
  number. Notice the closures that take no arguments `||` and close over
  `input`:

  ```rs
  use anyhow::{Result, anyhow, bail};
  use std::num::NonZeroUsize;

  fn parse_index(input: &str) -> Result<usize> {
      let value_error = || anyhow!(r#"illegal list value: "{input}""#);
      input
          .starts_with('+')
          .then(|| Err(value_error()))
          .unwrap_or_else(|| {
              input
                  .parse::<NonZeroUsize>()
                  .map(|n| usize::from(n) - 1)
                  .map_err(|_| value_error())
          })
  }
  ```

- What is `.then(...).unwrap_or_else(...)` doing here?
  - `bool::then(closure)` converts a boolean into an `Option`: if `true`, it
    runs the closure and returns `Some(...)`; if `false`, it returns `None`.
  - So `input.starts_with('+').then(...)` produces `Some(Err(...))` if it starts
    with `+`, or `None` if it does not.
  - `.unwrap_or_else(...)` unwraps that `Option`: if it was `Some(err)`, it
    unpacks and returns the error; if it was `None`, it runs the fallback
    closure to parse `input` as a `NonZeroUsize`.
  - We have to manually check for `+` because Rust's standard numeric parser
    happily accepts leading `+` signs (`"+1"` parses fine), but `cut` explicitly
    treats `+` in range indices as illegal.
  - This whole chain is just a functional expression style for a standard
    `if/else`:

  ```rs
  fn parse_index(input: &str) -> Result<usize> {
      let value_error = || anyhow!(r#"illegal list value: "{input}""#);

      if input.starts_with('+') {
          Err(value_error())
      } else {
          input
              .parse::<NonZeroUsize>()
              .map(|n| usize::from(n) - 1)
              .map_err(|_| value_error())
      }
  }
  ```

- Now that we have parsing a digit solved, we'll write `parse_pos`:

  ```rs
  use regex::Regex;

  fn parse_pos(range: String) -> Result<PositionList> {
      let range_re = Regex::new(r"^(\d+)-(\d+)$").unwrap();
      range
          .split(',')
          .into_iter()
          .map(|val| {
              parse_index(val).map(|n| n..n + 1).or_else(|e| {
                  range_re.captures(val).ok_or(e).and_then(|captures| {
                      let n1 = parse_index(&captures[1])?;
                      let n2 = parse_index(&captures[2])?;
                      if n1 >= n2 {
                          bail!(
                              "First number in range ({}) \
                              must be lower than second number ({})",
                              n1 + 1,
                              n2 + 1
                          );
                      }
                      Ok(n1..n2 + 1)
                  })
              })
          })
          .collect::<Result<_, _>>()
          .map_err(From::from)
  }
  ```

- So we're either parsing a digit and making a range `or_else` capturing two
  digits with a `Regex` `and_then` parsing both and returning a range, or
  returning `Err`.
- The regular expression in `parse_pos` is represented using a raw string to
  prevent Rust from interpreting backslash-escaped values in the string.
  Without this, the compiler complains that `\d` is an unknown character escape.
  Rust supports `r#"string"#` for raw strings containing quotes and `r"string"`
  for raw strings containing backslashes and no quotes.
- Regex based captures are available in one-based counting, so we use
  `&captures[1]` and `&captures[2]`.
- A breakdown of the combinators in `parse_pos`:
  - **`or_else` (Fallback on `Err`)**: `parse_index(val).map(...)` is Plan A
    (a single number like `"3"` $\to$ `2..3`). If that returns `Err(e)`
    (e.g. `"1-5"` isn't a single number), `.or_else(|e| ...)` catches that
    error and runs Plan B.
  - **`ok_or(e)`**: `range_re.captures(val)` returns `Option<Captures>`. If
    the regex also fails to match (e.g. `"foo"`), `.ok_or(e)` converts `None`
    back into the original error `e` (`illegal list value: "foo"`).
  - **`and_then` (Chaining on `Ok`)**: If the regex succeeded (`Ok(captures)`),
    `and_then` passes those captures forward to parse `n1` and `n2`, verify
    `n1 < n2`, and return `Ok(n1..n2 + 1)`.
  - **`map_err(From::from)`**: While the `?` operator automatically converts
    errors using `From::from`, `Iterator::collect` cannot convert error types
    during collection. In earlier versions of the book using `Box<dyn Error>`,
    this was needed to cast the collected error into the function's return type.
    With modern `anyhow::Result`, it's actually a harmless no-op because the
    error is already `anyhow::Error`!
- We also have a pretty dense `run` function that extracts the fields into our
  enum depending on the option:

  ```rs
  fn run(args: Args) -> Result<()> {
      // ...
      let extract = if let Some(fields) =
          args.extract.fields.map(parse_pos).transpose()?
      {
          Extract::Fields(fields)
      } else if let Some(bytes) =
          args.extract.bytes.map(parse_pos).transpose()?
      {
          Extract::Bytes(bytes)
      } else if let Some(chars) =
          args.extract.chars.map(parse_pos).transpose()?
      {
          Extract::Chars(chars)
      } else {
          unreachable!("Must have --fields, --bytes, or --chars");
      };

      println!("{extract:?}");

      Ok(())
  }

  ```

- It's wrapped oddly to make it fit, so it isn't immediately obvious that
  each arm is an `if let Some(var) =` capturing the parsed positions.
- **Note on `transpose()` (and an error in the book):** The author writes in
  the text that this uses `Result::transpose` to turn the `Result` of an
  `Option` into an `Option` of a `Result`. That explanation is completely
  backwards!
  - `args.extract.fields` is an `Option<String>`, not a `Result`.
  - `.map(parse_pos)` calls `Option::map`, producing
    `Option<Result<PositionList, Error>>`.
  - We want to bubble up any parsing error with `?`, but `?` cannot reach a
    `Result` trapped inside an `Option`.
  - Calling `.transpose()` here calls `Option::transpose`, which flips the
    layers inside out into `Result<Option<PositionList>, Error>`.
  - The trailing `?` unwraps that outer `Result` layer (short-circuiting on
    error), leaving a clean `Option<PositionList>`.
  - Finally, `if let Some(fields)` matches on that `Option<PositionList>`,
    initializing `Extract::Fields` with its `PositionList` if present, or
    falling through to the next `else if` if `None`.
- We add the same `open` code we've been using, but we also add a fairly
  complicated nested use statement to our code:

  ```rs
  use std::{
      fs::File,
      io::{self, BufRead, BufReader},
      num::NonZeroUsize,
      ops::Range,
  };
  // ...
  fn open(filename: &str) -> Result<Box<dyn BufRead>> {
      match filename {
          "-" => Ok(Box::new(BufReader::new(io::stdin()))),
          _ => Ok(Box::new(BufReader::new(File::open(filename)?))),
      }
  }
  ```

- The easiest way to parse delimited text properly is to use a proper library,
  so we will use the `csv` crate. It has an excellent tutorial at
  <https://docs.rs/csv/1.3.0/csv/tutorial/index.html>. Here is a simple program
  to show you how `csv` works:

  ```rs
  use csv::{ReaderBuilder, StringRecord};
  use std::fs::File;

  fn main() -> std::io::Result<()> {
      let mut reader = ReaderBuilder::new()
          .delimiter(b',')
          .from_reader(File::open("books.csv")?);

      println!("{}", fmt(reader.headers()?));
      for record in reader.records() {
          println!("{}", fmt(&record?));
      }

      Ok(())
  }

  fn fmt(rec: &StringRecord) -> String {
      rec.into_iter().map(|v| format!("{:20}", v)).collect()
  }
  ```

- So we need ways to extract chars matching our ranges, extract bytes matching
  our ranges, and extract fields matching our ranges. Here's our first draft of
  `extract_chars`:

  ```rs
  fn extract_chars(line: &str, char_pos: &[Range<usize>]) -> String {
      let chars: Vec<_> = line.chars().collect();
      let mut selected: Vec<char> = vec![];

      for range in char_pos.iter().cloned() {
          for i in range {
              if let Some(val) = chars.get(i) {
                  selected.push(*val)
              }
          }
      }
      selected.iter().collect()
  }
  ```

- Several important Rust details are happening in `extract_chars`:
  - **Random access for UTF-8 characters:** Rust strings are UTF-8, where
    characters take between 1 and 4 bytes. Because of variable width, Rust
    forbids direct indexing like `line[i]`. While `line.chars()` provides an
    iterator, iterators are forward-only and cannot jump around or backtrack
    (e.g., if a user requests positions `3, 1`). Collecting into `Vec<char>`
    materializes the characters into contiguous memory for random access via
    `chars.get(i)`.
  - **Why `cloned()` on `char_pos.iter()`:** `char_pos` is `&[Range<usize>]`.
    Calling `.iter()` yields borrowed references (`&Range<usize>`). But in
    Rust, iterating over a range mutates and consumes it, which requires
    ownership. Because `&Range<usize>` cannot be consumed, `for i in range`
    fails. Calling `.cloned()` creates an owned `Range<usize>` (a cheap 16-byte
    copy) so the inner loop can iterate it.
  - **Dereferencing with `*val`:** `chars.get(i)` returns `Option<&char>`, so
    `val` is a borrowed reference (`&char`). However, `selected` is `Vec<char>`,
    which stores owned values. Because `char` implements `Copy` (it is a 4-byte
    Unicode scalar), `*val` dereferences and copies the character so it can be
    pushed into `selected`. (Alternatively, `chars.get(i).copied()` turns
    `Option<&char>` into `Option<char>`).
  - **Collecting characters into a `String`:** `selected.iter().collect()`
    produces a `String` because the standard library implements
    `FromIterator<char>` for `String`.
