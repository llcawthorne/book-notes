# The Rust Programming Language

- Note: I did the Brown University version of *The Rust Programming Language* at
  <https://rust-book.cs.brown.edu>. Passages are quoted or adapted from the
  book, which is licensed under MIT/Apache-2.0.

## Chapter 1 - Getting Started

### 1.2 - Hello, World!

- If you use more than one word in a filename, the convention is to separate
  the words with underscores.
- The `main` function is the first code that runs in every executable Rust
  program. Declare functions with `fn`. Rust requires curly brackets around
  function bodies, and it's good style to place the opening curly bracket on the
  same line as the function declaration with one space in between.
- `println!` is a macro. Macros end in `!`.
- Most lines of Rust code end with a semicolon.

### 1.3 - Hello, Cargo!

- Cargo handles building your code and downloading and building your
  dependencies. `cargo new hello_cargo` will create a `hello_cargo` project.
  It also makes this a Git repository and generates a .gitignore if this isn't
  done within an existing Git repository. It creates *Cargo.toml* and a *src*
  directory with a *main.rs* file inside. The default *Cargo.toml*:

  ```toml
  [package]
  name = "hello_cargo"
  version = "0.1.0"
  edition = "2024"

  [dependencies]
  ```

- In Rust, packages of code are referred to as *crates*. We will add crates to
  dependencies in Chapter 2.
- Cargo expects your source files to live inside the *src* directory. The top
  level project directory is for README files, license information,
  configuration files, and anything else not related to your code.
- If you started your project without Cargo, you can convert it by moving
  project code into the *src* directory and creating a *Cargo.toml* file. One
  easy way to create a *Cargo.toml* file is to run `cargo init`.
- In the `hello_cargo` project, `cargo build` will generate a
  *target/debug/hello_cargo* executable. The default build is a debug build.
  The first time you run `cargo build`, it will create *Cargo.lock* which keeps
  track of exact versions of dependencies in your project. You never need to
  manually edit *Cargo.lock*. `cargo run` will build the project and run the
  resultant executable in one command. `cargo check` makes sure your code
  compiles without generating an executable, and is often much faster. Many
  Rustaceans run `cargo check` periodically as they write their program to make
  sure it compiles then run `cargo build` when they're ready to use the
  executable.
- `cargo build --release` compiles your project with optimization and puts it
  in the *target/release* directory. Be sure to build a release if you are
  benchmarking. Releases are compiled with optimizations to make them run
  faster, but they take longer to compile.

## Chapter 2 - Programming a Guessing Game

- Our first version of the game will allow a player to input a guess and echo it
  back:

  ```rs
  // ch02_guessing_game/src/main.rs
  use std::io;

  fn main() {
      println!("Guess the number!");

      println!("Please input your guess.");

      let mut guess = String::new();

      io::stdin()
          .read_line(&mut guess)
          .expect("Failed to read line");

      println!("You guessed: {guess}");
  }
  ```

- To obtain user input we need `io` from the `std` (standard library). By
  default, Rust has a set of items defined in the standard library that it
  brings into scope for every program called the *prelude*. Any type not in the
  prelude needs to be brought into scope with the `use` statement.
- We use the `let` command to create a variable. In Rust, variables are
  immutable by default. We add `mut` before the variable name to make it
  mutable. `String::new` returns a new instance of a `String`. `String` is a
  string type provided by the standard library that is a growable, UTF-8 encoded
  bit of text. `::` means `new` is an associated function of the `String` type.
  The `new` function creates a new, empty instance of a `String`.
- Because we did `use std::io`, we can call the `stdin` function from the `io`
  module. If we hadn't imported it with `use`, we could still call it using
  `std::io::stdin`. The `stdin` function returns an instance of `std::io::Stdin`
  which represents a handle to the standard input for your terminal. The
  `.read_line(&mut guess)` line calls the `read_line` method on the standard
  input handle to get input from the user. We pass `&mut guess` to it as an
  argument to tell it what string to store the user input in. `read_line` takes
  whatever the user types into standard input and appends it into a string, so
  it always takes a string as an argument. The string argument needs to be
  mutable so that the method can change the string's content. The `&` indicates
  that this argument is a *reference*, which gives you a way to let multiple
  parts of your code access one piece of data without needing to copy that data
  into memory multiple times. Like variables, references are immutable by
  default. Therefore we write `&mut guess` instead of `&guess` to make it
  mutable.
- It is often useful to break up long lines when you call a method with the
  `.method_name()` syntax. Now `.expect("Failed to read line")` is called on the
  `Result` value returned by `.read_line`. `Result` is an *enumeration*, often
  called an *enum*, which is a type that can be in one of multiple possible
  states. We call each possible state a *variant*. `Result`'s variants are `Ok`
  and `Err` and it is meant to encode error-handling information. The `Ok`
  variant indicates the operation was successful, and it contains the
  successfully generated value. The `Err` variant means the operation failed,
  and it contains information about how or why the operation failed. Values of
  the `Result` type, like values of any type, have methods defined on them. An
  instance of `Result` has an `expect` method that you can call. If the `Result`
  is an `Err` value, `expect` will cause the program to crash and display the
  message that you passed as an argument to `expect`. So if `read_line`
  returns an `Err`, it would likely be the result of an error coming from the
  underlying operating system. If this instance of `Result` is an `Ok` value,
  `expect` will take the return value that `Ok` is holding and return just that
  value to you so that you can use it. In this case, that value is the number of
  bytes in the user's input. If you don't call `expect`, the program will
  compile but you will get a warning:
  ``warning: unused `Result` that must be used``. The right way to suppress the
  warning is to actually write error handling code, but in our case we just
  want to crash if there is a problem so we use `expect`. We'll learn how to
  recover from errors in Chapter 9.
- `println!("You guessed: {guess}");` prints the string that now contains the
  user's input. The `{}` set of curly brackets is a placeholder. When printing
  the value of a variable, the variable name can go inside the curly brackets.
  When printing the result of evaluating an expression, place empty curly
  brackets in the format string, then follow the format string with a comma
  separated list of expressions to print in each empty curly bracket
  placeholder.

  ```rs
  // printing a variable and the result of an expression in one call
  let x = 5;
  let y = 10;

  println!("x = {x} and y + 2 = {}", y + 2); // x = 5 and y + 2 = 12
  ```

- Next we'll include a secret number for the user to guess. We are going to
  generate one between 1 and 100. There is no random number functionality in the
  standard library, but the Rust team provides a `rand` crate. The code we have
  been working on is a binary crate, which is an executable. `rand` is a library
  crate, which contains code that is intended to be used in other programs and
  cannot be executed on its own. Add `rand` to your Cargo.toml dependencies:

  ```toml
  [dependencies]
  rand = "0.8.5"
  ```

- "0.8.5" means any version at least 0.8.5 and below 0.9.0 in SemVer.
  When we include an external dependency, Cargo fetches the latest version of
  everything that dependency needs from the *registry*, which is a copy of data
  from <https://crates.io/>. You can watch the dependencies build by running
  `cargo build` now that you've updated *Cargo.toml*. Now that we have run
  `cargo build`, we have a *Cargo.lock* file that specifies which versions to
  use to build our project. *Cargo.lock* is often checked into source control
  and is important for reproducible builds. `cargo update` will figure out the
  latest versions from your specifications in *Cargo.toml* and update
  *Cargo.lock*.

  ```rs
  // ch02_guessing_game/src/main.rs
  use std::io;
  use rand::Rng;

  fn main() {
      println!("Guess the number!");
      let secret_number = rand::thread_rng().gen_range(1..=100);
      println!("The secret number is: {secret_number}");
      // --snip--
  }
  ```

- We start with `use rand::Rng`. The `Rng` trait defines methods that random
  number generators implement and needs to be in scope to use those methods.
  The `rand::thread_rng` function gives us a generator local to the current
  thread of execution and seeded by the operating system. We call the
  `.gen_range` method and give it a range expression as an argument for it to
  generate a number in the range. `gen_range` is defined by the `Rng` trait that
  we brought into scope. The kind of range expression we are using takes the
  form of `start..=end` and is inclusive on the lower and upper bounds.
- You don't need to know everything in every crate. Since we have declared
  dependencies, `cargo doc --open` will generate documentation for our code and
  dependencies and open it in the browser.
- Note the following code will not compile:

  ```rs
  // ch02_guessing_game/src/main.rs
  // DOES NOT COMPILE! error[E0308]: mismatched types
  use std::cmp::Ordering;
  use std::io;

  use rand::Rng;

  fn main() {
      // --snip--
      println!("You guessed: {guess}");

      match guess.cmp(&secret_number) {
          Ordering::Less => println!("Too small!"),
          Ordering::Greater => println!("Too big!"),
          Ordering::Equal => println!("You win!"),
      }
  }
  ```

- Above we `use std::cmp::Ordering` to bring it into scope. The `Ordering` type
  is another enum and has the variants `Less`, `Greater`, and `Equal`, the three
  outcomes possible when you compare two values. The `cmp` method compares two
  values and can be called on anything that can be compared. It takes a
  reference to whatever you want to compare with. Here we compare `guess` to
  `secret_number`. It returns a variant of `Ordering` and we use a `match`
  expression to decide what to do next based on which variant of `Ordering` was
  returned from the call. A `match` expression is made of *arms*. An arm
  consists of a *pattern* to match against, and the code that should be run if
  the value given to `match` fits that arm's pattern. Rust takes the value given
  to `match` and looks through each arm's pattern in turn. Patterns and `match`
  let you express a variety of situations your code might encounter and how to
  handle them all. The `match` expression ends after the first successful match.
- Rust is statically typed but you don't always need to provide types because it
  can infer them. Here we are using an `i32` where it expects a `String`.
  `guess` is a `String`, which Rust inferred. The `secret_number` is a random
  number, so an integer, more specifically an `i32` because Rust will default
  to that unless it is otherwise specified. Rust cannot compare a string and a
  number type. So we should convert the `String` to a number type.

  ```rs
  // ch02_guessing_game/src/main.rs
  use std::cmp::Ordering;
  use std::io;

  use rand::Rng;

  fn main() {
      // --snip--
      let mut guess = String::new();

      io::stdin()
          .read_line(&mut guess)
          .expect("Failed to read line");

      let guess: u32 = guess.trim().parse().expect("Please type a number!");
      println!("You guessed: {guess}");

      match guess.cmp(&secret_number) {
          Ordering::Less => println!("Too small!"),
          Ordering::Greater => println!("Too big!"),
          Ordering::Equal => println!("You win!"),
      }
  }
  ```

- Rust allows us to declare a new `guess` variable which *shadows* the existing
  `guess` variable. We often shadow the old variable when we want to convert a
  value from one type to another type. We bind the new variable to the
  expression `guess.trim().parse()`. The `guess` in the expression is the
  original string. `trim` removes any whitespace at the beginning and end, which
  we must do before converting it to a `u32`, which can only contain numerical
  data. The user must press `enter` to satisfy `read_line`, so `guess` contains
  a trailing newline character. The `parse` method on strings converts a string
  to another type. It can tell from the fact we are assigning it to a `u32` what
  to convert to. Additionally, since Rust can tell this is a `u32` it will make
  the `secret_number` a `u32` as well so we can compare them. The `parse` method
  only works on characters that can logically be converted into numbers so can
  easily cause errors. Because it might fail, it returns a `Result` type. If
  `parse` can successfully convert the string to a number, it will return the
  `Ok` variant of `Result`, and `expect` will return the number that we want
  from the `Ok` value.
- Now we want to allow multiple guesses with `loop`:

  ```rs
  use std::cmp::Ordering;
  use std::io;

  use rand::Rng;

  fn main() {
      println!("Guess the number!");

      let secret_number = rand::thread_rng().gen_range(1..=100);
      println!("The secret number is: {secret_number}");

      loop {
          println!("Please input your guess.");
          // --snip--
          match guess.cmp(&secret_number) {
              Ordering::Less => println!("Too small!"),
              Ordering::Greater => println!("Too big!"),
              Ordering::Equal => println!("You win!"),
          }
      }
  }
  ```

- As you can see, we moved everything from the guess input prompt onward into a
  loop. We didn't even have to indent by hand thanks to `rustfmt`. There is only
  one problem, the `loop` asks for another guess forever and there's no way to
  quit other than ctrl-C or entering a non-number answer to crash. Adding a
  `break` after they win will fix that:

  ```rs
  // ch02_guessing_game/src/main.rs
  // --snip--
          match guess.cmp(&secret_number) {
              Ordering::Less => println!("Too small!"),
              Ordering::Greater => println!("Too big!"),
              Ordering::Equal => {
                  println!("You win!");
                  break;
              }
          }
      }
  }
  ```

- We also want to handle invalid input better than a crash. `continue`
  conveniently lets you start over the loop, so we'll ignore invalid input and
  do that to take another guess.

  ```rs
  // ch02_guessing_game/src/main.rs
  // --snip--
          io::stdin()
              .read_line(&mut guess)
              .expect("Failed to read line");
          let guess: u32 = match guess.trim().parse() {
              Ok(num) => num,
              Err(_) => continue,
          };
          println!("You guessed: {guess}");
  // --snip--
  ```

- We switch from an `expect` which crashes the program to a `match` on the
  `Result`. `parse` returns the `Result` and `Result` is an enum that has
  variants of `Ok` and `Err`. The `Ok` contains a `num` that is the parse
  result. Otherwise, it returns an `Err` and we ignore the error message and
  `continue`. `_` is a catch-all value; in this example we are saying match all
  `Err` values, no matter what information they have inside them.
- We'll also delete the `println!` that displays the secret number, since that
  was just for testing. And here is our final code:

  ```rs
  // ch02_guessing_game/src/main.rs
  use std::cmp::Ordering;
  use std::io;

  use rand::Rng;

  fn main() {
      println!("Guess the number!");
      let secret_number = rand::thread_rng().gen_range(1..=100);

      loop {
          println!("Please input your guess.");
          let mut guess = String::new();
          io::stdin()
              .read_line(&mut guess)
              .expect("Failed to read line");
          let guess: u32 = match guess.trim().parse() {
              Ok(num) => num,
              Err(_) => continue,
          };
          println!("You guessed: {guess}");

          match guess.cmp(&secret_number) {
              Ordering::Less => println!("Too small!"),
              Ordering::Greater => println!("Too big!"),
              Ordering::Equal => {
                  println!("You win!");
                  break;
              }
          }
      }
  }
  ```

## Chapter 3 - Common Programming Concepts

### 3.1 - Variables and Mutability

- Variables are immutable by default. When a variable is immutable, once a value
  is bound to a name you cannot change that value. If you try to assign twice to
  an immutable variable `x`, you will get an
  ``error[E0384]: cannot assign twice to immutable variable `x` ``. You can
  declare them mutable by adding `mut` in front of the variable name when
  defining them with `let`. Note that you can reassign a mutable variable, but
  its type needs to remain the same or you will get an
  `error[E0308]: mismatched types` error.
- You can declare a constant with `const` instead of `let`. You cannot use `mut`
  with a `const`; they are always immutable. The type of the value must be
  annotated. Constants can be declared in any scope, including global scope.
  Also, they must be set to a constant expression and not the result of a value
  that could only be computed at runtime. Rust's naming convention for
  constants is to use all capitals with underscores separating words.
  `const THREE_HOURS_IN_SECONDS: u32 = 60 * 60 * 3;` You see that Rust can
  evaluate a limited set of operations at compile time, so we can easily
  compute the number of seconds in 3 hours. They are valid for the entire time
  the program runs so can be useful for values multiple parts of the program
  might need to know about.
- When you declare a new variable with the same name as a previous variable, we
  say the original variable is shadowed by the new one. The original variable is
  inaccessible until the new variable's scope ends. Since we're creating a new
  variable, we can re-use the name with a different type when we shadow a
  variable. You can also shadow an immutable variable.

### 3.2 - Data Types

- Every value in Rust is of a certain *data type*. We'll look at scalar and
  compound types. Rust is *statically typed*, which means that it must know the
  types of all variables at compile time. The compiler can usually infer what
  type we want to use based on the value and how we use it. In cases when many
  types are possible, we must add a type annotation like:
  `let guess: u32 = "42".parse().expect("Not a number!");`. Without the `u32`
  that would cause an `error[E0284]: type annotations needed`.
- A *scalar* type represents a single value. Rust has four primary scalar types:
  integers, floating-point numbers, Booleans, and characters. `u32` indicates an
  unsigned integer (signed integer types start with `i` instead of `u`) that
  takes up 32 bits of space. The `32` could be `8`, `16`, `32`, `64`, or `128`.
  There is also an architecture dependent `isize` and `usize`. These are 64 bits
  on 64-bit architectures and 32 bits on 32-bit architectures. Signed integers
  can store numbers from -(2^(n-1)) to 2^(n-1) - 1 inclusive where *n* is the
  number of bits. Unsigned integers can store numbers from 0 to 2^n - 1. So an
  `i8` holds from -128 to 127, and a `u8` holds 0 to 255.
- Numeric literals can use a `_` as a visual separator. You can also declare
  them a particular type with a type suffix, such as `57u8`. `98_222` is a
  decimal value. `0xff` is hex. `0o77` is octal. `0b1111_0000` is binary. And
  `b'A'` is a byte (`u8` only). Integer types default to `i32`. The primary time
  you would use `isize` or `usize` is as an index to some sort of collection.
  Rust panics in debug mode when you overflow an integer and it performs *two's
  complement wrapping* in release mode. There are four families of methods to
  specifically handle overflow:
  - Wrap in all modes with the `wrapping_*` methods, such as `wrapping_add`.
  - Return the `None` value if there is overflow with the `checked_*` methods.
  - Return the value and a Boolean indicating overflow with the `overflowing_*`
    methods.
  - Saturate at the value's min or max values with the `saturating_*` methods.
- Rust has two primitive types for *floating-point numbers*, `f32` and `f64`.
  The default is `f64` since it is roughly the same speed on modern hardware
  while capable of more precision. All floating-point types are signed.
- Rust supports the basic mathematical operations you'd expect for all the
  number types: addition, subtraction, multiplication, division, and remainder.
  Integer division truncates toward zero to the nearest integer.
- Booleans are one byte and can be `true` or `false`. Their type is written
  `bool`. The main way to use them is in conditionals.
- Rust's `char` type is the language's most primitive alphabetic type. A literal
  in single quotes is a `char` and one in double quotes is a string slice
  (`&str`), not a `String`. Rust's
  `char` type is 4 bytes and represents a Unicode scalar value ranging from
  `U+0000` to `U+D7FF` and `U+E000` to `U+10FFFF` inclusive.
- *Compound types* can group multiple values into one type. Rust has two
  primitive compound types: tuples and arrays.
- A *tuple* is a general way of grouping together a number of values with a
  variety of types into one compound type. Tuples have a fixed length and cannot
  grow or shrink in size once declared. You declare one with a comma-separated
  list of values inside parentheses. Each position has a type, and types of
  different values don't need to be the same.

  ```rs
  fn main() {
      let tup: (i32, f64, u8) = (500, 6.4, 1);  // the types are unnecessary
      let (x, y, z) = tup;
      println!("The value of y is: {y}");
  }
  ```

- Above we are *destructuring* the tuple `tup` into three separate variables.
  You can also access a value by using a period followed by the index of the
  value we want to access, so `tup.1` for `6.4` above. The first index is 0.
  A tuple with no values is called *unit* and written `()`, representing an
  empty value or an empty return type. Expressions implicitly return the unit
  value if they don't return any other value. You can modify elements of a
  mutable tuple like `tup.1 = 6.5`.
- The *array* is a fixed length collection of multiple values that must have the
  same type. We write the values in an array as a comma-separated list inside
  square brackets:

  ```rs
  fn main() {
      let a = [1, 2, 3, 4, 5];
  }
  ```

- Arrays are useful when you want your data allocated on the stack instead of
  the heap or when you want to ensure a fixed number of elements, but an array
  isn't as flexible as a vector type which can grow or shrink in size because
  its contents live on the heap. If you're unsure whether to use an array or
  vector, you probably need a vector. If you know you always need twelve months,
  an array is a good candidate. You write an array's type using square brackets
  with the type of each element, a semicolon, and then the number of elements in
  the array like `let a: [i32; 5] = [1, 2, 3, 4, 5];`. You can also initialize
  an array to contain the same value by specifying the initial value, a
  semicolon, then the length of the array like `let a = [3; 5];` instead of
  `let a = [3, 3, 3, 3, 3];`. You access array values with indexing like
  `a[1]`. Array indices start at 0. Attempting to access past the end of the
  array will cause a runtime error (a panic).

### 3.3 - Functions

- The `fn` keyword allows you to declare functions. Rust code uses *snake case*
  for function and variable names. Rust doesn't care where you define your
  functions, only that they are defined somewhere in a scope that can be seen
  by the caller.
- We can define functions to have *parameters*. The values you provide it are
  called *arguments*. In function signatures you must declare the type of each
  parameter. This is a deliberate decision for the language, and in practice
  the compiler almost never needs type annotations elsewhere because they are
  in the function definitions. It can also give more helpful error messages. You
  separate multiple parameters by commas:

  ```rs
  fn main() {
      print_labeled_measurement(5, 'h');
  }

  fn print_labeled_measurement(value: i32, unit_label: char) {
      println!("The measurement is: {value}{unit_label}");
  }
  ```

- Function bodies are made up of a series of statements optionally ending in an
  expression. *Statements* are instructions that perform some action and do not
  return a value. *Expressions* evaluate to a resultant value. A `let` or
  function declaration with `fn` is a statement. Therefore, you can't assign
  either to another variable. `let x = (let y = 6);` will cause an
  ``error: expected expression, found `let` statement``. This is different from
  C and Ruby where assignment returns the value of the assignment. Expressions
  evaluate to a value and make up most of the rest of the code that you'll
  write in Rust. `5 + 6` is an expression that evaluates to `11`. Expressions
  can be part of statements, like the `6` in `let x = 6`. Function calls are
  also expressions, as are macro calls. A new scope block created with curly
  brackets is an expression.

  ```rs
  fn main() {
      let y = {
          let x = 3;
          x + 1
      };
      println!("The value of y is: {y}");  // The value of y is: 4
  }
  ```

- The `x + 1` at the end doesn't have a semicolon because expressions do not
  include ending semicolons. If you add one, it turns it into a statement, and
  it will then not return a value.
- Functions can return values. We do not name return values, but we must declare
  their type after an arrow (`->`). In Rust, the return value of a function is
  synonymous with the value of the final expression in the block of the body of
  a function. You can return early by using the `return` keyword and specifying
  a value, but most functions return the last expression implicitly.

  ```rs
  fn main() {
      let x = plus_one(5);
      println!("The value of x is: {x}");
  }

  fn plus_one(x: i32) -> i32 {
      x + 1
  }
  ```

- If you had put a semicolon after `x + 1`, you would have gotten an
  `error[E0308]: mismatched types` error, because `()` isn't an `i32`, and
  statements evaluate to `()`.

### 3.4 - Comments

- Comments start with `//` and continue to the end of the line, or you can use
  the multiline comment syntax with `/*` and `*/`. Comments can be placed at the
  end of lines of code, but you'll most commonly see them on the line above code
  they are annotating. Rust also has documentation comments which we will
  discuss in Chapter 14.

### 3.5 - Control Flow

- An `if` expression allows you to branch your code depending on conditions.
  Blocks of code associated with the conditions in `if` expressions are
  sometimes called *arms*, just like the arms in `match` expressions. The
  condition must be a `bool` or you will get an
  `error[E0308]: mismatched types`. The `else` clause is optional. You can use
  multiple conditions by combining `if` and `else` in an `else if` expression.
  Rust only executes the block for the first `true` condition it finds and
  doesn't check the rest. Using too many `else if` expressions can clutter your
  code, so prefer `match`.

  ```rs
  fn main() {
      let number = 7;

      if number > 5 {
          println!("condition was true");
      } else if number == 0 {
          println!("number is zero");
      } else {
          println!("condition was false");
      } // condition was true
  }
  ```

- Because `if` is an expression, you can use it in a `let` statement like:

  ```rs
  fn main() {
      let condition = true;
      let number = if condition { 5 } else { 6 };

      println!("The value of number is: {number}"); // The value of number is: 5
  }
  ```

- The values that have the potential to be results from each arm of the `if`
  must be the same type or you will get an
  ``error[E0308]: `if` and `else` have incompatible types`` error.
- Rust has three kinds of loops: `loop`, `while`, and `for`. The `loop` keyword
  tells Rust to execute a block of code over and over either forever or until
  you explicitly tell it to stop. A `break` keyword says to stop executing the
  loop, and a `continue` keyword skips over the remaining code in this iteration
  and starts the next iteration. You can provide a value to break to use as the
  return value of the loop.

  ```rs
  fn main() {
      let mut counter = 0;
      let result = loop {
          counter += 1;
          if counter == 10 {
              break counter * 2;
          }
      };
      println!("The result is {result}"); // The result is 20
  }
  ```

- Notice above how you end the `let` that assigns the value returned from the
  loop to `result` with a semicolon, because it's a statement. You can also
  `return` from a loop, but `break` exits the current loop while `return` always
  exits the current function.
- If you have loops within loops, `break` and `continue` apply to the innermost
  loop at that point. You can optionally specify a *loop label*. Loop labels
  begin with a single quote:

  ```rs
  fn main() {
      let mut count = 0;
      'counting_up: loop {
          println!("count = {count}");
          let mut remaining = 10;
          loop {
              println!("remaining = {remaining}");
              if remaining == 9 {
                  break;
              }
              if count == 2 {
                  break 'counting_up;
              }
              remaining -= 1;
          }
          count += 1;
      }
      println!("End count = {count}"); // End count = 2
  }
  ```

- The `while` loop simply loops while a condition is `true`. It is more
  convenient than combining `loop`, `if`, `else`, and `break` to do the same
  thing.

  ```rs
  fn main() {
      let mut number = 3;
      while number != 0 {
          println!("{number}!");
          number -= 1;
      }
      println!("LIFTOFF!!!");
  }
  ```

- A `for` loop executes some code for each item in a collection. The safety and
  conciseness of `for` loops makes them the most commonly used loop construct in
  Rust. Even if you want to count 3, 2, 1 like above, a Rustacean would often
  use `for` with a Range.

  ```rs
  fn main() {
      let a = [10, 20, 30, 40, 50];
      for element in a {
          println!("the value is: {element}");
      }
  }

  fn main() {
      for number in (1..4).rev() {
          println!("{number}!");
      }
      println!("LIFTOFF!!!");
  }
  ```

## Chapter 4 - Understanding Ownership

- Here is a link to this chapter if you want to re-read it with diagrams:
  <https://rust-book.cs.brown.edu/ch04-00-understanding-ownership.html>.

### 4.1 - What is Ownership?

- Ownership is what enables Rust to make memory safety guarantees without
  needing a garbage collector. Ownership is a discipline for ensuring the
  **safety** of Rust programs. Safety is the absence of undefined behavior.
  In a dynamic language, the interpreter must check every time you use a
  variable to make sure it is defined and otherwise throw a `NameError` or
  `ReferenceError`. Rust's goal is to compile programs into efficient binaries
  that require as few runtime checks as possible. Therefore Rust does not check
  at runtime whether a variable is defined before being used. Instead, Rust
  checks at compile-time. If you try to compile a program that uses a variable
  before it is defined, you will receive an
  ``error[E0425]: cannot find value `x` in this scope``. Here is a program
  with undefined behavior that gives that error on compilation:

  ```rs
  // DOES NOT COMPILE! error[E0425]: cannot find value `x` in this scope
  fn read(y: bool) {
      if y {
          println!("y is true!");
      }
  }

  fn main() {
      read(x); // oh no! x isn't defined!
      let x = true;
  }

  // here it is in assembly
  // you don't know assembly, but read operates on the value on edi, and we
  // do not know what is there initially. so read's behavior is undefined!
  main:
      ; ...
      call    read
      mov     edi, 1     ; mov is after call
      ; ...
  ```

- A foundational goal of Rust is to ensure that your programs never have
  undefined behavior. That is the meaning of "safety." About 70% of reported
  security vulnerabilities in low-level systems are caused by memory corruption,
  which is one form of undefined behavior. A secondary goal of Rust is to
  prevent undefined behavior at compile-time instead of run-time. This goal has
  two motivations:
  1. Catching bugs at compile-time means avoiding those bugs in production,
     improving the reliability of your software.
  2. Catching bugs at compile-time means fewer runtime checks for those bugs,
     improving the performance of your software.
- Rust provides a particular way to think about memory. Ownership is a
  discipline for safely using memory within that way of thinking.
- Variables live in the stack.

  ```rs
  fn main() {
      let n = 5; // L1
      let y = plus_one(n); // L3
      println!("The value of y is: {y}");
  }

  fn plus_one(x: i32) -> i32 {
      // L2
      x + 1
  }

  L1                L2                L3
  Stack             Stack             Stack
  main              main              main
    n | 5             n | 5             n | 5
                    plus_one            y | 6
                      x | 5
  ```

- Variables live in **frames**. A frame is a mapping from variables to values
  within a single scope, such as a function. For example:
  - The frame for `main` at location `L1` holds `n = 5`.
  - The frame for `plus_one` at location `L2` holds `x = 5`.
  - The frame for `main` at location `L3` holds `n = 5; y = 6`.
- Frames are organized into a **stack** of currently-called-functions. For
  example, at `L2` the frame for `main` sits above the frame for the called
  function `plus_one`. After a function returns, Rust deallocates the function's
  frame. (Deallocation is called **freeing** or **dropping**). The sequence of
  frames is called a stack because the most recent frame added is always the
  next frame freed. Note that this doesn't fully capture what happens. As we
  saw in assembly, Rust might put `n` or `x` into a register rather than a
  stack frame. But this is an implementation detail that doesn't matter for
  our discussion, so we can focus on frame-only variables.
- When an expression reads a variable, the variable's value is copied from its
  slot in the stack frame:

  ```rs
  let a = 5; // L1
  let mut b = a; // L2
  b += 1; // L3

  L1                L2                L3
  Stack             Stack             Stack
  main              main              main
    a | 5             a | 5             a | 5
                      b | 5             b | 6
  ```

- Boxes live in the heap. If we copied a one million element array from `a` to
  `b`, we would end up with two million elements in memory. To transfer data
  without copying it, Rust uses **pointers**. A pointer is a value that
  describes a location in memory. The value that a pointer points to is called
  its **pointee**. One common way to make a pointer is to allocate memory in the
  **heap**. The heap is a separate region of memory where data can live
  indefinitely. Heap data is not tied to a specific stack frame. Rust provides
  a construction called `Box` for putting data on the heap.

  ```rs
  let a = Box::new([0; 1_000_000]); // L1
  let b = a; // L2

  // moving a to b transfers ownership; a is grayed out and can't be used
  L1                               L2
  Stack        Heap                Stack        Heap
  main                             main
    a | *----> [0, 0, ..., 0]        a | x moved
                                     b | *----> [0, 0, ..., 0]
  ```

- Observe that now, there is only ever a single array at a time. At `L1`, the
  value of `a` is a pointer to the array inside the heap. The statement
  `let b = a` copies the pointer from `a` to `b`, but the pointed-to data is
  not copied. Note that `a` is grayed out because it has been *moved*.
- Rust does not permit manual memory management. Rust automatically allocates
  and deallocates stack frames. Heap data is allocated when calling `Box::new`.
  There is no `free` command in Rust. Rust automatically frees a box's heap
  memory. It is almost correct to say "If a variable is bound to a box, when
  Rust deallocates the variable's frame, then Rust deallocates the box's heap
  memory."

  ```rs
  fn main() {
      let a_num = 4; // L1
      make_and_drop(); // L3
  }

  fn make_and_drop() {
      let a_box = Box::new(5); // L2
  }

  L1                L2                             L3
  Stack             Stack          Heap          Stack
  main              main                           main
    a_num | 4         a_num | 4                      a_num | 4
                    make_and_drop
                      a_box | *----> 5
  ```

- Now we get back to the idea of *moving*. If we bound an array of a million
  elements to both `a` and `b`, Rust would try to free it when each went out of
  scope. But freeing freed memory is undefined behavior! Enter *ownership*!
  When `a` is bound to `Box::new([0; 1_000_000])`, we say that `a` **owns** the
  box. The statement `let b = a` **moves** ownership of the box from `a` to `b`.
- **Box deallocation principle** (fully correct): If a variable owns a box,
  when Rust deallocates the variable's frame, then Rust deallocates the box's
  heap memory.
- Boxes are used by Rust data structures like `Vec`, `String`, and `HashMap` to
  hold a variable number of elements.

  ```rs
  fn main() {
      let first = String::from("Ferris"); // L1
      let full = add_suffix(first); // L4
      println!("{full}");
  }

  fn add_suffix(mut name: String) -> String {
      // L2
      name.push_str(" Jr."); // L3
      name
  }

  L1                                  L2
  Stack           Heap                Stack           Heap
  main                                main
    first | *---> "Ferris"              first | x moved
                                      add_suffix
                                        name  | *---> "Ferris"

  L3                                  L4
  Stack           Heap                Stack           Heap
  main                                main
    first | x moved                     first | x moved
  add_suffix                            full  | *---> "Ferris Jr."
    name  | *---> "Ferris Jr."
  ```

- There are several points to make about this example.
  - At `L1`, the string "Ferris" has been allocated on the heap. It is owned by
    `first`.
  - Ownership only moves forwards, from `first` to `name` then to `full`.
  - `L2`: calling `add_suffix(first)` moves the `String` into `name`. Only the
    pointer is copied. The heap data stays where it is.
  - `L3`: the method call `name.push_str(" Jr.")` resizes the string's heap
    allocation. This does three things. First, it creates a new larger
    allocation. Second, it writes "Ferris Jr." into the new allocation. Third,
    it frees the original heap memory. `first` now points to deallocated memory.
    Since `name` owns the string, it can change it with `push_str`. The
    function signature has to say `mut name` for that to be allowed.
  - `L4`: the frame for `add_suffix` is gone. This function returned `name`,
    transferring ownership of the string to `full`. The heap string isn't freed,
    because it now has a new owner.
- A variable cannot be used after being moved. There is no problem with `first`
  pointing at deallocated memory, as long as we don't try to use `first` after
  it has become invalid.

  ```rs
  // DOES NOT COMPILE! error[E0382]: borrow of moved value: `first`
  fn main() {
      let first = String::from("Ferris");
      let full = add_suffix(first);
      println!("{full}, originally {first}"); // L1
  }

  fn add_suffix(mut name: String) -> String {
      name.push_str(" Jr.");
      name
  }

  L1
  Stack           Heap
  main
    first | *---> [freed]
    full  | *---> "Ferris Jr."
  ```

- **Moved heap data principle**: if a variable `x` moves ownership of heap data
  to another variable `y`, then `x` cannot be used after the move.
- Moving ownership of heap data avoids undefined behavior from reading
  deallocated memory.
- You can use `.clone()` to make a deep copy of the heap data, then move the
  clone instead of the original, so the original stays usable. The obvious
  drawback is that you have two copies in memory.
- Ownership is primarily a discipline of heap management.
  - All heap data must be owned by exactly one variable.
  - Rust deallocates heap data once its owner goes out of scope.
  - Ownership can be transferred by moves, which happen on assignments and
    function calls.
  - Heap data can only be accessed through its current owner, not a previous
    owner.

### 4.2 - References and Borrowing

- Ownership, boxes, and moves provide a foundation for safely programming with
  the heap. However, move-only APIs can be inconvenient to use.

  ```rs
  // DOES NOT COMPILE! error[E0382]: borrow of moved value: `m1` (and `m2`)
  fn main() {
      let m1 = String::from("Hello");
      let m2 = String::from("world");
      greet(m1, m2); // L2
      let s = format!("{} {}", m1, m2); // L3
  }

  fn greet(g1: String, g2: String) {
      println!("{} {}!", g1, g2); // L1
  }

  L1                  L2                    L3
  Stack        Heap   Stack        Heap     Stack        Heap
  main                main                  main
    m1 | x moved        m1 | *---> [freed]    m1 | *---> [freed] <-- UB
    m2 | x moved        m2 | *---> [freed]    m2 | *---> [freed] <-- UB
  greet
    g1 | *---> Hello
    g2 | *---> world

  UB means Undefined Behavior, which would happen here because a pointer would
  be used after its pointee is freed.
  ```

- A **reference** is a kind of pointer.

  ```rs
  fn main() {
      let m1 = String::from("Hello");
      let m2 = String::from("world"); // L1
      greet(&m1, &m2); // L3 - note the ampersands
      let s = format!("{} {}", m1, m2);
  }

  fn greet(g1: &String, g2: &String) { // note the ampersands
      // L2
      println!("{} {}!", g1, g2);
  }

  L1                        L2
  Stack        Heap         Stack        Heap
  main                      main
    m1 | *---> "Hello"        m1 | *---> "Hello"
    m2 | *---> "world"        m2 | *---> "world"
                            greet
                              g1 | *-> m1
                              g2 | *-> m2

  L3
  Stack        Heap
  main
    m1 | *---> "Hello"
    m2 | *---> "world"
  ```

- The expression `&m1` uses the ampersand operator to create a reference to
  (or "borrow") `m1`. The type of the `greet` parameter `g1` is changed to
  `&String`, meaning "a reference to a `String`". Observe at `L2` that there
  are two steps from `g1` to "Hello". `g1` is a reference that points to `m1`
  on the stack, and `m1` is a String containing a box that points to "Hello"
  on the heap. `m1` continues to own the heap data "Hello". `g1` does not own
  either `m1` or "Hello". Therefore after `greet` ends and the program reaches
  `L3`, no heap data has been deallocated. Only the stack frame for `greet`
  disappears. References are **non-owning pointers**, because they do not own
  the data they point to.
- There is a dereference operator in Rust (`*`), but you probably won't see it
  very often. Rust implicitly inserts dereferences and references in certain
  cases, such as calling a method with the dot operator or calling `println!`.
  Arithmetic like `r + 1` also works on references to numbers. You do need `*`
  to assign through a reference (`*n += 1`), or to use the value itself in a
  comparison (`if *r > 3`) or a typed assignment (`let y: i32 = *r;`), but the
  compiler will suggest it if you forget.
- The macro `vec!` creates a vector with the elements between the brackets when
  you write `let mut v: Vec<i32> = vec![1, 2, 3];`.
- Pointer Safety Principle: data should never be aliased and mutated at the
  same time.
- Rust enforces the principle for boxes by disallowing aliasing. Assigning a
  box from one variable to another will move ownership, invalidating the
  previous variable. Owned data can only be accessed through the owner - no
  aliases. By design, references are meant to temporarily create aliases.
  We will explain the basics of how Rust ensures the safety of references
  through the **borrow checker**.
- The core idea behind the borrow checker is that variables have three kinds
  of **permissions** on their data:
  - Read (R): data can be copied to another location.
  - Write (W): data can be mutated.
  - Own (O): data can be moved or dropped.
- These permissions don't exist at runtime, only within the compiler. They
  describe how the compiler "thinks" about your program before the program is
  executed. By default, a variable has read/own permissions (RO) on its data.
  If a variable is annotated with `mut`, then it also has write permission (W).
  The key idea is that references can temporarily remove these permissions.
- Permission diagram legend (Brown's symbol = my notation):
  - `↑` = `[init]`: gained permissions on initialization.
  - `→` = `[borrow]`: lost permissions because it was borrowed.
  - `↺` = `[regain]`: permissions returned when a borrow ends.
  - `↓` = `[end]`: lost permissions because it isn't used again.
  - Inline dots on an expression = `[needs]`: permissions the line requires.
  - `+R` gained, `R` kept, `-R` lost (Brown strikes through), `.` never had
    (Brown's dash).
  - `<- ERROR` marks a `[needs]` the place doesn't have.
  - `F` (flow, §4.2) is a fourth column after O. It doesn't change within a
    function, so it only appears in `[needs]` rows.

  ```rs
  let mut v: Vec<i32> = vec![1, 2, 3];    // v    [init]    +R +W +O
  let num: &i32 = &v[2];                  // v    [borrow]   R -W -O
                                          // num  [init]    +R  . +O
                                          // *num [init]    +R  .  .
  println!("Third element is {}", *num);  // v    [regain]   R +W +O
                                          // num  [end]     -R  . -O
                                          // *num [end]     -R  .  .
  v.push(4);                              // v    [end]     -R -W -O
  ```

- In plain English:
  1. After `let mut v = (...)`, the variable `v` has been initialized
     (indicated by [init]). It gains +R +W +O permissions (the plus sign
     indicates gain).
  2. After `let num = &v[2]`, the data in `v` has been **borrowed** by `num`
     (indicated by [borrow]). Three things happen:
     - The borrow removes W O permissions from `v` (shown as -W -O for loss).
       `v` cannot be written, moved or dropped, but it can still be read.
     - The variable `num` has gained +R +O permissions. `num` is not writable
       (the missing W permission is shown as a .) because it was not marked
       `let mut`.
     - The **place** `*num` has gained the +R permission.
  3. After `println!(...)`, then `num` is no longer in use, so `v` is no longer
     borrowed. Therefore:
     - `v` regains its +W +O permissions (indicated by [regain]).
     - `num` and `*num` have lost all of their permissions (indicated by
       [end]).
  4. After `v.push(4)`, then `v` is no longer in use, and it loses all of its
     permissions.
  - Other details: borrowing part of `v` (one element) borrows all of `v`. If
    `v` were allowed to push while the `num` reference was live, it might have
    to reallocate a new array on the heap and `num` would be left dangling. The
    borrow ends when the reference is no longer being used; it doesn't have to
    go out of scope. Borrowing `v` temporarily takes away `v`'s ability to
    change, move or drop its data, so that `num` can't end up pointing at freed
    memory.
  - Also, why do we see both `num` and `*num`? Because accessing data through
    a reference is not the same as manipulating the reference itself. For
    example, if `num` is declared with `let mut num: &i32 = &x;`, then `num`
    can be reassigned to a different reference (`num` has W), but the data it
    points to cannot be mutated (`*num` does not have W). In general,
    permissions are defined on **places** not just variables. A place is
    anything you can put on the left-hand side of an assignment including:
    - Variables like `a`.
    - Dereferences of places like `*a`.
    - Array accesses of places like `a[0]`.
    - Fields of places like `a.0` for tuples or `a.field` for structs.
    - Any combination of the above like `*((*a)[0].1)`.
  - Places lose their permissions when they go unused because some permissions
    are mutually exclusive. If you write `num = &v[2]`, then `v` cannot be
    mutated or dropped while `num` is in use. But we could still use `num`
    later in the above code; it just means it doesn't lose its permissions until
    later. It has to stop being used before we `push` though, because we don't
    have W permission until its permissions are ended.
    Since 2018, Rust has ended a borrow at the reference's last use.
    Before that, a borrow lasted until the end of scope. This is called
    "non-lexical lifetimes" (NLL).
- Put simply, creating a reference to data ("borrowing" it) causes that data to
  be temporarily read-only until the reference is no longer in use. Rust uses
  these permissions in its **borrow checker**. The borrow checker looks for
  potentially unsafe operations involving references.

  ```rs
  // DOES NOT COMPILE! error[E0502]: cannot borrow `v` as mutable because it
  //                                 is also borrowed as immutable
  let mut v: Vec<i32> = vec![1, 2, 3];    // v    [init]   +R +W +O
  let num: &i32 = &v[2];                  // v    [needs]   R
                                          // v    [borrow]  R -W -O
                                          // num  [init]   +R  . +O
                                          // *num [init]   +R  .  .
  v.push(4);                              // v    [needs]   R  W  <- ERROR
  println!("Third element is {}", *num);
  ```

- The error message explains that `v` cannot be mutated while the reference
  `num` is in use. That's the surface-level reason - the underlying issue is
  that `num` could be invalidated by `push` and Rust catches that potential
  violation of memory safety.
- Mutable references provide unique and non-owning access to data. So far we
  have seen read-only **immutable references** (also called **shared
  references**). Immutable references permit aliasing but disallow mutation.
  However, it is also useful to temporarily provide mutable access to data
  without moving it. The mechanism for this is **mutable references** (also
  called **unique references**). Here is a simple example:

  ```rs
  let mut v: Vec<i32> = vec![1, 2, 3];    // v    [init]   +R +W +O
  let num: &mut i32 = &mut v[2];          // v    [needs]   R  W
                                          // v    [borrow] -R -W -O
                                          // num  [init]   +R  . +O
                                          // *num [init]   +R +W  .
  *num += 1;                              // *num [needs]   R  W
  println!("Third element is {}", *num);  // *num [needs]   R
                                          // v    [regain] +R +W +O
                                          // num  [end]    -R  . -O
                                          // *num [end]    -R -W  .
  println!("Vector is now {:?}", v);      // v    [needs]   R
                                          // v    [end]    -R -W -O
  ```

- A mutable reference is created with the `&mut` operator. The type of `num` is
  written as `&mut i32`. There are two differences from immutable references:
  1. When `num` was an immutable reference, `v` still had the R permission. Now
     that `num` is a mutable reference, `v` has lost *all* permissions while
     `num` is in use.
  2. When `num` was an immutable reference, the place `*num` only had the R
     permission. Now that `num` is a mutable reference, `*num` has also gained
     the W permission.
- The first observation is what makes mutable references *safe*. Mutable
  references allow mutation but prevent aliasing. The borrowed place `v` becomes
  temporarily unusable, so effectively not an alias.
- The second observation is what makes mutable references *useful*. `v[2]` can
  be mutated through `*num`. For example `*num += 1` mutates `v[2]`.
- Mutable references can also be temporarily downgraded to read-only references
  like: `let num2: &i32 = &*num;` where `*num` loses W and `*num2` gains R.
- Don't confuse a mutable variable holding a reference with a mutable
  reference. `let mut` on the variable controls whether `num` can be reassigned
  to point somewhere else (W on `num`). `&mut` in the type controls whether the
  data it points to can be changed (W on `*num`). They're independent:
  - `let mut num: &i32` can point elsewhere, but can't change the data.
  - `let num: &mut i32` can change the data, but can't point elsewhere.
- The rule behind that: `let mut` lets you change what the variable *directly
  holds*. The two-`mut` split only exists for references, because a reference
  variable has two places (`r` and `*r`). A variable that owns its value (a
  `Vec`, `String`, `i32`) has just one place, so a single `let mut` covers both
  modifying the value and reassigning the variable:

  ```rs
  let mut v = vec![1, 2, 3];  // v owns the Vec: one place, one `mut`
  v.push(4);                  // modify the Vec
  v = vec![9];                // or replace it; same `mut`

  let r = &mut v;             // r holds a reference: two places
  r.push(5);                  // fine without `let mut r`; changes *r, not r
  ```

- A reference changes permissions while it is "in use". "in use" here refers to
  a reference's **lifetime**, or the range of code spanning from its birth
  (where the reference is created) to its death (the last time the reference
  is used).

  ```rs
  fn ascii_capitalize(v: &mut Vec<char>) {           // v  [init]   +R  . +O
                                                     // *v [init]   +R +W  .
      let c = &v[0];                                 // v  [needs]   R
                                                     // v  [borrow]  R  . -O
                                                     // *v [borrow]  R -W  .
                                                     // c  [init]   +R  . +O
      if c.is_ascii_lowercase() {                    // c  [needs]   R
          let up = c.to_ascii_uppercase();           // c  [needs]   R
                                                     // c  [end]    -R  . -O
                                                     // v  [regain]  R  . +O
                                                     // *v [regain]  R +W  .
                                                     // up [init]   +R  . +O
          v[0] = up;                                 // up [needs]   R
                                                     // *v [needs]   R  W
      } else {                                       // c  [end]    -R  . -O
                                                     // v  [regain]  R  . +O
                                                     // *v [regain]  R +W  .
          println!("Already capitalized: {:?}", v);  // v  [needs]   R
      }
  }
  ```

- `v[0] = up` automatically dereferences `v`; it means `(*v)[0] = up`.
- Data must outlive all of its references. Rust enforces this property in two
  ways. The first way deals with references that are created and dropped within
  the scope of a single function. `drop` requires O permission, and making a
  reference to a variable removes its O permission. When references are either
  input to a function or output from a function, Rust doesn't know how long
  they live. For that we will have a new permission F, the flow permission.
  The following is a safe function that returns a reference to the first
  element of a vector:

  ```rs
  fn first(strings: &Vec<String>) -> &String { // strings  [init]   +R  . +O
                                               // *strings [init]   +R  .  .
      let s_ref = &strings[0];                 // strings  [needs]   R        F
                                               // *strings [needs]   R
                                               // strings  [borrow]  R  . -O
                                               // s_ref    [init]   +R  . +O
                                               // *s_ref   [init]   +R  .  .
      s_ref                                    // s_ref    [needs]   R        F
  }
  ```

- The flow permission is expected whenever an expression uses an input
  reference (like `&strings[0]`), or returns an output reference (like
  `return s_ref`). Unlike RWO permissions, F does not change throughout the body
  of a function. A reference has the F permission if it's allowed to be used
  (that is to *flow*) in a particular expression. The flow permission is decided
  by the function signature. `first` only has one input reference, so Rust
  assumes the output comes from it (called *lifetime elision*). That parameter
  has F, and so does `s_ref`, because it points into the data the parameter
  borrowed. If we change `first` to `first_or` which has a `default` parameter,
  the following won't compile:

  ```rs
  // DOES NOT COMPILE! error[E0106]: missing lifetime specifier
  fn first_or(strings: &Vec<String>, default: &String) -> &String {
      if strings.len() > 0 {
          &strings[0]     // strings  [needs]   R        F <- ERROR
      } else {
          default         // default  [needs]   R        F <- ERROR
      }
  }
  ```

- The help message from the compiler helps you understand the above error:
  ``this function's return type contains a borrowed value, but the signature
  does not say whether it is borrowed from `strings` or `default` ``. To
  understand why, imagine the following:

  ```rs
  // DOES NOT COMPILE! error[E0106]: missing lifetime specifier
  fn main() {
      let strings = vec![];
      let default = String::from("default");
      let s = first_or(&strings, &default);
      drop(default);
      println!("{}", s);
  }
  ```

- The program is unsafe if `first_or` allows `default` to *flow* into the
  return value. Rust would only allow this program to compile if it was certain
  that `default` cannot flow into the return value. Rust provides a mechanism
  called *lifetime parameters* which will be explained in Chapter 10, but for
  now it is enough to know that: input/output references are treated differently
  than references within a function body and Rust uses a different mechanism,
  the F permission, to check the safety of those references.
- To see F in another context, consider this:

  ```rs
  // DOES NOT COMPILE! error[E0106]: missing lifetime specifier
  fn return_a_string() -> &String {
      let s = String::from("Hello world");
      let s_ref = &s;
      s_ref
  }
  ```

- Clearly `s_ref` was invalidated when `return_a_string` returns because `s`
  gets popped from the stack and its memory deallocated. There are no input
  references, so nothing in the function has F, and a reference into a local
  like `s_ref` can never flow out.

### 4.3 - Fixing Ownership Errors

- Rust will always reject an unsafe program. But Rust will also sometimes reject
  a safe program. We need to learn how to respond to both.

#### Fixing an Unsafe Program: Returning a Reference to the Stack

  ```rs
  // DOES NOT COMPILE! error[E0106]: missing lifetime specifier
  fn return_a_string() -> &String {
      let s = String::from("Hello world");
      &s
  }
  ```

- This is clearly unsafe. We make a reference to a variable that is popped off
  the stack when we return. The simplest fix is to move ownership out of the
  function, changing `&String` to `String`:

  ```rs
  fn return_a_string() -> String {
      let s = String::from("Hello world");
      s
  }
  ```

- Or we could return a string literal, which lives forever (indicated by
  `'static`). This works if we never intend to change the string and avoids heap
  allocation:

  ```rs
  fn return_a_string() -> &'static str {
      "Hello world"
  }
  ```

- We also have the option to defer borrow checking to run time by using
  garbage collection. Here is a reference-counted pointer, which will be
  explained more in Chapter 15:

  ```rs
  use std::rc::Rc;
  fn return_a_string() -> Rc<String> {
      let s = Rc::new(String::from("Hello world"));
      Rc::clone(&s)
  }
  ```

- Put simply, `Rc::clone` only clones a pointer to `s` and not the data itself.
  At runtime, the `Rc` checks when the last `Rc` pointing to the data has been
  dropped and then deallocates the data. We could also have the caller provide
  a "slot" to put the string using a mutable reference:

  ```rs
  fn return_a_string(output: &mut String) {
      output.replace_range(.., "Hello world");
  }
  ```

- This style can be verbose, but it can also be more memory-efficient if the
  caller needs to carefully control when allocations occur.

#### Fixing an Unsafe Program: Not Enough Permissions

- Another common issue is trying to mutate read-only data, or trying to drop
  data behind a reference.

  ```rs
  // DOES NOT COMPILE! error[E0596]: cannot borrow `*name` as mutable, as it
  //                                 is behind a `&` reference
  fn stringify_name_with_title(name: &Vec<String>) -> String {
                                        // name  [init]  +R  . +O
                                        // *name [init]  +R  .  .
      name.push(String::from("Esq."));  // *name [needs]  R  W  <- ERROR
      let full = name.join(" ");
      full
  }
  // ideally: ["Ferris", "Jr."] => "Ferris Jr. Esq."
  ```

- This program is unsafe because `push` could invalidate other references to
  `name` outside of `stringify_name_with_title`. Consider:

  ```rs
  fn main() {
      let name = vec![String::from("Ferris")];
      let first = &name[0]; // L1
      stringify_name_with_title(&name); // L2
      println!("{}", first); // L3
  }

  L1
  Stack            Heap
  main
    name  | *----> buf1 [*] ----> "Ferris"
    first | *----> buf1[0]

  L2 (push moved the slots to buf2 and freed buf1)
  Stack            Heap
  main
    name  | *----> buf2 [*, *] -> "Ferris", "Esq."
    first | *----> [freed]

  L3
    println!("{}", first) reads through first  <-- UB
  ```

- The easiest solution, but also a bad solution, is to simply pass a
  `&mut Vec<String>` to `stringify_name_with_title`. However, functions should
  not mutate their inputs if the caller would not expect it. Another option is
  to take ownership of the name by changing `&Vec<String>` to `Vec<String>`:

  ```rs
  fn stringify_name_with_title(mut name: Vec<String>) -> String {
      name.push(String::from("Esq."));
      let full = name.join(" ");
      full
  }
  ```

  This is also a bad solution. It is very rare for Rust functions to take
  ownership of heap-owning data structures like `Vec` or `String`. This version
  would make the input `name` unusable, which is annoying to a caller.
- Instead we could continue passing `&Vec` but clone the vector:

  ```rs
  fn stringify_name_with_title(name: &Vec<String>) -> String {
      let mut name_clone = name.clone();
      name_clone.push(String::from("Esq."));
      let full = name_clone.join(" ");
      full
  }
  ```

- We could avoid unnecessary copies by adding the suffix later, which works
  because `slice::join` already copies the data from `name` into `full`:

  ```rs
  fn stringify_name_with_title(name: &Vec<String>) -> String {
      let mut full = name.join(" ");
      full.push_str(" Esq.");
      full
  }
  ```

#### Fixing an Unsafe Program: Aliasing and Mutating a Data Structure

- Another unsafe operation is using a reference to heap data that gets
  deallocated by another alias. This function gets a reference to the largest
  string in a vector and then uses it while mutating the vector:

  ```rs
  // DOES NOT COMPILE! error[E0502]: cannot borrow `*dst` as mutable because it
  //                                 is also borrowed as immutable
  fn add_big_strings(dst: &mut Vec<String>, src: &[String]) {
                                                      // *dst [init]    +R +W  .
      let largest: &String =
          dst.iter().max_by_key(|s| s.len()).unwrap();// *dst [needs]    R
                                                      // *dst [borrow]   R -W  .
      for s in src {
          if s.len() > largest.len() {
              dst.push(s.clone());                    // *dst [needs]    R  W
                                                      //      <- ERROR: no W
          }
      }
  }
  ```

- This program is unsafe because `dst.push(...)` could deallocate the contents
  of `dst` and invalidate the reference `largest`. The most direct fix would be
  to shorten the lifetime of `largest` to not overlap with `dst.push(...)`.
  One possibility is to clone `largest`:

  ```rs
  fn add_big_strings(dst: &mut Vec<String>, src: &[String]) {
      let largest: String = dst.iter().max_by_key(|s| s.len()).unwrap().clone();
      for s in src {
          if s.len() > largest.len() {
              dst.push(s.clone());
          }
      }
  }
  ```

- This may involve a performance hit for allocating and copying the string data.
  Another possibility is to perform all the length comparisons first and mutate
  `dst` afterwards:

  ```rs
  fn add_big_strings(dst: &mut Vec<String>, src: &[String]) {
      let largest: &String = dst.iter().max_by_key(|s| s.len()).unwrap();
      let to_add: Vec<String> =
          src.iter().filter(|s| s.len() > largest.len()).cloned().collect();
      dst.extend(to_add);
  }
  ```

- However this also causes a performance hit for allocating the vector `to_add`.
  A final possibility is to copy out the length of `largest`, since we actually
  only need its length and not its contents. It's arguably the most idiomatic
  and performant solution:

  ```rs
  fn add_big_strings(dst: &mut Vec<String>, src: &[String]) {
      let largest_len: usize =
          dst.iter().max_by_key(|s| s.len()).unwrap().len();
      for s in src {
          if s.len() > largest_len {
              dst.push(s.clone());
          }
      }
  }
  ```

- These solutions share the same key idea: shortening the lifetime of borrows
  on `dst` to not overlap with a mutation to `dst`.

#### Fixing an Unsafe Program: Copying vs. Moving Out of a Collection

- First we will look at two small programs. The first is safe and the second
  will not compile.

  ```rs
  let v: Vec<i32> = vec![0, 1, 2];  // v      [init]   +R  . +O
  let n_ref: &i32 = &v[0];          // v      [needs]   R
                                    // v      [borrow]  R  . -O
                                    // n_ref  [init]   +R  . +O
                                    // *n_ref [init]   +R  .  .
  let n: i32 = *n_ref;              // *n_ref [needs]   R
                                    // v      [end]    -R  .  .
                                    // n_ref  [end]    -R  . -O
                                    // *n_ref [end]    -R  .  .
                                    // n      [init]   +R  . +O
  ```

  ```rs
  // DOES NOT COMPILE! error[E0507]: cannot move out of `*s_ref` which is behind
  //                                 a shared reference
  let v: Vec<String> =
      vec![String::from("Hello world")];  // v      [init]   +R  . +O
  let s_ref: &String = &v[0];             // v      [needs]   R
                                          // v      [borrow]  R  . -O
                                          // s_ref  [init]   +R  . +O
                                          // *s_ref [init]   +R  .  .
  let s: String = *s_ref;                 // *s_ref [needs]   R     O  <- ERROR
  ```

- The difference is that a `String` owns heap data and an `i32` does not.
  Copying the `String` out of `v` would copy its pointer to the heap data, so
  Rust would free that memory when `s` goes out of scope, then free the same
  memory again when `v` goes out of scope (a double free). If a value does not
  own heap data, then it can be copied without a move: `i32` and `&String` can
  be copied, but `String` cannot. One exception is mutable references: an
  `&mut i32` does not own heap data, but it cannot be copied. After
  `let b = a;` where `a` is an `&mut i32`, `a` can no longer be used, because
  we can't have two usable mutable references to the same data.
- You can fix this by avoiding taking ownership of the string and just using an
  immutable reference:

  ```rs
  let v: Vec<String> = vec![String::from("Hello world")];
  let s_ref: &String = &v[0];
  println!("{s_ref}!");
  ```

- You can also clone the data you want to get ownership of and leave the vector
  alone:

  ```rs
  let v: Vec<String> = vec![String::from("Hello world")];
  let mut s: String = v[0].clone();
  s.push('!');
  println!("{s}");
  ```

- Finally, you can use a method like `Vec::remove` to move the string out of the
  vector:

  ```rs
  let mut v: Vec<String> = vec![String::from("Hello world")];
  let mut s: String = v.remove(0);
  s.push('!');
  println!("{s}");
  assert!(v.len() == 0);
  ```

#### Fixing a Safe Program: Mutating Different Tuple Fields

- First let's look at an example of fine-grained permission tracking that works:

  ```rs
  let mut name = (              // name   [init]   +R +W +O
      String::from("Ferris"),   // name.0 [init]   +R +W +O
      String::from("Rustacean") // name.1 [init]   +R +W +O
  );
  let first = &name.0;          // name   [borrow]  R -W -O
                                // name.0 [borrow]  R -W -O
  name.1.push_str(", Esq.");    // name.1 [needs]   R  W
  println!("{first} {}", name.1);
  ```

- If however we define a `get_first` function, Rust might lose track of the fact
  that `name.1` still has write permission:

  ```rs
  // DOES NOT COMPILE! error[E0502]: cannot borrow `name.1` as mutable because
  //                                 it is also borrowed as immutable
  fn get_first(name: &(String, String)) -> &String {
      &name.0
  }

  fn main() {
      let mut name = (
          String::from("Ferris"),
          String::from("Rustacean")
      );
      let first = get_first(&name);   // name   [borrow]  R -W -O
                                      // name.0 [borrow]  R -W -O
                                      // name.1 [borrow]  R -W -O
      name.1.push_str(", Esq.");      // name.1 [needs]   R  W    <- ERROR
      println!("{first} {}", name.1);
  }
  ```

- To fix this, we can either inline `&name.0` or defer borrow checking to
  runtime with cells, which we will discuss later.

#### Fixing a Safe Program: Mutating Different Array Elements

- A similar problem occurs when we borrow elements of an array. Borrowing one
  element works fine:

  ```rs
  let mut a = [0, 1, 2, 3];
  let x = &mut a[1];          // a[_] [borrow] -R -W  .
  *x += 1;                    // a[_] [regain] +R +W  .
  println!("{a:?}");
  ```

- But borrowing a second element while the first borrow is live fails, even
  though `a[1]` and `a[2]` don't overlap:

  ```rs
  // DOES NOT COMPILE! error[E0502]: cannot borrow `a[_]` as immutable because
  //                                 it is also borrowed as mutable
  let mut a = [0, 1, 2, 3];
  let x = &mut a[1];          // a[_] [borrow] -R -W  .
  let y = &a[2];              // a[_] [needs]   R        <- ERROR
  *x += *y;
  ```

- Rust's borrow checker doesn't keep track of which elements in an array are
  borrowed. It uses a single place, `a[_]`, to represent all indexes of `a`. It
  does this because an index could be calculated at runtime and not known at
  compile time. We can work around the borrow checker with
  `slice::split_at_mut`:

  ```rs
  let mut a = [0, 1, 2, 3];
  let (a_l, a_r) = a.split_at_mut(2);
  let x = &mut a_l[1];
  let y = &a_r[0];
  *x += *y;
  ```

- We could also directly use `unsafe`:

  ```rs
  let mut a = [0, 1, 2, 3];
  let x = &mut a[1] as *mut i32;
  let y = &a[2] as *const i32;
  unsafe { *x += *y; } // DO NOT DO THIS unless you know what you're doing!
  ```

### 4.4 - The Slice Type

- A slice is a kind of reference (a non-owning pointer) that refers to a
  contiguous sequence of elements in a collection rather than a whole
  collection. To motivate why slices are useful, consider a function that takes
  a string of words separated by spaces and returns the first word it finds in
  that string. A function to do this might have the signature:
  `fn first_word(s: &String) -> ?`. We don't want ownership of the string, and
  what should we return? We don't have a way to say "part of a string".
  This function returns the index of the end of the first word:

  ```rs
  fn first_word(s: &String) -> usize {
      let bytes = s.as_bytes();

      for (i, &item) in bytes.iter().enumerate() {
          if item == b' ' {
              return i;
          }
      }

      s.len()
  }
  ```

- However, the number we return isn't connected to the original `String` at all.
  Someone could `clear` the `String` and we would have a number that means
  nothing. A *string slice* is a reference to part of a `String` and looks like:

  ```rs
  let s = String::from("hello world");

  let hello: &str = &s[0..5];
  let world: &str = &s[6..11];
  let s2: &String = &s; // L1

  L1
  Stack                  Heap
  main
    s     | *----------> "hello world"
    hello | *, len 5 --> "hello world"[0..5]
    world | *, len 5 --> "hello world"[6..11]
    s2    | *-> s
  ```

- We create slices using a range within brackets by specifying
  `[starting_index..ending_index]` where `starting_index` is the first position
  in the slice and `ending_index` is one more than the last position in the
  slice. Slices are "fat" pointers, or pointers with metadata. The metadata is
  the length of the slice. `hello` points to "h" and has a `len` of 5.
  As references, slices change the permissions on referenced data.

  ```rs
  fn main() {
      let mut s = String::from("hello");  // s      [init]   +R +W +O
      let hello: &str = &s[0..5];         // s      [needs]   R
                                          // s      [borrow]  R -W -O
                                          // hello  [init]   +R  . +O
                                          // *hello [init]   +R  .  .
      println!("{hello}");                // hello  [needs]   R
                                          // s      [regain]  R +W +O
                                          // hello  [end]    -R  . -O
                                          // *hello [end]    -R  .  .
      s.push_str(" world");               // s      [needs]   R  W
                                          // s      [end]    -R -W -O
  }
  ```

- In range syntax, you can drop `starting_index` if you want to start at `0`,
  and drop `ending_index` if you want to end at `len`. `[0..2]` becomes `[..2]`
  and `[3..len]` becomes `[3..]`. You can drop both values to take a slice of
  the entire string.
- So now let's rewrite `first_word` with string slices:

  ```rs
  fn first_word(s: &String) -> &str {
      let bytes = s.as_bytes();

      for (i, &item) in bytes.iter().enumerate() {
          if item == b' ' {
              return &s[0..i];
          }
      }

      &s[..]
  }
  ```

- Now when we call `first_word`, we get back a single value that is tied to the
  underlying data. The compiler ensures the reference into the `String` remains
  valid. This does not compile:

  ```rs
  // DOES NOT COMPILE! error[E0502]: cannot borrow `s` as mutable because it is
  //                                 also borrowed as immutable
  fn main() {
      let mut s = String::from("hello world");
      let word = first_word(&s);                // s [borrow]  R -W -O
      s.clear();                                // s [needs]   R  W    <- ERROR
      println!("the first word is: {}", word);
  }
  ```

- Recall from the borrowing rules that if we have an immutable reference to
  something, we cannot also take a mutable reference. Because `clear` needs to
  truncate the `String`, it needs to get a mutable reference. The `println!`
  after the call to `clear` uses the reference in `word`, so the immutable
  reference must still be active at that point. But Rust disallows the mutable
  reference in `clear` and the immutable reference in `word` from existing at
  the same time, and compilation fails.
- String literals are slices. When we type `let s = "Hello, world!";` the type
  of `s` is `&str`. It's a slice pointing to that specific point of the binary.
  `&str` is an immutable reference. As another improvement, we can change the
  signature of `first_word` to `fn first_word(s: &str) -> &str {` and it will be
  able to work both on a slice of the `String` or a reference to the `String`.

  ```rs
  fn main() {
      let my_string = String::from("hello world");

      // `first_word` works on slices of `String`s, whether partial or whole.
      let word = first_word(&my_string[0..6]);
      let word = first_word(&my_string[..]);
      // `first_word` also works on references to `String`s, which are
      // equivalent to whole slices of `String`s.
      let word = first_word(&my_string);

      let my_string_literal = "hello world";

      // `first_word` works on slices of string literals, partial or whole
      let word = first_word(&my_string_literal[0..6]);
      let word = first_word(&my_string_literal[..]);

      // Because string literals *are* string slices already,
      // this works too, without the slice syntax!
      let word = first_word(my_string_literal);
  }
  ```

- Slice syntax also works to refer to part of an array:

  ```rs
  let a = [1, 2, 3, 4, 5];
  let slice = &a[1..3];
  assert_eq!(slice, &[2, 3]);
  ```

- Slice syntax also works with other collections. We'll talk about them when
  we discuss vectors in Chapter 8.
- Remember, a slice is both a pointer and a length, so it takes up slightly more
  memory than just a pointer (16 bytes vs 8 bytes on 64-bit architecture).

### 4.5 - Ownership Recap

- Ownership at Runtime
  - Rust allocates local variables in stack frames, which are allocated when a
    function is called and deallocated when the call ends.
  - Local variables can hold either data (like numbers, booleans, tuples, etc.)
    or pointers.
  - Pointers can be created either through boxes (pointers owning data on the
    heap) or references (non-owning pointers).

  ```rs
  fn main() {
      let mut a_num = 0;
      inner(&mut a_num); // L2
  }

  fn inner(x: &mut i32) {
      let another_num = 1;
      let a_stack_ref = &another_num;

      let a_box = Box::new(2);
      let a_box_stack_ref = &a_box;
      let a_box_heap_ref = &*a_box; // L1

      *x += 5;
  }

  L1                                              L2
  Stack                             Heap          Stack
  main                                            main
    a_num           | 0                             a_num | 5
  inner
    x               | *-> a_num
    another_num     | 1
    a_stack_ref     | *-> another_num
    a_box           | *-----------> 2
    a_box_stack_ref | *-> a_box
    a_box_heap_ref  | *-----------> 2 (the same 2)
  ```

- Slices are a special kind of reference that refer to a contiguous sequence of
  data in memory.

  ```rs
  fn main() {
      let s = String::from("abcdefg");
      let s_slice = &s[2..5]; // L1
  }

  L1
  Stack                 Heap
  main
    s       | *----------> "abcdefg"
    s_slice | *, len 3 --> "abcdefg"[2..5] ("cde", not a separate copy)
  ```

- Rust tracks R (read), W (write), and O (own) permissions on each variable.
  Rust requires that a variable has appropriate permissions to perform a given
  operation. As a basic example, if a variable isn't declared `let mut`, then it
  is missing the W permission and cannot be mutated. A variable's permissions
  can be changed if it is **moved** or **borrowed**. A move of a variable with a
  non-copyable type like `Box<T>` or `String` requires RO permissions and the
  move eliminates all permissions on the original variable. Borrowing a variable
  (creating a reference to it) temporarily removes some of the variable's
  permissions. An immutable borrow creates an immutable reference and also
  disables the borrowed data from being mutated or moved. You cannot mutate
  through the original or the immutable reference and moving data out of the
  reference (with `let s2 = *s_ref`) is also not ok. A mutable borrow creates a
  mutable reference which disables the borrowed data from being read, written,
  or moved. Mutating through the reference is fine, but you cannot even read
  through the original variable until you are done with the mutable reference.

## Chapter 5 - Using Structs to Structure Related Data

### 5.1 - Defining and Instantiating Structs

- Structs are like tuples in that both hold multiple related values, but in a
  struct you name each piece of data so it's clear what the values mean.
  You define a struct with the `struct` keyword:

  ```rs
  struct User {
      active: bool,
      username: String,
      email: String,
      sign_in_count: u64,
  }
  ```

- To use a struct after we've defined it, we create an instance of that struct
  by specifying concrete values for each of the fields.

  ```rs
  fn main() {
      let user1 = User {
          email: String::from("someone@example.com"),
          username: String::from("someusername123"),
          active: true,
          sign_in_count: 1,
      }; // L1
  }

  L1
  Stack                              Heap
  main
    user1.active        | true
    user1.username      | *--------> "someusername123"
    user1.email         | *--------> "someone@example.com"
    user1.sign_in_count | 1
  ```

- To get a specific value from a struct, we use dot notation. If the instance
  is mutable, we change a field with dot notation and assigning into a
  particular field. Note that we use `let mut user1` to make the entire instance
  mutable; Rust doesn't allow us to mark only certain fields as mutable.
- You can build a struct with a function and return the struct if it is the last
  expression in the function body. This is so common that there is a *field init
  shorthand* syntax for doing this with less repetition:

  ```rs
  // `build_user` without special syntax
  fn build_user(email: String, username: String) -> User {
      User {
          active: true,
          username: username,
          email: email,
          sign_in_count: 1,
      }
  }

  // `build_user` with *field init shorthand*
  fn build_user(email: String, username: String) -> User {
      User {
          active: true,
          username,
          email,
          sign_in_count: 1,
      }
  }
  ```

- Because the parameters have the same name as the struct fields they are
  meant for, we only have to specify the parameter: `username,` instead of
  `username: username,`.
- Struct update syntax provides a convenient way to copy another struct and
  update certain fields. You use `..struct_name` to set unspecified fields as
  equal:

  ```rs
  // without struct update syntax
  fn main() {
      // --snip--

      let user2 = User {
          active: user1.active,
          username: user1.username,
          email: String::from("another@example.com"),
          sign_in_count: user1.sign_in_count,
      };
  }

  // with struct update syntax
  fn main() {
      // --snip--

      let user2 = User {
          email: String::from("another@example.com"),
          ..user1
      };
  }
  ```

- The `..user1` must come last and specifies all remaining fields should be set
  equal to `user1`.
- Note that you can specify a struct's fields and values in any order, if you
  haven't noticed we aren't using the same order as the definition.
- Note also that ownership still applies. `..user1` moves the `String` in
  `user1.username` into `user2`, so `user1` is partially invalidated: we can no
  longer use `user1` as a whole or `user1.username`, though its other fields
  are still usable. If we had given `user2` new values for both `email` and
  `username`, `user1` would still be fully valid, because `active` and
  `sign_in_count` implement the `Copy` trait and are copied rather than moved.
- Rust also supports *tuple structs*. They have a name but don't have names
  associated with their fields; rather, they just have the types of the fields.
  Tuple structs are useful when you want to give the whole tuple a name and make
  the tuple a different type from other tuples, and when naming each field as in
  a regular struct would be verbose or redundant.

  ```rs
  struct Color(i32, i32, i32);
  struct Point(i32, i32, i32);

  fn main() {
      let black = Color(0, 0, 0);
      let origin = Point(0, 0, 0);
  }
  ```

- Above `black` and `origin` have the same values but are different types
  because they're instances of different tuple structs. Each struct you define
  is its own type, even though the fields within the struct might have the same
  types. A function that takes a parameter of type `Color` cannot take a `Point`
  as an argument even though both are three `i32` values. Tuple structs still
  support `.` syntax to access an individual value like `black.0`, and you can
  still destructure them but need to specify the type of the struct when doing
  so like `let Point(x, y, z) = origin;`.
- You can also define *unit-like structs* that lack any data fields. They can
  be useful if you need to implement a trait on some type but don't have any
  data that you want to store in the type itself:

  ```rs
  struct AlwaysEqual;

  fn main() {
      let subject = AlwaysEqual;
  }
  ```

- We used the owned `String` type rather than `&str` slice type in the `User`
  struct defined above. This is a deliberate choice because we want each
  instance of this struct to own all of its data and for that data to be valid
  for as long as the entire struct is valid. Structs can also store references
  to data owned by something else, but to do this requires *lifetimes*, a Rust
  feature we will discuss in Chapter 10.

  ```rs
  // DOES NOT COMPILE! error[E0106]: missing lifetime specifier
  struct User {
      active: bool,
      username: &str,
      email: &str,
      sign_in_count: u64,
  }

  fn main() {
      let user1 = User {
          active: true,
          username: "someusername123",
          email: "someone@example.com",
          sign_in_count: 1,
      };
  }
  ```

- Rust's borrow checker will track ownership permissions both at the
  struct-level and field-level. If you borrow field `x` of a `Point` structure
  `p`, it will affect both permissions of `p` and `p.x`, but not `p.y`.

  ```rs
  struct Point { x: i32, y: i32 }
  let mut p = Point { x: 0, y: 0 };   // p   [init]   +R +W +O
                                      // p.x [init]   +R +W +O
                                      // p.y [init]   +R +W +O
  let x = &mut p.x;                   // p.x [needs]   R  W
                                      // p   [borrow] -R -W -O
                                      // p.x [borrow] -R -W -O
                                      // x   [init]   +R  . +O
                                      // *x  [init]   +R +W  .
  *x += 1;                            // *x  [needs]   R  W
                                      // x   [end]    -R  . -O
                                      // *x  [end]    -R -W  .
                                      // p   [regain] +R +W +O
                                      // p.x [regain] +R +W +O
  println!("{}, {}", p.x, p.y);       // p.x [needs]   R
                                      // p.y [needs]   R
  ```

- If we had tried to use `p` while `p.x` was mutably borrowed, we would have
  gotten ``error[E0502]: cannot borrow `p` as immutable because it is also
  borrowed as mutable``. Generally, if you encounter an ownership error that
  involves a struct, you should consider which fields of your structure are
  supposed to be borrowed with which permissions. But be aware of the borrow
  checker's limitations, since Rust may sometimes assume more fields are
  borrowed than they actually are.

### 5.2 - An Example Program Using Structs

- Consider a simple program to calculate the area of rectangles:

  ```rs
  // ch05_rectangles/src/main.rs
  fn main() {
      let width1 = 30;
      let height1 = 50;

      println!(
          "The area of the rectangle is {} square pixels.",
          area(width1, height1)
      );
  }

  fn area(width: u32, height: u32) -> u32 {
      width * height
  }
  ```

- While this works, we have a problem that `area` calculates the area of one
  rectangle but here it takes two parameters and it's not clear they are
  related. We could make it a little more clear with a tuple:

  ```rs
  fn main() {
      let rect1 = (30, 50);

      println!(
          "The area of the rectangle is {} square pixels.",
          area(rect1)
      );
  }

  fn area(dimensions: (u32, u32)) -> u32 {
      dimensions.0 * dimensions.1
  }
  ```

- Now we have our data all in one argument, but it's hard for a newcomer to
  remember width is the first piece of data and height the second without
  labels. This doesn't matter for our area calculation, but if we were trying to
  draw the rectangle, it could prove disastrous.

  ```rs
  struct Rectangle {
      width: u32,
      height: u32,
  }

  fn main() {
      let rect1 = Rectangle {
          width: 30,
          height: 50,
      };

      println!(
          "The area of the rectangle is {} square pixels.",
          area(&rect1)
      );
  }

  fn area(rectangle: &Rectangle) -> u32 {
      rectangle.width * rectangle.height
  }
  ```

- Now `area` takes one parameter and both pieces of data are labeled. Note that
  `rectangle` parameter is an immutable borrow of a struct `Rectangle` instance.
  This way, `main` retains ownership and can continue using `rect1`. Note that
  accessing the fields of a borrowed struct instance does not move the field
  values, which is why you often see borrows of structs.
- Imagine if to debug we wanted to print our rectangle above, like
  `println!("rect1 is {rect1}");`. This would fail to compile with an
  ``error[E0277]: `Rectangle` doesn't implement `std::fmt::Display` ``.
  `println!` macro supports multiple types of formatting, but by default the
  curly brackets tell it to use a formatting known as `Display`, output intended
  for direct end user consumption. Instead we can try to print our rectangle
  using `Debug` which is meant for developers. To do this, we replace `{rect1}`
  with `{rect1:?}` like `println!("rect1 is {rect1:?}");` and this changes our
  compile error to ``error[E0277]: `Rectangle` doesn't implement `Debug` ``.
  There is a default implementation of `Debug` however and we can implement it
  by adding `#[derive(Debug)]` above the definition of our `Rectangle` struct.
  This will give us output `rect1 is Rectangle { width: 30, height: 50 }`.

  ```rs
  #[derive(Debug)]
  struct Rectangle {
      width: u32,
      height: u32,
  }

  fn main() {
      let rect1 = Rectangle {
          width: 30,
          height: 50,
      };

      println!("rect1 is {rect1:?}");
  }
  ```

- To display it split across multiple lines, use `{:#?}` instead of `{:?}`.
  There is also a `dbg!` macro that takes ownership of an expression, prints the
  file and line number of where the macro occurs, and prints the resultant
  value of that expression, then returns ownership of the value. It prints to
  `stderr`.

  ```rs
  // ch05_rectangles/src/main.rs
  #[derive(Debug)]
  struct Rectangle {
      width: u32,
      height: u32,
  }

  fn main() {
      let scale = 2;
      let rect1 = Rectangle {
          width: dbg!(30 * scale),
          height: 50,
      };

      dbg!(&rect1);
  }
  ```

  ```text
  $ cargo run
     Compiling rectangles v0.1.0 (file:///projects/rectangles)
      Finished `dev` profile [unoptimized + debuginfo] target(s) in 0.61s
       Running `target/debug/rectangles`
  [src/main.rs:10:16] 30 * scale = 60
  [src/main.rs:14:5] &rect1 = Rectangle {
      width: 60,
      height: 50,
  }
  ```

- The `width` field gets the same value because `dbg!` returns ownership.
  However we don't want `dbg!` to take ownership of `rect1`, so we use a
  reference to `rect1` in the next call.
- It's cool we're printing out our struct, but we forgot all about `area`. Let's
  fix that...

### 5.3 - Method Syntax

- Methods are similar to functions but are defined within the context of a
  struct, enum, or trait and their first parameter is always `self`.

  ```rs
  // ch05_rectangles/src/main.rs
  #[derive(Debug)]
  struct Rectangle {
      width: u32,
      height: u32,
  }

  impl Rectangle {
      fn area(&self) -> u32 {
          self.width * self.height
      }
  }

  fn main() {
      let rect1 = Rectangle {
          width: 30,
          height: 50,
      };

      println!(
          "The area of the rectangle is {} square pixels.",
          rect1.area()
      );
  }
  ```

- To define a function within the context of `Rectangle`, we start an `impl`
  block for `Rectangle`. Everything within this `impl` block will be associated
  with the `Rectangle` type. `area` is mostly the same as when it was a separate
  function except for the new `&self` parameter instead of taking an
  `&Rectangle` and using `self` to access the data elements. You call `area`
  using the `.` syntax on an instance of the struct type. `&self` is actually
  shorthand for `self: &Self`. Within an `impl` block, `Self` is an alias for
  the type that the `impl` block is for (here `Rectangle`). Methods can take
  ownership of `self`, borrow `self` immutably (like we did here), or borrow
  `self` mutably just as they can any other parameter. It is very rare to take
  ownership of `self`, and we didn't need `&mut self` here to read values.
  Methods can have the same name as data fields, and Rust knows which you are
  accessing by whether or not you use parentheses. Often when we do this, we
  want the method to return the value of the field and do nothing else;
  *getters*. This is useful to designate a field as private but give it a public
  getter so that it is read-only, and we will cover public/private in Chapter 7.
- Methods are a type of *associated function*. Everything in an `impl` block is
  an associated function with the type named after the `impl`. But we can define
  functions without a `self` parameter that are not methods if they do not need
  an instance of the type to work with. `String::from` is an example of an
  associated function defined on the `String` type. This functionality is often
  used for constructors that return a new instance of the struct, and they are
  often called `new`, but this isn't a special name in Rust. The associated
  function is namespaced by the struct and you use the `::` syntax to call it.
  The `::` syntax is also used for namespaces created by modules which we will
  discuss in Chapter 7. Method calls with the `.` syntax are just syntactic
  sugar for calling the method with `::` and providing `&r` for an instance `r`.
- It is valid to have multiple `impl` blocks for the same type. We will see a
  use for this when we discuss generic types and traits.
- Rust inserts as many references and dereferences as needed to make types
  match up for the `self` parameter. In the following code, we need an
  immutable borrow plus two dereferences (one for the mutable reference and one
  for the box):

  ```rs
  let r = &mut Box::new(Rectangle {
      width: 1,
      height: 2
  });
  let area1 = r.area();
  let area2 = Rectangle::area(&**r);
  assert_eq!(area1, area2);
  ```

- To study methods and ownership, we will use a running example of these three
  methods that take `&self`, `&mut self`, and `self`.

  ```rs
  impl Rectangle {
      fn area(&self) -> u32 {
          self.width * self.height
      }

      fn set_width(&mut self, width: u32) {
          self.width = width;
      }

      fn max(self, other: Rectangle) -> Rectangle {
          Rectangle {
              width: self.width.max(other.width),
              height: self.height.max(other.height),
          }
      }
  }
  ```

- If we make an owned rectangle with `let rect = Rectangle { ... }`, then `rect`
  has R and O permissions so we can call `area` and `max` methods but not
  `set_width` which would require W. Trying the latter would give
  ``error[E0596]: cannot borrow `rect` as mutable, as it is not declared as
  mutable``. It would be fine to call `set_width` through a mutable reference,
  `let rect_ref = &mut rect;` (which requires declaring `let mut rect`), but we
  would get a similar error through an immutable reference,
  `let rect_ref = &rect;`. Calling `max` moves ownership, so we can no longer
  use our original variable (unless the struct implements `Copy`). Once we call
  `rect.max(..)`, we move `rect` and so lose all permission on it. Trying to use
  it afterwards would give ``error[E0382]: borrow of moved value: `rect` ``. We
  would also get an error, ``error[E0507]: cannot move out of `*self` which is
  behind a mutable reference``, if we wrote a `&mut self` method that did
  `*self = self.max(other);`. Calling `max` requires ownership, which we do not
  have through `*self`. This would actually be safe since our `Rectangle`
  doesn't own any heap data, and you could make it work by adding
  `#[derive(Copy, Clone)]` to the `struct` definition, so calling `max` copies
  `*self` instead of moving it. So remember: when you see an error like "cannot
  move out of `*self`", that's usually because you're trying to call a `self`
  method on a reference like `&self` or `&mut self` and Rust is protecting you.

  ```rs
  // ch05_rectangles/src/main.rs
  #[derive(Debug)]
  struct Rectangle {
      width: u32,
      height: u32,
  }

  impl Rectangle {
      fn area(&self) -> u32 {
          self.width * self.height
      }

      fn set_width(&mut self, width: u32) {
          self.width = width;
      }

      fn max(self, other: Rectangle) -> Rectangle {
          Rectangle {
              width: self.width.max(other.width),
              height: self.height.max(other.height),
          }
      }
  }

  fn main() {
      let scale = 2;
      let rect1 = Rectangle {
          width: dbg!(30 * scale),
          height: 50,
      };

      dbg!(&rect1);

      println!(
          "The area of the rectangle is {} square pixels.",
          rect1.area()
      );
  }
  ```

## Chapter 6 - Enums and Pattern Matching

- Enums allow you to define a type by enumerating its possible variants.

### 6.1 - Defining an Enum

- Enums give you a way of saying a value is one of a possible set of values.
- Consider an IP address. It can either be a version four or a version six
  address, but not both at the same time. When you define an enum, it becomes a
  custom data type that can be used anywhere in your code.

  ```rs
  enum IpAddrKind {
      V4,
      V6,
  }

  // Using the enum
  let four = IpAddrKind::V4;
  let six = IpAddrKind::V6;
  fn route(ip_kind: IpAddrKind) {}

  // Instead of embedding the enum in a struct, we can also carry data
  enum IpAddr {
      V4(String),
      V6(String),
  }

  let home = IpAddr::V4(String::from("127.0.0.1"));
  let loopback = IpAddr::V6(String::from("::1"));

  // The two don't have to take the same arguments
  enum IpAddr {
      V4(u8, u8, u8, u8),
      V6(String),
  }

  let home = IpAddr::V4(127, 0, 0, 1);
  let loopback = IpAddr::V6(String::from("::1"));

  // Enums can even contain structs, like the standard library `IpAddr`
  struct Ipv4Addr { /* --snip-- */ }
  struct Ipv6Addr { /* --snip-- */ }
  enum IpAddr {
      V4(Ipv4Addr),
      V6(Ipv6Addr),
  }

  // Here's an enum with four variants with different types:
  enum Message {
      Quit,
      Move { x: i32, y: i32 },
      Write(String),
      ChangeColor(i32, i32, i32),
  }

  // We can also define methods on enums with `impl`
  impl Message {
      fn call(&self) {
          // method body would be defined here
      }
  }

  let m = Message::Write(String::from("hello"));
  m.call();
  ```

- As you can see above, the name of each enum variant becomes a function that
  constructs an instance of the enum. It can optionally take data arguments.
- The `Option` enum is included in the standard library and encodes when a value
  could be something or nothing. `Option` is included in the prelude and does
  not need to be brought into scope explicitly. Even its variants are included
  in the prelude, so you can use `Some` and `None` without the `Option::`
  prefix.
- Rust does not have `null` or `nil`. It instead has `Option<T>`.

  ```rs
  enum Option<T> {
      None,
      Some(T),
  }

  let some_number = Some(5);              // Option<i32>
  let some_char = Some('e');              // Option<char>
  let absent_number: Option<i32> = None;
  ```

- You cannot add an `i32` to an `Option<i32>` without converting the latter. But
  how do you get the `i32` out of an `Option<i32>`? In general, you need code to
  handle each variant. That way you explicitly deal with the `None` case.
  `match` is an easy way to do so.

### 6.2 - The `match` Control Flow Construct

- `match` allows you to compare a value against a series of patterns and then
  execute code based on which pattern matches. Patterns can be made up of
  literal values, variable names, wildcards, and many other things; Chapter 19
  is all about patterns. The power of `match` comes from the expressiveness of
  patterns and the fact that the compiler confirms that all possible cases are
  handled. The code block associated with the first matched pattern is executed.

  ```rs
  enum Coin {
      Penny,
      Nickel,
      Dime,
      Quarter,
  }

  fn value_in_cents(coin: Coin) -> u8 {
      match coin {
          Coin::Penny => 1,
          Coin::Nickel => 5,
          Coin::Dime => 10,
          Coin::Quarter => 25,
      }
  }
  ```

- A `match` is said to have arms. An arm is a pattern and some code. The `=>`
  operator separates the pattern and the code to run. Each arm is separated from
  the next with a comma. The code associated with each arm is an expression, and
  the resultant value of the expression in the matching arm is the value that
  gets returned for the entire `match` expression. In our example, each
  expression is short, so we do not use curly brackets. If you want multiple
  lines of code in a match arm, you must use curly brackets and the comma
  following the arm is then optional.

  ```rs
  fn value_in_cents(coin: Coin) -> u8 {
      match coin {
          Coin::Penny => {
              println!("Lucky penny!");
              1
          }
          Coin::Nickel => 5,
          Coin::Dime => 10,
          Coin::Quarter => 25,
      }
  }
  ```

- Patterns can bind to the parts of the values that match the pattern.

  ```rs
  #[derive(Debug)]  // so we can inspect the state in a minute
  enum UsState {
      Alabama,
      Alaska,
      // --snip--
  }

  enum Coin {
      Penny,
      Nickel,
      Dime,
      Quarter(UsState),
  }

  fn value_in_cents(coin: Coin) -> u8 {
      match coin {
          Coin::Penny => 1,
          Coin::Nickel => 5,
          Coin::Dime => 10,
          Coin::Quarter(state) => {
              println!("State quarter from {state:?}!");
              25
          }
      }
  }
  ```

- You can see how this would be useful for pulling the value out of an `Option`.

  ```rs
  fn plus_one(x: Option<i32>) -> Option<i32> {
      match x {
          None => None,
          Some(i) => Some(i + 1),
      }
  }

  let five = Some(5);
  let six = plus_one(five);
  let none = plus_one(None);
  ```

- Matches in Rust are *exhaustive*. The arms of a `match` must cover all
  possibilities. A `match` that only handles the `Some` case will not compile.
  If you don't care about some values, you can use a catch-all pattern:

  ```rs
  let dice_roll = 9;
  match dice_roll {
      3 => add_fancy_hat(),
      7 => remove_fancy_hat(),
      other => move_player(other), // matches all other values of `u8`
  }

  fn add_fancy_hat() {}
  fn remove_fancy_hat() {}
  fn move_player(num_spaces: u8) {}
  ```

- If we want the catch-all without binding a value, use `_`.
- If you do not want to do anything in an arm, you can use the `()` expression.
- If an enum contains non-copyable data like a String, then you should be
  careful with whether a match will move or borrow that data. A match on an
  `Option<String>` will move non-ignored fields. The idiomatic solution is to
  match on a reference.

  ```rs
  let opt: Option<String> =
      Some(String::from("Hello world"));  // opt        [init]   +R  . +O
                                          // opt@Some.0 [init]   +R  . +O
  match &opt {                            // opt        [needs]   R
                                          // opt        [borrow]  R  . -O
                                          // opt@Some.0 [borrow]  R  . -O
      Some(s) => println!("Some: {}", s), // s          [init]   +R  . +O
                                          // s          [needs]   R
                                          // s          [end]    -R  . -O
                                          // opt        [regain]  R  . +O
                                          // opt@Some.0 [regain]  R  . +O
      None => println!("None!"),          // opt        [regain]  R  . +O
                                          // opt@Some.0 [regain]  R  . +O
  };
  println!("{:?}", opt);                  // opt        [needs]   R
                                          // opt        [end]    -R  . -O
                                          // opt@Some.0 [end]    -R  . -O
  ```

- If we had done the above without the reference, `Some(s)` would have moved
  the `String` out of `opt` into `s`, and the `println!` wouldn't compile:
  ``error[E0382]: borrow of partially moved value: `opt` ``.
  Rust will "push down" the reference from the outer enum, `&Option<String>`,
  to the inner field, `&String`. Therefore `s` has type `&String` and `opt`
  can be used after the match.

### 6.3 - Concise Control Flow with if let and let...else

- `if let` syntax lets you combine `if` and `let` into a less verbose way to
  handle values that match one pattern while ignoring the rest.

  ```rs
  let config_max = Some(3u8);
  match config_max {
      Some(max) => println!("The maximum is configured to be {max}"),
      _ => (),
  }

  // This is equivalent to above
  let config_max = Some(3u8);
  if let Some(max) = config_max {
      println!("The maximum is configured to be {max}");
  }
  ```

- You can also include an `else` with an `if let`, and the block of code
  associated with `else` is the same as a block of code associated with the `_`.

  ```rs
  let mut count = 0;
  match coin {
      Coin::Quarter(state) => println!("State quarter from {state:?}!"),
      _ => count += 1,
  }

  // equivalently
  let mut count = 0;
  if let Coin::Quarter(state) = coin {
      println!("State quarter from {state:?}!");
  } else {
      count += 1;
  }
  ```

- `let...else` lets us bind values from a pattern if it matches, and execute
  an early-exit `else` block if it does not. `let...else` takes a pattern on the
  left side and an expression on the right, but it does not have an `if` branch,
  only an `else`. If the pattern matches, it will bind the value from the
  pattern, but if it does not match it will follow the `else` arm, which must
  diverge (usually by returning from the function):

  ```rs
  fn describe_state_quarter(coin: Coin) -> Option<String> {
      let Coin::Quarter(state) = coin else {
          return None;
      };

      if state.existed_in(1900) {
          Some(format!("{state:?} is pretty old, for America!"))
      } else {
          Some(format!("{state:?} is relatively new."))
      }
  }
  ```

- Using custom types defined by `enum` or `struct` ensures type safety: The
  compiler will make certain your functions only get values of the type each
  function expects.

## Chapter 7 - Packages, Crates, and Modules

- As a project grows, you should organize code by splitting it into multiple
  modules and then multiple files. As a package grows, you can extract parts
  into separate crates that become external dependencies.
- A package can contain multiple binary crates and optionally one library crate.
  For very large projects comprising a set of interrelated packages that evolve
  together, Cargo provides workspaces which will be covered in Chapter 14.
- Features for managing your code's organization, collectively referred to as
  the *module system*, include:
  - **Packages**: A Cargo feature that lets you build, test, and share crates
  - **Crates**: A tree of modules that produces a library or executable
  - **Modules and use**: Let you control the organization, scope, and privacy
    of paths
  - **Paths**: A way of naming an item, such as a struct, function, or module

### 7.1 - Packages and Crates

- A *crate* is the smallest amount of code that the Rust compiler considers at
  a time. Crates can contain modules, and the modules may be defined in other
  files that get compiled with the crate. A crate can come in two forms: a
  binary crate or a library crate. *Binary crates* are programs you can compile
  to an executable that you can run. Each must have a function called `main`
  that defines what happens when the executable runs. *Library crates* don't
  have a `main` function and don't compile to an executable. Instead they define
  functionality intended to be shared with multiple projects. Most of the time
  when Rustaceans say "crate," they mean library crate, and they use "crate"
  interchangeably with the general programming concept of "library".
- The *crate root* is a source file that the Rust compiler starts from and makes
  up the root module of your crate.
- A *package* is a bundle of one or more crates that provides a set of
  functionality. A package contains a *Cargo.toml* file that describes how to
  build those crates. A package can contain as many binary crates as you like,
  but at most only one library crate. A package must contain at least one crate.
- When you run `cargo new my-project`, Cargo creates a `my-project` directory
  and in it a *Cargo.toml* and *src/main.rs*. *Cargo.toml* doesn't mention the
  source file. Cargo follows the convention that *src/main.rs* is the crate root
  of a binary crate with the same name as the package. Likewise, Cargo knows
  that if the package directory contains *src/lib.rs*, the package contains a
  library crate with the same name as the package and *src/lib.rs* is the crate
  root. Cargo passes crate root files to `rustc` to build the library or
  binary. This default new project is a binary crate named `my-project`. If a
  package contains both *src/main.rs* and *src/lib.rs*, it has two crates: a
  binary and a library, both with the same name as the package. A package can
  have multiple binary crates by placing files in the *src/bin* directory: each
  file will be a separate binary crate.

### 7.2 - Control Scope and Privacy with Modules

- **Start from the crate root**: When compiling a crate, the compiler first
  looks in the crate root file (usually *src/lib.rs* for a library crate and
  *src/main.rs* for a binary crate) for code to compile.
- **Declaring modules**: In the crate root file, you can declare new modules,
  say for example "garden", with `mod garden;`. The compiler will look for the
  module's code in:
  - Inline, within curly brackets that replace the semicolon following
    `mod garden`.
  - In the file *src/garden.rs*
  - In the file *src/garden/mod.rs*
- **Declaring submodules**: In any file other than the crate root, you can
  declare submodules. For example, you might declare `mod vegetables;` in
  *src/garden.rs*. The compiler will look for the submodule's code within the
  directory name for the parent module in these places:
  - Inline, directly following `mod vegetables`, within curly brackets instead
    of the semicolon
  - In the file *src/garden/vegetables.rs*
  - In the file *src/garden/vegetables/mod.rs*
- **Paths to code in modules**: Once a module is part of your crate, you can
  refer to code in that module from anywhere else in that same crate, as long as
  the privacy rules allow, using the path to the code. For example, an
  `Asparagus` type in the garden vegetables module would be found at
  `crate::garden::vegetables::Asparagus`.
- **Private vs public**: Code within a module is private from its parent modules
  by default. To make a module public, declare it with `pub mod` instead of
  `mod`. To make items within a public module public as well, use `pub` before
  their declarations.
- **The `use` keyword**: Within a scope, the `use` keyword creates shortcuts to
  items to reduce repetition of long paths. In any scope that can refer to
  `crate::garden::vegetables::Asparagus`, you can create a shortcut with
  `use crate::garden::vegetables::Asparagus`, and from then on you only need to
  write `Asparagus` to make use of that type in the scope.
- *Modules* let us organize code within a crate for readability and easy reuse.
  Modules also allow us to control the *privacy* of items because code within
  a module is private by default.
- The source code provides an extended example of a `restaurant` library in
  `ch07_restaurant`.
- The contents of either *src/main.rs* or *src/lib.rs* are *crate roots* and the
  contents of either of these two files form a module named `crate` at the root
  of the crate's module structure, known as the *module tree*.

### 7.3 - Paths for Referring to an Item in the Module Tree

- An *absolute path* is the full path starting from a crate root; for code from
  an external crate, the absolute path begins with the crate name, and for code
  from the current crate, it starts with the literal `crate`.
- A *relative path* starts from the current module and uses `self`, `super`, or
  an identifier in the current module.
- Both absolute and relative paths are followed by one or more identifiers
  separated by double colons (`::`).
- Using absolute vs relative path comes down to if you're more likely to move
  item definition code separately from or together with the code that uses an
  item. The preference in general is to specify absolute paths because it's more
  likely we'll want to move code definitions and item calls independently.
- In Rust if you want to make an item private, you put it in a module. By
  default all items are private even to parent modules. However, items in
  child modules can use the items in their ancestor modules. Sibling modules
  are accessible, but only their `pub` items are visible to siblings. A private
  item is visible in the module where it's defined and all of that module's
  descendants.
- Modules are containers so making a module public doesn't do much on its own
  without making items within it public as well.
- Typically a crate with a binary and a library will have just enough code in
  the binary to start an executable that calls code defined in the library. The
  library can be shared, so other projects benefit from most of the
  functionality that the package provides. The module tree should be defined
  in *src/lib.rs*. Then, any public items can be used in the binary crate by
  starting paths from the name of the package. The binary crate becomes a user
  of the library crate just like a completely external crate would use the
  library crate: It can only use the public API.
- We can construct relative paths that begin in the parent module, rather than
  the current module or crate root, by using `super` at the start of the path.
  This makes rearranging the module tree easier when the module is closely
  related to the parent but the parent might be moved elsewhere.
- If we have a struct with a private field, the struct needs to provide a
  public associated function that constructs an instance or we can't create
  an instance of the struct outside the module since we couldn't set the value
  of the private field. If we make an enum public, all its variants are public.

### 7.4 - Bringing Paths into Scope with the `use` Keyword

- We can create a shortcut to a path with the `use` keyword once and then use
  the shorter name everywhere else in scope. `use` commands only create
  shortcuts for the particular scope in which the `use` occurs. Submodules have
  separate scopes and won't see `use` declared in a parent module without
  calling `super::`.
- The idiomatic way to bring a function into scope is to bring the function's
  parent module into scope with `use`. This makes it clear the function isn't
  locally defined (since calls to it are preceded with the parent module name)
  while still minimizing repetition of the full path. It is idiomatic to
  specify the full path for structs, enums, and other items with `use`.

  ```rs
  use std::collections::HashMap;

  fn main() {
      let mut map = HashMap::new();
      map.insert(1, 2);
  }
  ```

- Bringing two items with the same name into the same scope requires using
  their parent modules or else use the `as` keyword. `as` lets you specify
  a new local name, or *alias*, for the type.
- *Re-exporting* is combining `pub` and `use` so that we bring the item into our
  scope but also make that item available for others to bring into their scope.
  It is useful when the internal structure of your code is different from how
  programmers calling your code would think about the domain.
- To use an external package we put the library and version in our *Cargo.toml*
  then `use` the items we want to bring into scope, or prefix them with the
  package name and `::`. We don't have to specify `std` in our *Cargo.toml*,
  but we do need to `use` items from there to bring them into scope. For
  example, `use std::collections::HashMap` allows you to refer to `HashMap`.
- We can `use` two or more items in the same path by specifying the shared
  portion of the path followed by `::{item1, item2}`. For example,
  `use std::{cmp::Ordering, io}`. We can `use std::io::{self, Write}` to bring
  both `std::io` and `std::io::Write` into scope.
- If we want to bring all public items defined in `std::collections` into scope,
  we use the glob operator (`*`) like `use std::collections::*`. It is often
  used when testing to bring everything under test into the `tests` module.
- Here's the full code of the project before splitting it into different files:

  ```rs
  // ch07_restaurant/src/lib.rs
  mod front_of_house {
      pub mod hosting {
          pub fn add_to_waitlist() {}
          fn seat_at_table() {}
      }

      mod serving {
          fn take_order() {}
          fn serve_order() {}
          fn take_payment() {}
      }
  }

  mod back_of_house {
      pub struct Breakfast {
          pub toast: String,
          seasonal_fruit: String,
      }

      impl Breakfast {
          pub fn summer(toast: &str) -> Breakfast {
              Breakfast {
                  toast: String::from(toast),
                  seasonal_fruit: String::from("peaches"),
              }
          }
      }

      pub enum Appetizer {
          Soup,
          Salad,
      }

      fn fix_incorrect_order() {
          cook_order();
          super::deliver_order();
      }

      fn cook_order() {}
  }

  pub use crate::front_of_house::hosting;

  pub fn eat_at_restaurant() {
      // Absolute path
      crate::front_of_house::hosting::add_to_waitlist();

      // Relative path
      front_of_house::hosting::add_to_waitlist();

      // Order a breakfast in the summer with Rye toast.
      let mut meal = back_of_house::Breakfast::summer("Rye");
      // Change our mind about what bread we'd like
      meal.toast = String::from("wheat");
      println!("I'd like {} toast please", meal.toast);

      // The next line won't compile if we uncomment it; we're not allowed
      // to see or modify the seasonal fruit that comes with the meal.
      // meal.seasonal_fruit = String::from("blueberries");

      let order1 = back_of_house::Appetizer::Soup;
      let order2 = back_of_house::Appetizer::Salad;

      // Because of earlier `use` command this works
      hosting::add_to_waitlist();
  }

  fn deliver_order() {}
  ```

### 7.5 - Separating Modules into Different Files

- The book shows moving `front_of_house` to *src/front_of_house.rs*. It also
  moves its child `front_of_house::hosting` to *src/front_of_house/hosting.rs*.
  I have made these changes to the code in `ch07_restaurant` and it compiles.
  There is an older style still supported where `front_of_house` goes within
  *src/front_of_house/mod.rs* and `hosting` goes in
  *src/front_of_house/hosting/mod.rs*. The main drawback of the old style is
  having many open files named `mod.rs`.
- You only need to load a file using a `mod` declaration *once* in your module
  tree. Other files refer to it using a path to where it was declared.
- Not covered in the book: there are more visibility levels than private and
  `pub`. `pub(crate)` is the common one, for sharing an item between modules
  without making it part of the crate's public API:

  | Visibility                  | Visible to                            |
  | --------------------------- | ------------------------------------- |
  | (none)                      | This module and its child modules     |
  | `pub(super)`                | Also the parent module                |
  | `pub(crate)`                | The whole crate, but not other crates |
  | `pub(in crate::some::path)` | Everything under that module          |
  | `pub`                       | Everyone, including other crates      |

## Chapter 8 - Common Collections

- Collections can contain multiple values and, unlike the built-in array and
  tuple types, the data is stored on the heap so the amount does not need to be
  known at compile time and can grow or shrink as the program runs. We will
  discuss three collections in this chapter:
  - A *vector* allows you to store a variable number of values next to each
    other.
  - A *string* is a collection of characters.
  - A *hash map* allows you to associate a value with a specific key. It's a
    particular implementation of the more general data structure called a *map*.

### 8.1 - Storing Lists of Values with Vectors

- Vectors (`Vec<T>`) are useful when you have a list of items of the same type.
- To create a new, empty vector call `Vec::new`. For example,
  `let v: Vec<i32> = Vec::new();`. Because we aren't inserting values right
  away, Rust needs the type annotation here. More often, you'll create a
  `Vec<T>` with initial values and Rust will infer the type. Rust provides the
  `vec!` macro to create a new vector that holds the values it is given. For
  example, `let v = vec![1, 2, 3];`. Rust will infer the type to be `Vec<i32>`.
- As with any variable, if we want to be able to change a vector, we need to
  make it mutable using the `mut` keyword: `let mut v = Vec::new();`. You can
  add new values to a mutable vector with the `push` method. If we push `i32`
  values after declaring the new vector, we don't need the type annotation where
  it is declared.
- You can access values by indexing like `let third: &i32 = &v[2];` or as an
  option from using get like `let third: Option<&i32> = v.get(2);`. Indexing
  outside of range will cause a panic, but using `get` outside of range returns
  `None`.
- Recall that you can't have a mutable reference while an immutable reference
  is still in use.

  ```rs
  // DOES NOT COMPILE! error[E0502]: cannot borrow `v` as mutable because it is
  //                                 also borrowed as immutable
  let mut v = vec![1, 2, 3, 4, 5];
  let first = &v[0];
  v.push(6);
  println!("The first element is: {first}");
  ```

- To access each element in a vector in turn, we can use a `for` loop to get
  immutable references to each element:

  ```rs
  let v = vec![100, 32, 57];
  for i in &v {
      println!("{i}");
  }
  ```

- We can also iterate over mutable references of a mutable vector in order to
  make changes to all the elements. To get the value in `i` and add 1 to it, we
  need to dereference `i` with `*`:

  ```rs
  let mut v = vec![100, 32, 57];
  for i in &mut v {
      *i += 50;
  }
  ```

- An iterator is a pointer that moves through each element of a vector. Each
  call to `next` returns `Some` with the current element and advances the
  pointer, or returns `None` at the end. Rust does not allow you to add or
  remove elements from a vector during iteration. A `push` operation could cause
  reallocation and invalidate the pointer. You can iterate over the range of
  indexes into a vector without using a pointer to the vector.
- The variants of an `enum` are the same type, so different variants can be in
  the same vector:

  ```rs
  enum SpreadsheetCell {
      Int(i32),
      Float(f64),
      Text(String),
  }

  let row = vec![
      SpreadsheetCell::Int(3),
      SpreadsheetCell::Text(String::from("blue")),
      SpreadsheetCell::Float(10.12),
  ];
  ```

- Vector has many methods and is documented at:
  <https://doc.rust-lang.org/std/vec/struct.Vec.html>. In addition to `push`
  which adds to the end, there is `pop` that returns an `Option` containing the
  final element and removes it.

  ```rs
  let mut stack = Vec::new();
  stack.push(1);
  stack.push(2);
  stack.push(3);
  while let Some(top) = stack.pop() {
      // Prints 3, 2, 1
      println!("{top}");
  }
  ```

- When a vector is dropped, all of its contents are also dropped. The borrow
  checker ensures that any reference to contents of a vector is only used
  while the vector itself is valid.

  ```rs
  {
      let v = vec![1, 2, 3, 4];
      // do stuff with v
  } // <- v goes out of scope and is freed here
  ```

- `&[T]` works like `&str` for any list of elements: functions take a slice
  and can then accept a `Vec`, an array, or part of either. A `&Vec<T>` is
  converted to `&[T]` automatically, and slice syntax works on vectors too.

  ```rs
  fn sum(list: &[i32]) -> i32 {
      let mut total = 0;
      for n in list {
          total += n;
      }
      total
  }

  let v = vec![1, 2, 3, 4, 5];
  let a = [10, 20, 30];
  sum(&v);       // 15, &Vec<i32> becomes &[i32]
  sum(&a);       // 60, arrays work too
  sum(&v[1..3]); // 5, a slice of the Vec: [2, 3]
  ```

### 8.2 - Storing UTF-8 Encoded Text with Strings

- Strings are implemented as a collection of bytes, plus some methods to provide
  useful functionality when those bytes are interpreted as text. Rust has only
  one string type in the core language, the string slice `str` most commonly
  seen in its borrowed form `&str`. The `String` type is part of the standard
  library and is a growable, mutable, owned, UTF-8 encoded string type. `String`
  is actually implemented as a wrapper around a vector of bytes with some extra
  guarantees, restrictions, and capabilities.
- `new` works the same as with `Vec`. `let mut s = String::new()` creates a new,
  empty string called `s`. Often we have some data to start from, so we use the
  `to_string` method, which is available on any type that implements the
  `Display` trait including string literals.

  ```rs
  let data = "initial contents";
  let s = data.to_string();
  // The method also works on a literal directly:
  let s = "initial contents".to_string();
  // This is also equivalent
  let s = String::from("initial contents");
  ```

- You can append to a string with `push_str`. You can use the `+` operator
  and `format!` macro to also concatenate string values. `push` adds a single
  character to a string.

  ```rs
  let mut s1 = String::from("foo");
  let s2 = "bar";
  s1.push_str(s2); // s1 = "foobar"
  println!("s2 is {s2}"); // "s2 is bar", push_str did not take ownership of s2

  let s1 = String::from("Hello, ");
  let s2 = String::from("world!");
  let s3 = s1 + &s2; // s1 has been moved here and can no longer be used
  // s3 = "Hello, world!"
  // `+` uses the `add` method: fn add(self, s: &str) -> String {

  // `format!` is useful for combining strings in more complicated ways
  let s1 = String::from("tic");
  let s2 = String::from("tac");
  let s3 = String::from("toe");
  let s = format!("{s1}-{s2}-{s3}");
  ```

- `add` takes a string slice, but we passed `&s2`, a `&String`. The compiler
  coerces the `&String` argument into a `&str`. `add` takes ownership of its
  first argument since it is `self` and not `&self`. `format!` works like
  `println!` but returns a `String` with the contents rather than printing
  output. The code generated by `format!` uses references so doesn't take
  ownership of any of its parameters.
- You cannot use indexing syntax to access individual characters of a string in
  Rust. `String` is a wrapper over `Vec<u8>`, and some characters are
  multi-byte. You can create a slice with the indexing syntax, like
  `let s = &hello[0..4]` for the first four bytes of a string. You will get a
  panic at runtime if you try to cut across a char boundary, so be careful doing
  this in code.
- Be explicit about whether you want characters or bytes when working with
  strings. The `chars` method lets you iterate across each character and the
  `bytes` method lets you iterate across each byte, and `char_indices` returns
  a pair of `(byte_index, char)`:

  ```rs
  for c in "Зд".chars() {
      println!("{c}");
  }

  for b in "Зд".bytes() {
      println!("{b}");
  }

  for (i, c) in "Зд".char_indices() {
      println!("{i}: {c}"); // i is always a valid slice boundary
  }
  ```

- The `str` page is at <https://doc.rust-lang.org/std/primitive.str.html>.
  Here are the methods you'll use most, all of which work on `&str` and
  therefore on `String` too:

  ```rs
  let s = String::from("Hello, world");

  // searching (return bool or Option<usize> byte index)
  s.contains("world");            // true
  s.starts_with("Hello");         // true
  s.ends_with('d');               // true (char or &str patterns)
  s.find("o");                    // Some(4)
  s.rfind('o');                   // Some(8)

  // transforming (return a new String)
  s.replace("world", "Rust");     // "Hello, Rust"
  s.replacen('l', "L", 2);        // "HeLLo, world"
  s.to_uppercase();               // "HELLO, WORLD"
  s.to_lowercase();               // "hello, world"
  "ab".repeat(3);                 // "ababab"

  // trimming and splitting (return &str slices, no allocation)
  "  hi  ".trim();                // "hi" (also trim_start, trim_end)
  s.split(", ");                  // iterator: "Hello", "world"
  "a b  c".split_whitespace();    // iterator: "a", "b", "c"
  "a\nb".lines();                 // iterator: "a", "b"
  s.split_once(", ");             // Some(("Hello", "world"))
  s.strip_prefix("Hello, ");      // Some("world")

  // building and modifying (String only, needs `mut`)
  let mut t = String::new();
  t.push_str("foo");              // "foo"
  t.push('!');                    // "foo!"
  t.insert(0, '>');               // ">foo!"
  t.pop();                        // Some('!'), t is ">foo"
  t.clear();                      // ""
  ```

- **Methods that return pieces of the string** (`trim`, `split`, `strip_prefix`)
  return `&str` slices pointing into the original, so they're cheap.
- **Methods that change the text** (`replace`, `to_uppercase`) have to allocate
  and return a new `String`.
- **Searches give byte positions.** `find` returns a byte index, not a character
  index. That fits the UTF-8 discussion above, and it means you can pass the
  result straight to `&s[i..]`.
- **Splitting returns iterators,** so you'll usually end with
  `.collect::<Vec<_>>()` or loop over the result with `for`. Chapter 13
  explains iterators properly.

### 8.3 - Storing Keys with Associated Values in Hash Maps

- A `HashMap<K, V>` is a mapping of keys of type `K` to values of type `V`. Like
  vectors, hash maps are homogeneous: All of the keys must have the same type,
  and all of the values must have the same type.
- You can use `new` and then add elements with `insert`. The `get` method allows
  you to get values back out:

  ```rs
  use std::collections::HashMap;
  let mut scores = HashMap::new();
  scores.insert(String::from("Blue"), 10);
  scores.insert(String::from("Yellow"), 50);
  let team_name = String::from("Blue");
  let score = scores.get(&team_name).copied().unwrap_or(0); // score = 10
  for (key, value) in &scores {
      println!("{key}: {value}");
  }

  // You can also build a HashMap from an array of pairs with HashMap::from
  let scores = HashMap::from([
      ("Blue", 10),
      ("Yellow", 50),
  ]);
  ```

- `get` returns an `Option<&V>` so here `copied` is converting it from
  `Option<&i32>` to `Option<i32>` then `unwrap_or` is extracting the `i32` value
  or else returning a 0 for `None`.
- For types that implement the `Copy` trait, the values are copied into the hash
  map. For owned values, the values will be moved and the hash map will be the
  owner of those values. If we insert references to values into the hash map,
  the values won't be moved into the hash map. The values the references point
  to need to be valid for at least as long as the hash map is valid.

  ```rs
  use std::collections::HashMap;
  let field_name = String::from("Favorite color");
  let field_value = String::from("Blue");
  let mut map = HashMap::new();
  map.insert(field_name, field_value);
  // field_name and field_value are now invalid!
  ```

- Keys are unique, so there are several ways to deal with a key already existing
  in a hash map. Either you overwrite the old value, keep the old value, or
  combine the old and new value. `insert` overwrites old values with new.
  `entry` is used to check if a key exists and only insert if not. `or_insert`
  returns a mutable reference to a value for a key if it exists or else inserts
  the new key/value pair and returns a mutable reference to the new value.
  The mutable reference is useful if you want to update the value.

  ```rs
  use std::collections::HashMap;
  let mut scores = HashMap::new();
  scores.insert(String::from("Blue"), 10);
  scores.insert(String::from("Blue"), 50);
  println!("{scores:?}"); // {"Blue": 50}

  let mut scores = HashMap::new();
  scores.insert(String::from("Blue"), 10);
  scores.entry(String::from("Yellow")).or_insert(50);
  scores.entry(String::from("Blue")).or_insert(50);
  println!("{scores:?}"); // {"Yellow": 50, "Blue": 10}

  let text = "hello world wonderful world";
  let mut map = HashMap::new();
  for word in text.split_whitespace() {
      // `count` is a &mut i32 into the map; while it's in use the map is
      // mutably borrowed, but the borrow ends after its last use (*count += 1)
      let count = map.entry(word).or_insert(0);
      *count += 1;
  }
  println!("{map:?}"); // {"world": 2, "hello": 1, "wonderful": 1}

  // Inside the loop, you could just update the map directly
  *map.entry(word).or_insert(0) += 1;

  counts.entry(word).or_default(); // uses the type's default: 0, "", empty Vec
  // the following computes the default only if needed
  counts.entry(word).or_insert_with(|| expensive());
  counts.entry(word)
      .and_modify(|c| *c += 1)              // runs only if the key exists
      .or_insert(1);                        // runs only if it doesn't

  // You can also iterate over a HashMap, `key` and `value` are references.
  // Using `for (&key, &value) in &counts` matches and copies the values so you
  // don't have to dereference them inside the loop body.
  for (key, value) in &counts {
      println!("{key}: {value}");
  }

  // `entry` is also useful for grouping
  let words = ["apple", "avocado", "banana", "blueberry", "cherry"];
  let mut by_letter: HashMap<char, Vec<&str>> = HashMap::new();
  for w in words {
      by_letter.entry(w.chars().next().unwrap())
          .or_insert_with(Vec::new)   // only builds the Vec if the key is new
          .push(w);
  }
  // {'a': ["apple", "avocado"], 'b': ["banana", "blueberry"], 'c': ["cherry"]}
  ```

- `or_insert_with(Vec::new)` is better than `or_insert(Vec::new())` because the
  second version builds a `Vec` every time, even when the key already exists,
  and then throws it away. `or_default()` is the shortest form when the type’s
  default value is what you want.
- `BTreeMap` is also in `std::collections`. It's a map that keeps its keys
  sorted (a B-tree, not a hash map).
- The default hashing function provides resistance against denial of service
  attacks at the cost of performance. There are other hashing algorithms
  available or you could write your own.
- Exercises
  - Given a list of integers, use a vector and return the median (when sorted,
    the value in the middle position) and mode (the value that occurs most
    often; a hash map will be helpful here) of the list.

    ```rs
    // ch08_collections/src/main.rs
    use std::collections::HashMap;

    fn main() {
        let v = vec![1, 2, 3, 4, 5, 5, 5];
        println!(
            "The median is {}",
            median(&v).expect("No median of an empty list!")
        );
        println!(
            "The mode is {}",
            mode(&v).expect("No mode of an empty list!")
        );
    }

    fn median(v: &[i32]) -> Option<f64> {
        if v.is_empty() {
            return None;
        }
        let mut v = v.to_vec();
        v.sort();
        let l = v.len();
        if l.is_multiple_of(2) {
            Some((v[l / 2 - 1] as f64 + v[l / 2] as f64) / 2.0)
        } else {
            Some(v[l / 2] as f64)
        }
    }

    fn mode(v: &[i32]) -> Option<i32> {
        if v.is_empty() {
            return None;
        }
        let mut counts = HashMap::new();
        for &item in v {
            *counts.entry(item).or_insert(0) += 1;
        }
        let mut mode = v[0];
        let mut mode_count = 0;
        for (&item, &count) in &counts {
            if count > mode_count || (count == mode_count && item < mode) {
                mode_count = count;
                mode = item;
            }
        }
        Some(mode)
    }
    ```
  - Convert strings to Pig Latin. The first consonant of each word is moved
    to the end of the word and ay is added, so first becomes irst-fay. Words
    that start with a vowel have hay added to the end instead (apple becomes
    apple-hay). Keep in mind the details about UTF-8 encoding!
    - Here's my long-winded version:

      ```rs
      // ch08_collections/src/bin/pig_latin.rs
      fn main() {
          let sample_string =
          String::from("This is a test of the pig latin system!");
          println!("{}", pig_latinize(&sample_string));
      }

      fn pig_latinize(s: &str) -> String {
          let mut new_words = Vec::new();
          let mut word_count = 0;
          let l = s.split_whitespace().count();
          for word in s.split_whitespace() {
              let mut new_word = String::new();
              let mut first_letter = ' ';
              let mut punctuation = ' ';
              word_count += 1;
              for (i, c) in word.to_lowercase().chars().enumerate() {
                  if i == 0 {
                      first_letter = c;
                  } else {
                      if !c.is_ascii_punctuation() {
                          new_word.push(c);
                      } else {
                          punctuation = c;
                      }
                      if i == word.chars().count() - 1 {
                          new_word.push('-');
                          new_word.push(first_letter);
                          new_word.push_str("ay");
                          if word_count == l && punctuation != ' ' {
                              new_word.push(punctuation);
                          }
                      }
                  }
                  if "aeiouAEIOU".contains(first_letter) {
                      new_word.push_str(word);
                      new_word.push_str("-hay");
                      break;
                  }
              }
              new_words.push(new_word);
          }
          capitalize_first(&new_words.join(" "))
      }

      fn capitalize_first(s: &str) -> String {
          let mut new_string = String::new();
          for (i, c) in s.char_indices() {
              if i == 0 {
                  new_string.push(c.to_ascii_uppercase());
              } else {
                  new_string.push(c);
              }
          }
          new_string
      }
      ```

    - Here's AI's shorter version using iterators:

      ```rs
      fn pig_latin_word(word: &str) -> String {
          let Some(first) = word.chars().next() else {
              return String::new();
          };
          let rest = &word[first.len_utf8()..];
          if "aeiouAEIOU".contains(first) {
              format!("{word}-hay")
          } else {
              format!("{rest}-{first}ay")
          }
      }

      fn pig_latinize(s: &str) -> String {
          let mut new_words = Vec::new();
          for word in s.split_whitespace() {
              new_words.push(pig_latin_word(word));
          }
          new_words.join(" ")
      }
      ```
    - And here's a version of `pig_latin_word` that uses match-guards:

      ```rs
      fn pig_latin_word(word: &str) -> String {
          let mut first = None;
          let mut rest = String::new();
          for c in word.to_lowercase().chars() {
              if first.is_none() {
                  first = Some(c);
              } else {
                  rest.push(c);
              }
          }
          match first {
              None => String::new(),
              Some(f) if "aeiou".contains(f) => format!("{f}{rest}-hay"),
              Some(f) if rest.is_empty() => format!("{f}ay"),   // "b" -> "bay"
              Some(f) => format!("{rest}-{f}ay"),
          }
      }
      ```
  - Using a hash map and vectors, create a text interface to allow a user to
    add employee names to a department in a company; for example, “Add Sally
    to Engineering” or “Add Amir to Sales.” Then, let the user retrieve a
    list of all people in a department or all people in the company by
    department, sorted alphabetically.

    ```rs
    use std::collections::HashMap;
    use std::io;

    fn main() {
        let mut company: HashMap<String, Vec<String>> = HashMap::new();

        println!("Commands: Add <name> to <department>, List <department>,");
        println!("          List all, Quit");

        loop {
            let mut input = String::new();
            io::stdin()
                .read_line(&mut input)
                .expect("Failed to read line");

            let mut words = Vec::new();
            for word in input.split_whitespace() {
                words.push(word);
            }

            if words.is_empty() || words[0] == "Quit" {
                break;
            } else if words[0] == "Add" && words.len() >= 4 && words[2] == "to" {
                add_employee(&mut company, words[1], &words[3..].join(" "));
            } else if words[0] == "List" && words.len() == 2 && words[1] == "all" {
                list_all(&company);
            } else if words[0] == "List" && words.len() >= 2 {
                list_department(&company, &words[1..].join(" "));
            } else {
                println!("Sorry, I didn't understand that.");
            }
        }
    }

    fn add_employee(
        company: &mut HashMap<String, Vec<String>>,
        name: &str,
        dept: &str,
    ) {
        let people = company.entry(dept.to_string()).or_default();
        people.push(name.to_string());
        println!("Added {name} to {dept}.");
    }

    fn list_department(company: &HashMap<String, Vec<String>>, dept: &str) {
        match company.get(dept) {
            Some(people) => {
                let mut people = people.clone();
                people.sort();
                println!("{dept}:");
                for person in &people {
                    println!("  {person}");
                }
            }
            None => println!("No department named {dept}."),
        }
    }

    fn list_all(company: &HashMap<String, Vec<String>>) {
        let mut depts = Vec::new();
        for dept in company.keys() {
            depts.push(dept);
        }
        depts.sort();
        for dept in depts {
            list_department(company, dept);
        }
    }
    ```

    - You could also use slice-pattern, but that hasn't been covered yet:

      ```rs
      match words.as_slice() {
          ["Add", name, "to", dept @ ..] if !dept.is_empty() => {
              add_employee(&mut company, name, &dept.join(" "));
          }
          ["List", "all"] => list_all(&company),
          ["List", dept @ ..] if !dept.is_empty() => {
              list_department(&company, &dept.join(" "));
          }
          ["Quit"] | [] => break,
          _ => println!("Sorry, I didn't understand that."),
      }
      ```

## Chapter 9 - Error Handling

- Rust groups errors into two major categories: recoverable and unrecoverable
  errors. For a *recoverable error*, such as "file not found", we just want
  to report the error and allow the user to retry the operation. *Unrecoverable
  errors* are always symptoms of bugs, like trying to access a location beyond
  the end of an array, so we want to immediately stop the program. Rust doesn't
  have exceptions, which are the single way many other languages try to deal
  with both types of error. It has `Result<T, E>` for recoverable errors and
  `panic!` for unrecoverable errors.

### 9.1 - Unrecoverable Errors with `panic!`

- You can cause a panic by taking an action that causes a panic or by calling
  the `panic!` macro. By default, a panic prints a failure message, unwinds,
  cleans up the stack, and quits. Via an environment variable, you can have Rust
  display the call stack when a panic occurs.
- Unwinding (walking back up the stack and cleaning up each function's data) is
  a lot of work and makes the binary larger. You can instead abort immediately
  and let the operating system reclaim the memory by adding `panic = 'abort'`
  to the appropriate `[profile]` sections in your *Cargo.toml*.
- You can get a backtrace in the event of a panic by setting `RUST_BACKTRACE=1`.
  The key to reading the backtrace is to start from the top and read until you
  see files you wrote. That's the spot where the problem originated. To get a
  backtrace, debug symbols must be enabled. They are enabled by default when
  building without the `--release` flag.

### 9.2 - Recoverable Errors with `Result`

- The `Result` enum has two variants: `Ok` and `Err`:

  ```rs
  enum Result<T, E> {
      Ok(T),
      Err(E),
  }
  ```

- Consider the function `File::open` from `std::fs::File`. It returns a
  `Result<T, E>` where the `T` is `std::fs::File` which is a file handle on
  success and the `E` is a `std::io::Error`. We can `match` on these variants.
- The `Result` enum and its variants are brought into scope by the prelude.

  ```rs
  use std::fs::File;
  use std::io::ErrorKind;

  fn main() {
      let greeting_file_result = File::open("hello.txt");

      let greeting_file = match greeting_file_result {
          Ok(file) => file,
          Err(error) => match error.kind() {
              ErrorKind::NotFound => match File::create("hello.txt") {
                  Ok(fc) => fc,
                  Err(e) => panic!("Problem creating the file: {e:?}"),
              },
              _ => {
                  panic!("Problem opening the file: {error:?}");
              }
          },
      };
  }
  ```

- `io::Error` is a struct provided by the standard library. It has a method
  `kind` that we can call to get an `io::ErrorKind` value. The enum
  `io::ErrorKind` is also provided by the standard library and has variants
  for the different kinds of errors that might result from an `io` operation.
  Here we are prepared to deal with `NotFound` by creating the file and willing
  to crash for other errors.
- `match` is very useful but also very primitive. `Result` has methods that
  can be more convenient, often using closures which we'll introduce in Chapter
  13. Here is the above rewritten:

  ```rs
  use std::fs::File;
  use std::io::ErrorKind;

  fn main() {
      let greeting_file = File::open("hello.txt").unwrap_or_else(|error| {
          if error.kind() == ErrorKind::NotFound {
              File::create("hello.txt").unwrap_or_else(|error| {
                  panic!("Problem creating the file: {error:?}");
              })
          } else {
              panic!("Problem opening the file: {error:?}");
          }
      });
  }
  ```

- If you don't have any error handling code and just want to panic, the `unwrap`
  and `expect` methods are an easy way to get the value out of the `Result` and
  panic if it's an error. Both return the value inside for an `Ok`, but panic
  for an `Err`, but `expect` allows you to specify a panic message. Most
  Rustaceans prefer `expect` to `unwrap` to give more context about why the
  operation is expected to always succeed.

  ```rs
  use std::fs::File;

  fn main() {
      let greeting_file = File::open("hello.txt")
          .expect("hello.txt should be included in this project");
  }
  ```

- Instead of dealing with the `Err` immediately, we may choose to propagate the
  error to calling code where there might be more context on how to deal with
  the issue. This is a long way to propagate the error; we will see a short way
  later:

  ```rs
  use std::fs::File;
  use std::io::{self, Read};

  fn read_username_from_file() -> Result<String, io::Error> {
      let username_file_result = File::open("hello.txt");

      let mut username_file = match username_file_result {
          Ok(file) => file,
          Err(e) => return Err(e),
      };

      let mut username = String::new();

      match username_file.read_to_string(&mut username) {
          Ok(_) => Ok(username),
          Err(e) => Err(e),
      }
  }
  ```

- This code propagates the error. It returns an `io::Error`, because that is the
  error type of both calls that could fail. On success it returns `Ok` wrapping
  the username. Recall that `return` is unnecessary when you are returning the
  final expression of a function. The calling code may decide to panic, use a
  default username, or look up the username elsewhere, for example. We don't
  know what the calling code is trying to do, so we propagate all the success
  and error information upward for it to handle appropriately.
- The pattern of propagating errors is so common in Rust that Rust provides the
  question mark operator `?` to make this easier. Here is the last example
  rewritten using it:

  ```rs
  use std::fs::File;
  use std::io::{self, Read};

  fn read_username_from_file() -> Result<String, io::Error> {
      let mut username_file = File::open("hello.txt")?;
      let mut username = String::new();
      username_file.read_to_string(&mut username)?;
      Ok(username)
  }
  ```

- In the above code, if the value of the `Result` is `Ok`, the value inside the
  `Ok` will be returned by the `?` expression, but if the value is an `Err`, the
  `Err` will be returned from the whole function as if we had used the `return`
  keyword. There is one difference between this and the longer example. Error
  values that have `?` called on them go through the `from` function defined in
  the `From` trait of the standard library, which converts values from one type
  into another. The error type received is thus converted into the error type
  defined in the return type of the current function. This is useful when a
  function returns one error type to represent all the ways a function might
  fail, even if parts might fail for many different reasons. For example we
  could define `OurError` as the return type and also define
  `impl From<io::Error> for OurError` to construct `OurError` from an
  `io::Error`, and the `?` operator would convert error types.
- We could make this example even shorter by chaining method calls:

  ```rs
  use std::fs::File;
  use std::io::{self, Read};

  fn read_username_from_file() -> Result<String, io::Error> {
      let mut username = String::new();

      File::open("hello.txt")?.read_to_string(&mut username)?;

      Ok(username)
  }
  ```

- And we could make that even shorter by using `fs::read_to_string`, but that
  wouldn't have given a chance to explain `?`:

  ```rs
  use std::fs;
  use std::io;

  fn read_username_from_file() -> Result<String, io::Error> {
      fs::read_to_string("hello.txt")
  }
  ```

- The `?` operator can only be used in functions whose return type is compatible
  with the value the `?` is used on, because it is defined to perform an early
  return of a value out of the function.

  ```rs
  // DOES NOT COMPILE! error[E0277]: the `?` operator can only be used in a
  //                                 function that returns `Result` or `Option`
  use std::fs::File;

  fn main() {
      let greeting_file = File::open("hello.txt")?;
  }
  ```

- You can make `main` return a `Result<(), E>`. If it returns an `Err`, the
  program prints the error and exits with a failure code. Just remember to
  return `Ok(())` at the end. A `Box<dyn Error>` allows `main` to return any
  type of error. `main` may return any types that implement the
  `std::process::Termination` trait which contains a function `report` that
  returns an `ExitCode`. The standard library documentation has more on
  implementing the `Termination` trait for your own types.
- As you can see from the error, `?` can also be used with `Option<T>` values if
  that is what your function returns.

  ```rs
  fn last_char_of_first_line(text: &str) -> Option<char> {
      text.lines().next()?.chars().last()
  }
  ```

- Note you can't mix and match between `Result` and `Option`. You can either use
  `?` on `Result` values in a function that returns `Result`, or you can use `?`
  on `Option` values in a function that returns `Option`. You can use `ok` to
  convert a `Result` to an `Option` or `ok_or` to convert an `Option` to a
  `Result` and then use `?` though.

### 9.3 - To `panic!` or Not to `panic!`

- When you choose to return a `Result`, you are giving the calling code options,
  so `Result` is a good default choice for a function that might fail. In
  examples, prototype code, and tests, it's more appropriate to panic. Often
  examples are obfuscated by too much error handling, prototypes can have
  `expect` and `unwrap` replaced by real error handling later, and panic is
  an expedient way to mark a test as failed. `expect` is also appropriate in
  code you know cannot fail and documenting the reason you think you will never
  get an `Err` variant:

  ```rs
  use std::net::IpAddr;

  let home: IpAddr = "127.0.0.1"
      .parse()
      .expect("Hardcoded IP address should be valid");
  ```

- If the above IP came from user input and did have the possibility of failure,
  we would want to handle it robustly. But we can see that the hardcoded value
  will parse, so we can unwrap the value.
- Panic anytime your code could end up in a bad state. In this context, a *bad
  state* is when some assumption, guarantee, contract, or invariant has been
  broken, such as when invalid values, contradictory values, or missing values
  are passed in to your code - plus one of the following:
  - The bad state is something that is unexpected as opposed to something that
    will likely happen occasionally, such as a user entering data in the wrong
    format.
  - Your code after this point needs to rely on not being in this bad state,
    rather than checking for the problem at every step.
  - There's not a good way to encode this information in the types you use.
- If someone calls your code with values that don't make sense, it is best to
  return an error and let the user decide what they want to do, but if
  continuing could be insecure or harmful, the best choice might be to call
  `panic!` and alert the user to the bug in their code so it can be fixed
  immediately. Similarly, `panic!` can be appropriate if you're calling external
  code that is out of your control and returns an invalid state that you have
  no way of fixing. However, when failure is expected, return `Result` instead
  of calling `panic!`.
- Let's imagine for our chapter 2 guessing game, we wanted to implement a
  `Guess` type that restricts guesses to values between 1 and 100 and otherwise
  panics (which would be documented in our API docs). Imagine we have a
  *src/lib.rs* that declares a `mod guessing_game` where we implement this
  struct in *src/guessing_game.rs*. By being in a module, its `value` field
  would be private and only set through the public `Guess::new` method and only
  accessible through the public `value` method. You could pass this around
  safely knowing you had a value between 1 and 100. Any of our functions relying
  on this value can take or return a `Guess` without having to validate the
  value is within range.

  ```rs
  // imaginary /src/guessing_game.rs
  pub struct Guess {
      value: i32,
  }

  impl Guess {
      pub fn new(value: i32) -> Guess {
          if value < 1 || value > 100 {
              panic!("Guess value must be between 1 and 100, got {value}.");
          }

          Guess { value }
      }

      pub fn value(&self) -> i32 {
          self.value
      }
  }
  ```

## Chapter 10 - Generic Types, Traits, and Lifetimes

- *Generics* are abstract stand-ins for concrete types or other properties. We
  can express the behavior of generics or how they relate to other generics
  without knowing what will be in their place when compiling and running code.
  Generics allow us to replace specific types with a placeholder that represents
  multiple types to remove code duplication.
- First let's talk about extracting a function to remove duplication. Here are
  the steps:
  1. Identify duplicate code.
  2. Extract the duplicate code into the body of the function, and specify the
     inputs and return values of that code in the function signature.
  3. Update the instances of duplicated code to call the function instead.

  ```rs
  fn largest(list: &[i32]) -> &i32 {
      let mut largest = &list[0];

      for item in list {
          if item > largest {
              largest = item;
          }
      }

      largest
  }

  fn main() {
      let number_list = vec![34, 50, 25, 100, 65];

      let result = largest(&number_list);
      println!("The largest number is {result}");

      let number_list = vec![102, 34, 6000, 89, 54, 2, 43, 8];

      let result = largest(&number_list);
      println!("The largest number is {result}");
  }
  ```

- Just like a function body can operate on an abstract `list` instead of
  specific values, generics allow code to operate on abstract types.

### 10.1 - Generic Data Types

- When defining a function that uses generics, we place the generics in the
  signature of the function where we would usually specify the data types of the
  parameters and return value.
- Continuing our `largest` example, imagine you had a function to determine
  the largest `i32` in a list and another to determine the largest `char`.

  ```rs
  fn largest_i32(list: &[i32]) -> &i32 {
      let mut largest = &list[0];

      for item in list {
          if item > largest {
              largest = item;
          }
      }

      largest
  }

  fn largest_char(list: &[char]) -> &char {
      let mut largest = &list[0];

      for item in list {
          if item > largest {
              largest = item;
          }
      }

      largest
  }

  fn main() {
      let number_list = vec![34, 50, 25, 100, 65];

      let result = largest_i32(&number_list);
      println!("The largest number is {result}");

      let char_list = vec!['y', 'm', 'a', 'q'];

      let result = largest_char(&char_list);
      println!("The largest char is {result}");
  }
  ```

- The functions do the same thing but do it to different types. Introducing a
  generic type parameter will allow us to eliminate the duplicate and use a
  single function for both. To parameterize the types we need to name the type
  parameter. You can use any identifier as a type parameter name but by
  convention type parameter names are short, often just one letter, and
  UpperCamelCase. We will simply use `T`, short for type. We have to declare
  the type parameter in the signature before we use it and we do so within
  angle brackets, `<>`, between the name of the function and the parameter list:
  `fn largest<T>(list: &[T]) -> &T {`. We read this definition as "The function
  `largest` is generic over some type `T`". This function has one parameter
  named `list`, which is a slice of values of type `T`. The `largest` function
  will return a reference to a value of the same type `T`. Using it would look
  something like this:

  ```rs
  // DOES NOT COMPILE! error[E0369]: binary operation `>` cannot be applied to
  //                                 the type `&T`
  fn largest<T>(list: &[T]) -> &T {
      let mut largest = &list[0];

      for item in list {
          if item > largest {
              largest = item;
          }
      }

      largest
  }

  fn main() {
      let number_list = vec![34, 50, 25, 100, 65];

      let result = largest(&number_list);
      println!("The largest number is {result}");

      let char_list = vec!['y', 'm', 'a', 'q'];

      let result = largest(&char_list);
      println!("The largest char is {result}");
  }
  ```

- The issue is that when `largest` takes a slice `&[T]` as input, the function
  cannot assume *anything* about the type `T`. It could be `i32` or `String`,
  but it could also be `File`. Can you say one file is greater than another?
  `largest` requires that `T` is something you can compare with `>` (i.e. that
  `T` implements `PartialOrd`, a trait we are about to explain). Some types are
  comparable and others are not. Rust requires you to state the expected
  capabilities of generic types up front. If `T` needs to be comparable, then
  `largest` must say so. Also, unlike Java where every object has a set of core
  methods like `Object.toString()`, there are no core methods in Rust. Without
  restrictions, a generic type `T` has no capabilities: it cannot be printed,
  cloned, or mutated (although it can be dropped). We will come back to how to
  fix this in the next section, but let's see other uses of generics.
- We can define structs to use a generic type parameter in one or more fields
  by using the `<>` syntax. A `Point<T>` can hold `x` and `y` coordinate values
  of any type:

  ```rs
  struct Point<T> {
      x: T,
      y: T,
  }

  fn main() {
      let integer = Point { x: 5, y: 10 };
      let float = Point { x: 1.0, y: 4.0 };
  }
  ```

- Like a function definition, the `<T>` comes just after the name of the struct,
  then you use the generic type in the struct definition where we would
  otherwise specify concrete data type. Because we used only one generic type
  `T` to define `Point<T>`, this definition says that the struct is generic
  over some type `T` and that the fields `x` and `y` are both the same type.
  If you tried to make one `i32` and the other `f64`, you would get a compile
  error: `error[E0308]: mismatched types`:

  ```rs
  // DOES NOT COMPILE! error[E0308]: mismatched types
  struct Point<T> {
      x: T,
      y: T,
  }

  fn main() {
      let wont_work = Point { x: 5, y: 4.0 };
  }
  ```

- However, we could allow `x` and `y` to be different types by using multiple
  generic type parameters:

  ```rs
  struct Point<T, U> {
      x: T,
      y: U,
  }

  fn main() {
      let both_integer = Point { x: 5, y: 10 };
      let both_float = Point { x: 1.0, y: 4.0 };
      let integer_and_float = Point { x: 5, y: 4.0 };
  }
  ```

- You can use as many generic type parameters in a definition as you want, but
  more than a few makes your code hard to read. If you find you need many
  generic types, your code may need restructuring into smaller pieces.
- We have already seen several enums that use generics, so let's review the
  definitions of `Option<T>` and `Result<T, E>`. Because `Option<T>` is generic,
  we can use this abstraction no matter what the type of the optional value is:

  ```rs
  enum Option<T> {
      Some(T),
      None,
  }


  enum Result<T, E> {
      Ok(T),
      Err(E),
  }
  ```

- When you recognize situations in your code with multiple struct or enum
  definitions that differ only in the types of values they hold, you can
  avoid duplication by using generic types instead.
- You can also use generics in method definitions on structs and enums:

  ```rs
  struct Point<T> {
      x: T,
      y: T,
  }

  impl<T> Point<T> {
      fn x(&self) -> &T {
          &self.x
      }
  }

  fn main() {
      let p = Point { x: 5, y: 10 };

      println!("p.x = {}", p.x());
  }
  ```

- Note we specify `<T>` right after the `impl`. You could use a different letter
  than the struct declaration, but it is conventional to use the same name. We
  can also specify constraints on generic types when defining methods on the
  type. For example, we could implement a method only on `Point<f32>`
  instances:

  ```rs
  impl Point<f32> {
      fn distance_from_origin(&self) -> f32 {
          (self.x.powi(2) + self.y.powi(2)).sqrt()
      }
  }
  ```

- You cannot simultaneously implement specific and generic methods of the same
  name this way. For example, if you had a generic `distance_from_origin` for
  all types `T` and a specific `distance_from_origin` for `f32` the compiler
  would reject your program. More generally, Rust does not have inheritance-like
  mechanisms for specializing methods as you might find in an object-oriented
  language, with the one exception of default trait methods discussed in the
  next section.
- Generic type parameters in a struct definition aren't always the same as those
  you use in that same struct's method signatures. Consider the following with
  `X1` and `Y1` in the struct definition and `X2` and `Y2` for the `mixup`
  method signature. The method creates a new `Point` instance with the `x`
  value from the `self` `Point` (of type `X1`) and the `y` value from the
  passed-in `Point` (of type `Y2`).

  ```rs
  struct Point<X1, Y1> {
      x: X1,
      y: Y1,
  }

  impl<X1, Y1> Point<X1, Y1> {
      fn mixup<X2, Y2>(self, other: Point<X2, Y2>) -> Point<X1, Y2> {
          Point {
              x: self.x,
              y: other.y,
          }
      }
  }

  fn main() {
      let p1 = Point { x: 5, y: 10.4 };
      let p2 = Point { x: "Hello", y: 'c' };

      let p3 = p1.mixup(p2);

      println!("p3.x = {}, p3.y = {}", p3.x, p3.y);
  }
  ```

- In the above code, `p3` will have an `x` value of type `i32` and a `y` value
  of type `char`, so the output will be `p3.x = 5, p3.y = c`. In this example,
  `X1` and `Y1` are declared after `impl` because they go with the struct
  definition. `X2` and `Y2` are declared after `fn mixup` because they're only
  relevant to the method.
- Generic types will not make your code run slower than concrete types. Rust
  accomplishes this through monomorphization of the code using generics at
  compile time. *Monomorphization* is the process of turning generic code into
  specific code by filling in the concrete types that are used when compiled.
  An `Option<T>` in the source code becomes a concrete `Option<i32>` or
  `Option<f64>` (or whatever) at compilation based on its types used, so there
  is no performance penalty at runtime as if we had duplicated each definition
  by hand.

### 10.2 - Defining Shared Behavior with Traits

- A *trait* defines the functionality a particular type has and can share with
  other types. We can use traits to define shared behavior in an abstract way.
  We can use *trait bounds* to specify that a generic type can be any type that
  has certain behavior. Traits are similar to a feature often called interfaces
  in other languages, although with some differences.

#### Defining a Trait

- A type's behavior consists of the methods we can call on that type. Different
  types share the same behavior if we can call the same methods on all those
  types. Trait definitions are a way to group method signatures together to
  define a set of behaviors necessary to accomplish some purpose.
- For example, let's say you have a `NewsArticle` struct that holds a news
  story filed in a particular location and a `SocialPost` that can have at most
  280 characters along with metadata. We want to make a media aggregator
  library crate named `aggregator` that can display summaries of both. To do
  this, we need a summary from each type, and we'll request the summary by
  calling a `summarize` method on an instance. The `Summary` definition below
  expresses this behavior:

  ```rs
  pub trait Summary {
      fn summarize(&self) -> String;
  }
  ```

- We declare a trait with the `trait` keyword and then the trait's name which is
  `Summary` in this case. We also declared it `pub` so that crates depending on
  this crate can make use of it. Inside the curly brackets, we declare the
  method signatures that describe the behaviors of the types that implement this
  trait, which in this case is `fn summarize(&self) -> String`. After the method
  signature we use a semicolon instead of providing an implementation. Each type
  implementing this trait must provide its own custom behavior for the body of
  the method. The compiler will enforce that any type that has the `Summary`
  trait will have the method `summarize` defined with this signature exactly.
  A trait can have multiple methods in its body: The method signatures are
  listed one per line, and each line ends in a semicolon.

#### Implementing a Trait on a Type

- Below are the implementations of `summarize` for our `NewsArticle` and
  `SocialPost` structs:

  ```rs
  // imaginary aggregator/src/lib.rs
  pub struct NewsArticle {
      pub headline: String,
      pub location: String,
      pub author: String,
      pub content: String,
  }

  impl Summary for NewsArticle {
      fn summarize(&self) -> String {
          format!("{}, by {} ({})", self.headline, self.author, self.location)
      }
  }

  pub struct SocialPost {
      pub username: String,
      pub content: String,
      pub reply: bool,
      pub repost: bool,
  }

  impl Summary for SocialPost {
      fn summarize(&self) -> String {
          format!("{}: {}", self.username, self.content)
      }
  }
  ```

- Implementing a trait is similar to implementing regular methods. The
  difference is that after `impl` we put the trait name we want to implement
  then use the `for` keyword and specify the name of the type we want to
  implement the trait for. Within the `impl` block, we put the method signatures
  that the trait definition has defined. Instead of the semicolon after each
  signature, we fill in the method body with the specific behavior that we want
  the methods of the trait to have for the particular type.
- Now that the traits are implemented, users of the crate can call the trait
  methods on instances of `NewsArticle` and `SocialPost` like normal methods,
  but first they must bring the trait into scope as well as the types.

  ```rs
  use aggregator::{SocialPost, Summary};

  fn main() {
      let post = SocialPost {
          username: String::from("horse_ebooks"),
          content: String::from(
              "of course, as you probably already know, people",
          ),
          reply: false,
          repost: false,
      };

      println!("1 new post: {}", post.summarize());
  }
  ```

- Other crates that depend on `aggregator` can also bring the `Summary` trait
  into scope to implement `Summary` on their own types. We can implement a
  trait on a type only if either the trait or the type, or both, are local to
  our crate. For example, we can implement standard library traits like
  `Display` on a custom type like `SocialPost` in our `aggregator` crate because
  `SocialPost` is local to our `aggregator` crate. We can also implement
  `Summary` on `Vec<T>` in our `aggregator` crate because the trait `Summary`
  is local to our `aggregator` crate. But we can't implement external traits on
  external types. For example, we can't implement `Display` on `Vec<T>` because
  both are defined in the standard library and not local to our `aggregator`
  crate. This restriction is part of a property called *coherence* and more
  specifically the *orphan rule*, so named because the parent type is not
  present. This rule ensures that other people's code can't break your code and
  vice versa. Without the rule, two crates could implement the same trait for
  the same type and Rust wouldn't know which implementation to use.

#### Using Default Implementations

- Sometimes it is useful to have default behavior for some or all the methods
  in a trait instead of requiring implementations for all methods on every
  type. We can implement a default method body when declaring the trait, and
  those implementing the trait can choose to keep or override the default
  behavior:

  ```rs
  pub trait Summary {
      fn summarize(&self) -> String {
          String::from("(Read more...)")
      }
  }
  ```

- To use a default implementation for `NewsArticle`, we specify an empty `impl`
  block with `impl Summary for NewsArticle {}`. The syntax for overriding the
  default implementation is the same as the syntax for implementing a trait
  without a default implementation, so we don't have to change `SocialPost`.
  Default implementations can call other methods in the same trait, even if
  those other methods don't have a default implementation.

  ```rs
  pub trait Summary {
      fn summarize_author(&self) -> String;

      fn summarize(&self) -> String {
          format!("(Read more from {}...)", self.summarize_author())
      }
  }

  impl Summary for SocialPost {
      fn summarize_author(&self) -> String {
          format!("@{}", self.username)
      }
  }
  ```

- We only have to implement `summarize_author` and we get the default
  implementation of `summarize` for free. Note however you cannot call the
  default implementation from an overriding implementation in the same method.

#### Using Traits as Parameters

- Now that we know how to define and implement traits, we can explore how to use
  traits to define functions that accept many different types. We will continue
  using the `Summary` trait as an example. Imagine we wanted a `notify` function
  that takes a type that implements `Summary` and calls its `summarize`
  function. We would specify this with the `impl Trait` syntax:

  ```rs
  pub fn notify(item: &impl Summary) {
      println!("Breaking news! {}", item.summarize());
  }
  ```

- This parameter will accept any type that implements the specified trait. In
  the function body, we can use any methods on `item` that come from the
  `Summary` trait such as `summarize`. We could call it with a `NewsArticle` or
  `SocialPost`, but it would fail to compile if called with a `String` or `i32`
  because those types don't implement `Summary`.
- The `impl Trait` syntax is actually syntactic sugar for a longer form known
  as a *trait bound*:

  ```rs
  pub fn notify<T: Summary>(item: &T) {
      println!("Breaking news! {}", item.summarize());
  }
  ```

- The longer form gives us more control. If we declared two parameters using
  `impl Summary`, those two parameters could be different types. Where if we
  declared them `<T: Summary>` then used `T` for both, they would be required to
  be the same type.
- In either syntax we can specify more than one trait bound using the `+`
  syntax:

  ```rs
  pub fn notify(item: &(impl Summary + Display)) { /* ... */ }

  pub fn notify<T: Summary + Display>(item: &T) { /* ... */ }
  ```

- With both traits specified, the caller can call `summarize` and use `{}` to
  format `item`.
- Functions with multiple generic type parameters can contain lots of trait
  bound information, so Rust has alternate syntax for specifying trait bounds
  inside a `where` clause after the function signature:

  ```rs
  // Instead of
  fn some_function<T: Display + Clone, U: Clone + Debug>(t: &T, u: &U) -> i32 {
      /* ... */
  }
  // We can say
  fn some_function<T, U>(t: &T, u: &U) -> i32
  where
      T: Display + Clone,
      U: Clone + Debug,
  {
      /* ... */
  }
  ```

#### Returning Types That Implement Traits

- We can use the `impl Trait` syntax in the return position to return a
  value of some type that implements a trait without specifying the concrete
  type:

  ```rs
  fn returns_summarizable() -> impl Summary {
      SocialPost {
          username: String::from("horse_ebooks"),
          content: String::from(
              "of course, as you probably already know, people",
          ),
          reply: false,
          repost: false,
      }
  }
  ```

- The ability to specify a return type only by the trait it implements is
  especially useful in the context of closures and iterators, which we cover in
  Chapter 13. Closures and iterators create types that only the compiler knows
  or types that are very long to specify, but the `impl Trait` syntax allows you
  to specify that a function returns some type that implements the `Iterator`
  trait without needing to write out a very long type. However, you can only
  use `impl Trait` if you're returning a single type. Returning either a
  `NewsArticle` or a `SocialPost` isn't allowed due to restrictions on how
  `impl Trait` is implemented in the compiler.

#### Using Trait Bounds to Conditionally Implement Methods

- By using a trait bound with an `impl` block that uses generic type parameters,
  we can implement methods conditionally for types that implement the specified
  traits. In the following example, `Pair<T>` always implements the `new`
  function to return a new instance of `Pair<T>`, but it only implements
  `cmp_display` when its inner type `T` implements the `PartialOrd` trait that
  enables comparison and the `Display` trait that enables printing:

  ```rs
  use std::fmt::Display;

  struct Pair<T> {
      x: T,
      y: T,
  }

  impl<T> Pair<T> {
      fn new(x: T, y: T) -> Self {
          // Recall `Self` in an `impl` is a type alias for `Pair<T>` here:
          Self { x, y }
      }
  }

  impl<T: Display + PartialOrd> Pair<T> {
      fn cmp_display(&self) {
          if self.x >= self.y {
              println!("The largest member is x = {}", self.x);
          } else {
              println!("The largest member is y = {}", self.y);
          }
      }
  }
  ```

- We can also conditionally implement a trait for any type that implements
  another trait. Implementations of a trait on any type that satisfies the
  trait bounds are called *blanket implementations* and are used extensively
  by the Rust standard library. For example, the standard library implements
  the `ToString` trait on any type that implements the `Display` trait. The
  `impl` block looks similar to:

  ```rs
  impl<T: Display> ToString for T {
      // --snip--
  }
  ```

- Because of this, we can call the `to_string` method defined in `ToString` on
  any type that implements the `Display` trait. Because integers implement
  `Display` we can convert them to `String` values as follows:

  ```rs
  let s = 3.to_string();
  ```

- Blanket implementations appear in the documentation for the trait in the
  "Implementors" section.
- Not covered in the book: implementing `Display` for your own type. It can't
  be derived (the user-facing format is up to you), but it's short. `fmt`
  writes into a `Formatter` with `write!` (like `format!`, but into `f`) and
  returns `fmt::Result`. Thanks to the blanket implementation above,
  `to_string()` comes for free:

  ```rs
  use std::fmt;

  struct Rectangle {
      width: u32,
      height: u32,
  }

  impl fmt::Display for Rectangle {
      fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
          write!(f, "{}x{} rectangle", self.width, self.height)
      }
  }

  fn main() {
      let rect = Rectangle { width: 30, height: 50 };
      println!("{rect}");        // 30x50 rectangle
      let s = rect.to_string();  // "30x50 rectangle", via ToString
  }
  ```

- Traits and trait bounds let us write code that uses generic type parameters
  to reduce duplication but also specify to the compiler that we want the
  generic type to have particular behavior. The compiler can then use the
  trait bound information to check that all the concrete types used with our
  code provide the correct behavior. In dynamically typed languages, we would
  get an error at runtime if we called a method on a type that didn't define
  the method. But Rust moves these errors to compile time so that we're forced
  to fix the problems before our code is even able to run. Additionally, we
  don't have to write code that checks for behavior at runtime, because we've
  already checked at compile time. Doing so improves performance without
  having to give up the flexibility of generics.

### 10.3 - Validating References with Lifetimes

- Lifetimes are another kind of generic that we've already been using. They
  ensure that references are valid as long as we need them to be. Every
  reference in Rust has a lifetime, which is the scope for which that reference
  is valid. Most of the time they are implicit and inferred, just like most of
  the time types are inferred. Just like we are only required to annotate types
  when multiple types are possible, we must annotate lifetimes when the
  lifetimes of references could be related in a few different ways. Rust
  requires us to annotate the relationships using generic lifetime parameters
  to ensure that the actual references used at runtime will definitely be valid.

#### Dangling References

- The main aim of lifetimes is to prevent dangling references which, if they
  were allowed to exist, would cause a program to reference data other than the
  data it's intended to reference.

  ```rs
  // DOES NOT COMPILE! error[E0597]: `x` does not live long enough
  fn main() {
      let r;

      {
          let x = 5;
          r = &x;
      }

      println!("r: {}", r);
  }
  ```

- Because `r` has a larger scope than `x`, we say that it "lives longer". If
  Rust allowed this code to work, `r` would be referencing memory that was
  deallocated when `x` went out of scope.

#### The Borrow Checker Ensures Data Outlives Its References

- The Rust compiler has a *borrow checker* that compares scopes to determine
  whether all borrows are valid. This is the same code with annotations showing
  the lifetimes of the variables:

  ```rs
  // DOES NOT COMPILE! error[E0597]: `x` does not live long enough
  fn main() {
      let r;                // ---------+-- 'a
                            //          |
      {                     //          |
          let x = 5;        // -+-- 'b  |
          r = &x;           //  |       |
      }                     // -+       |
                            //          |
      println!("r: {r}");   //          |
  }                         // ---------+
  ```

- `'b` is shorter than `'a`: The subject of the reference doesn't live as long
  as the reference. So the program is rejected. Here is a fixed version:

  ```rs
  fn main() {
      let x = 5;            // ----------+-- 'b
                            //           |
      let r = &x;           // --+-- 'a  |
                            //   |       |
      println!("r: {r}");   //   |       |
                            // --+       |
  }                         // ----------+
  ```

- Here `x` still has lifetime `'b`, but `'b` is larger than `'a`.

#### Generic Lifetimes in Functions

- We'll write a function that returns the longer of two string slices. After it
  is written, the output of the following program will be
  `The longest string is abcd`.

  ```rs
  fn main() {
      let string1 = String::from("abcd");
      let string2 = "xyz";

      let result = longest(string1.as_str(), string2);
      println!("The longest string is {result}");
  }
  ```

- We want `longest` to take string slices, which are references, rather than
  strings, because we don't want the `longest` function to take ownership of its
  parameters. The following will not compile:

  ```rs
  // DOES NOT COMPILE! error[E0106]: missing lifetime specifier
  fn longest(x: &str, y: &str) -> &str {
      if x.len() > y.len() { x } else { y }
  }
  ```

- The error message tells us we need a generic lifetime parameter on the return
  type because Rust can't tell whether the reference being returned refers to
  `x` or `y`. But we actually don't know that either and also don't know the
  lifetimes of concrete references that will be passed in. To fix this error,
  we'll add generic lifetime parameters that define the relationship between
  the references so that the borrow checker can perform analysis.

#### Lifetime Annotation Syntax

- Lifetime annotations don't change how long references live. They instead
  describe the relationships of the lifetimes of multiple references to each
  other without affecting lifetimes. Just like a function can accept any type
  when the type signature specified a generic type parameter, functions can
  accept references with any lifetime by specifying a generic lifetime
  parameter.
- Lifetime annotations start with an apostrophe `'` and are usually all
  lowercase and very short, like generic types. Most people use `'a` for the
  first lifetime annotation. We place lifetime annotations after the `&` of a
  reference, using a space to separate the annotation from the reference's
  type. Here are some examples:

  ```rs
  &i32        // a reference
  &'a i32     // a reference with an explicit lifetime
  &'a mut i32 // a mutable reference with an explicit lifetime
  ```

- One lifetime annotation by itself doesn't have much meaning, because the
  annotations are meant to tell Rust how generic lifetime parameters of
  multiple references relate to each other.

#### In Function Signatures

- To use lifetime annotations in function signatures, we need to declare the
  generic lifetime parameters inside angle brackets between the function name
  and the parameter list, just as we did with generic type parameters. We want
  the signature to express the following constraint: The returned reference will
  be valid as long as both parameters are valid:

  ```rs
  fn longest<'a>(x: &'a str, y: &'a str) -> &'a str {
      if x.len() > y.len() { x } else { y }
  }
  ```

- Now the function signature tells Rust that for some lifetime `'a`, the
  function takes two parameters, both of which are string slices that live at
  least as long as lifetime `'a`. It also tells Rust that the string slice
  returned from the function will live at least as long as lifetime `'a`. In
  practice, this means the lifetime of the reference returned by the `longest`
  function is the same as the smaller of the lifetimes of the values passed in
  as arguments. Lifetime annotations go in the function signature, not in the
  function body, and they become part of the contract of the function. The
  generic lifetime `'a` will get the concrete lifetime that is equal to the
  smaller of the lifetimes of `x` and `y`, and the returned reference will be
  valid for the length of the smaller of the lifetimes of `x` and `y`.

  ```rs
  // This example works fine, since `result` doesn't outlive either parameter
  fn main() {
      let string1 = String::from("long string is long");

      {
          let string2 = String::from("xyz");
          let result = longest(string1.as_str(), string2.as_str());
          println!("The longest string is {result}");
      }
  }

  // DOES NOT COMPILE! error[E0597]: `string2` does not live long enough
  fn main() {
      let string1 = String::from("long string is long");
      let result;
      {
          let string2 = String::from("xyz");
          result = longest(string1.as_str(), string2.as_str());
      }
      println!("The longest string is {result}");
  }
  ```

#### Relationships

- If `longest` always returned the first parameter, we would only need to
  specify the lifetime of the first parameter and return type. When returning
  a reference from a function, the lifetime parameter for the return type must
  match the lifetime parameter for one of the parameters. If the reference does
  not refer to one of the parameters, it must refer to a value created within
  the function, but this would be a dangling reference because the value would
  go out of scope at the end of the function. It doesn't work to specify a
  lifetime parameter only for the return value when it relates to neither
  parameter:

  ```rs
  // DOES NOT COMPILE! error[E0515]: cannot return value referencing local
  //                                 variable `result`
  fn longest<'a>(x: &str, y: &str) -> &'a str {
      let result = String::from("really long string");
      result.as_str()
  }
  ```

- We're trying to return a reference to a local variable that is cleaned up at
  the end of the function, and there is no way to specify lifetime parameters
  to make this legal, so Rust won't allow it. In this case, the best fix would
  be to return an owned data type rather than a reference.
- Ultimately, lifetime syntax is about connecting the lifetimes of various
  parameters and return values of functions. Once they're connected, Rust has
  enough information to allow memory-safe operations and disallow operations
  that would create dangling pointers or otherwise violate memory safety.

#### In Struct Definitions

- So far, the structs we've defined all hold owned types. We can define structs
  to hold references, but in that case we would need to add a lifetime
  annotation on every reference in the struct's definition:

  ```rs
  struct ImportantExcerpt<'a> {
      part: &'a str,
  }

  fn main() {
      let novel = String::from("Call me Ishmael. Some years ago...");
      let first_sentence = novel.split('.').next().unwrap();
      let i = ImportantExcerpt {
          part: first_sentence,
      };
  }
  ```

- This struct has a single field `part` that holds a string slice which is a
  reference. An instance of `ImportantExcerpt` cannot outlive the reference it
  holds in its `part` field. Here `novel` exists before `i` and doesn't go out
  of scope until after `i` does, so this is valid.

#### Lifetime Elision

- The *lifetime elision rules* are particular patterns that the compiler is
  programmed to recognize, so you can leave out lifetime annotations. Lifetimes
  on function or method parameters are called *input lifetimes*, and lifetimes
  on return values are called *output lifetimes*. The compiler follows three
  rules to figure out lifetimes of references when there aren't explicit
  annotations. The first rule applies to input lifetimes, and the second and
  third rules apply to output lifetimes. If the compiler gets to the end of the
  three rules and there are still references for which it can't figure out
  lifetimes, the compiler will stop with an error. These rules apply to `fn`
  definitions as well as `impl` blocks.
- The first rule is that the compiler assigns a different lifetime parameter to
  each lifetime in each input type. For example:
  - The function `fn foo(x: &i32)` would get one lifetime parameter and become
    `fn foo<'a>(x: &'a i32)`.
  - The function `fn foo(x: &i32, y: &i32)` would get two lifetime parameters
    and become `fn foo<'a, 'b>(x: &'a i32, y: &'b i32)`.
  - The function `fn foo(x: &ImportantExcerpt)` would get two lifetime
    parameters and become `fn foo<'a, 'b>(x: &'a ImportantExcerpt<'b>)`.
- The second rule is that if there is exactly one input lifetime parameter,
  that lifetime is assigned to all output lifetime parameters:
  `fn foo<'a>(x: &'a i32) -> &'a i32`.
- The third rule is that if there are multiple input lifetime parameters but
  one of them is `&self` or `&mut self` because this is a method, the lifetime
  of `self` is assigned to all output lifetime parameters. The third rule makes
  methods much nicer to read and write because fewer symbols are necessary.
- Consider the `first_word` function from Chapter 4. It did not need annotations
  because of these rules. The signature starts without any lifetimes:
  `fn first_word(s: &str) -> &str {`. Then the compiler applies the first rule
  which specifies that each parameter gets its own lifetime:
  `fn first_word<'a>(s: &'a str) -> &str {`. The second rule applies because
  there is exactly one input lifetime, so the lifetime of the input parameter is
  assigned to the output parameter:
  `fn first_word<'a>(s: &'a str) -> &'a str {`. Now all the references in the
  signature have lifetimes so the compiler can continue analysis without needing
  programmer annotations.
- Now consider the `longest` function before we added lifetime parameters.
  `fn longest(x: &str, y: &str) -> &str {`. The first rule is every input
  parameter gets its own lifetime:
  `fn longest<'a, 'b>(x: &'a str, y: &'b str) -> &str {`. The second rule does
  not apply since there is more than one input lifetime. The third rule doesn't
  apply because this is a function rather than a method so there is no `self`.
  We have worked through all three rules without figuring out the return type's
  lifetime, so we get a compiler error.

#### In Method Definitions

- The third rule means we don't need to annotate method signatures often. When
  we implement methods on a struct with lifetimes, we use the same syntax as
  that of generic type parameters. Where we declare and use the lifetime
  parameters depends on whether they are related to the struct fields or the
  method parameters and return values. Lifetime names for struct fields always
  need to be declared after the `impl` keyword and then used after the struct's
  name because those lifetimes are part of the struct's type. In method
  signatures inside the `impl` block, references might be tied to the lifetime
  of references in the struct's fields or they might be independent.
- Consider this method `level` whose only parameter is a reference to `self`
  and whose return value is an `i32` defined on `ImportantExcerpt` from the
  earlier example:

  ```rs
  impl<'a> ImportantExcerpt<'a> {
      fn level(&self) -> i32 {
          3
      }
  }
  ```

- The lifetime parameter after `impl` and after the struct name are required,
  but because of the first elision rule, we're not required to annotate the
  lifetime of the reference to `self`.
- Here is an example where the third lifetime elision rule applies:

  ```rs
  impl<'a> ImportantExcerpt<'a> {
      fn announce_and_return_part(&self, announcement: &str) -> &str {
          println!("Attention please: {announcement}");
          self.part
      }
  }
  ```

- The first rule applies and gives both `&self` and `announcement` their own
  lifetimes. Then because one of the parameters is `&self`, the return type
  gets the lifetime of `&self` and all lifetimes have been accounted for.

#### The Static Lifetime

- `'static` is a special lifetime that denotes the affected reference *can*
  live for the entire duration of the program. All string literals have the
  `'static` lifetime. Here is an annotated string:

  ```rs
  let s: &'static str = "I have a static lifetime.";
  ```

- The text of this string is stored directly in the program's binary, which is
  always available. Therefore, the lifetime of all string literals is `'static`.
  An error message might suggest using `'static` but it is seldom the answer.

#### Generic Type Parameters, Trait Bounds, and Lifetimes

- Here is an example that combines specifying generic type parameters, trait
  bounds, and lifetimes all in one function:

  ```rs
  use std::fmt::Display;

  fn longest_with_an_announcement<'a, T>(
      x: &'a str,
      y: &'a str,
      ann: T,
  ) -> &'a str
  where
      T: Display,
  {
      println!("Announcement! {ann}");
      if x.len() > y.len() { x } else { y }
  }
  ```

- This is the `longest` function from earlier, but it also takes an `ann`
  parameter of any type that implements the `Display` trait. Because lifetimes
  are a type of generic, both `'a` and `T` go in the angle brackets after the
  function name.

## Chapter 11 - Writing Automated Tests

- Tests are Rust functions that verify that the non-test code is functioning in
  the expected manner. The bodies of test functions typically perform these
  three actions:
  - Set up any needed data or state.
  - Run the code you want to test.
  - Assert that the results are what you expect.

### 11.1 - How to Write Tests

- At its simplest, a test in Rust is a function that's annotated with the `test`
  attribute. Attributes are metadata about pieces of Rust code; one example is
  the `derive` attribute we used with structs in Chapter 5. To change a function
  into a test function, add `#[test]` on the line before `fn`. When you run your
  tests with `cargo test`, Rust builds a test runner binary that runs the
  annotated function and reports on whether each test function passes or fails.
- When you make a new library project with Cargo
  (`cargo new library-name --lib`), a test module with a test function in it is
  automatically generated.
- `cargo test` outputs a line per test, but `cargo test -q` outputs a `.` per
  test unless there's a failure.
- One way to fail a test is to call `panic!`. Another is to give the `assert!`
  macro an argument that evaluates `false`. You could also compare two unequal
  values with `assert_eq!` or two equal values with `assert_ne!`.
- Here's a basic library with a couple of tests for some code we've seen:

  ```rs
  // ch11_adder/src/lib.rs
  #[derive(Debug)]
  struct Rectangle {
      width: u32,
      height: u32,
  }

  impl Rectangle {
      fn can_hold(&self, other: &Rectangle) -> bool {
          self.width > other.width && self.height > other.height
      }
  }

  pub fn add_two(a: u64) -> u64 {
      a + 2
  }

  #[cfg(test)]
  mod tests {
      use super::*;

      #[test]
      fn larger_can_hold_smaller() {
          let larger = Rectangle {
              width: 8,
              height: 7,
          };
          let smaller = Rectangle {
              width: 5,
              height: 1,
          };

          assert!(larger.can_hold(&smaller));
      }

      #[test]
      fn smaller_cannot_hold_larger() {
          let larger = Rectangle {
              width: 8,
              height: 7,
          };
          let smaller = Rectangle {
              width: 5,
              height: 1,
          };

          assert!(!smaller.can_hold(&larger));
      }

      #[test]
      fn it_adds_two() {
          let result = add_two(2);
          assert_eq!(result, 4);
      }
  }
  ```

- The tests are in their own `tests` module but they can see everything in their
  parent module. They `use super::*` so they can directly call anything in their
  parent. These tests pass.
- The `assert_eq!` macro calls its arguments `left` and `right` and doesn't care
  which is the expected vs actual value. When `assert_eq!` or `assert_ne!` fail,
  they print their arguments using debug formatting. Also, they do their
  comparison with `==` and `!=` so the values being compared need to implement
  the `Debug` and `PartialEq` traits. Both traits are derivable, so usually you
  only need to add `#[derive(PartialEq, Debug)]` annotation to your struct or
  enum definition. Any arguments after the value (for `assert!`) or two values
  (for `_eq!` and `_ne!`) being tested are passed to the `format!` macro for
  display. You can pass a format string that contains `{}` placeholders and
  values to go in those placeholders. Custom messages are useful for documenting
  what an assertion means; when a test fails, you'll have a better idea of what
  the problem is with the code.

  ```rs
  pub fn greeting(name: &str) -> String {
      format!("Hello {name}!")
  }

  #[cfg(test)]
  mod tests {
      use super::*;

      #[test]
      fn greeting_contains_name() {
          let result = greeting("Carol");
          assert!(
              result.contains("Carol"),
              "Greeting did not contain name, value was `{result}`"
          );
      }
  }
  ```

- Now when `greeting_contains_name` fails, we get an informational message that
  includes the result without using `assert_eq!` to test exact equality.
  You can refer to any variables in scope, and you can also provide format
  strings for `assert_eq!` and `assert_ne!`.
- The `#[track_caller]` attribute works like Go's `t.Helper()` for test
  helper functions: a failing assertion inside the helper is reported at the
  line in the test that called it, not inside the helper.

  ```rs
  #[track_caller]
  fn assert_even(n: i32) {
      assert!(n % 2 == 0, "{n} is not even");
  }

  #[test]
  fn three_is_even() {
      assert_even(3); // the failure points at this line
  }
  ```

- Recall our `Guess` struct that takes a guess between 1 and 100 and panics
  otherwise. This is our contract, and it would be good to test. We can test it
  with `should_panic`. We place `#[should_panic]` after the `#[test]` attribute
  and before the test function it applies to.

  ```rs
  pub struct Guess {
      value: i32,
  }

  impl Guess {
      pub fn new(value: i32) -> Guess {
          if value < 1 || value > 100 {
              panic!("Guess value must be between 1 and 100, got {value}.");
          }

          Guess { value }
      }
  }

  #[cfg(test)]
  mod tests {
      use super::*;

      #[test]
      #[should_panic]
      fn greater_than_100() {
          Guess::new(200);
      }
  }
  ```

- Tests relying on `#[should_panic]` can be imprecise and pass even when they
  panic for an unexpected reason. `should_panic` takes an `expected` argument
  that will check the panic message for an expected substring. It can further
  check your expectations, but couples you to a specific `panic` message.

  ```rs
  #[test]
  #[should_panic(expected = "between 1 and 100")]
  fn greater_than_100() {
      Guess::new(200);
  }
  ```

- Instead of panicking, tests can optionally return a `Result<(), String>`. This
  enables you to use the question mark operator in the body of tests, which can
  be a convenient way to write tests that should fail if any operation within
  them returns an `Err` variant. You cannot use `#[should_panic]` with a test
  that returns a `Result`. To check that an operation returns an `Err` variant,
  you should use `assert!(value.is_err())`.

  ```rs
  #[cfg(test)]
  mod tests {
      use super::*;

      #[test]
      fn it_works() -> Result<(), String> {
          let result = add_two(2);

          if result == 4 {
              Ok(())
          } else {
              Err(String::from("two plus two does not equal four"))
          }
      }
  }
  ```

- Here is an example of a test calling `Result` returning functions and passing
  the `Err` upwards:

  ```rs
  // without Result: unwrap on every fallible step
  #[test]
  fn loads_config() {
      let text = fs::read_to_string("tests/data/config.toml").unwrap();
      let config = Config::parse(&text).unwrap();
      assert_eq!(config.port, 8080);
  }

  // with Result: ? passes any failure up, which fails the test
  #[test]
  fn loads_config() -> Result<(), Box<dyn Error>> {
      let text = fs::read_to_string("tests/data/config.toml")?;
      let config = Config::parse(&text)?;
      assert_eq!(config.port, 8080);
      Ok(())
  }
  ```

- This has two benefits:
  - Setup reads like normal code. Integration tests often read files, parse
    input or connect to things, and `?` keeps that setup short.
  - Failures show the error itself. A failing test prints the returned error
    (for example, the parse error), while an `unwrap()` panic shows mostly the
    panic location.

### 11.2 - Controlling How Tests Are Run

- The default behavior of `cargo test` is to run all your tests in parallel and
  capture output generated during test runs to make it easier to read test
  output. All tests in a test binary are run by default and all test failures
  are reported at the end. `cargo test -- --fail-fast` stops starting new tests
  after the first failure. Some arguments go to `cargo test` and some go to the
  resultant test binary. You separate options to each by `--`.
  `cargo test --help` displays the options you can use with `cargo test`, and
  `cargo test -- --help` displays the options you can use after the separator.
  Options are documented in the Tests section of the rustc book:
  <https://doc.rust-lang.org/rustc/tests/index.html>.
- If you don't want to run the tests in parallel, you run:
  `cargo test -- --test-threads=1`. It is slower, but the tests won't interfere
  with one another if they share state.
- Rust captures output of tests and only shows it on test failure. So if the
  test passes, you only see the success message and no `println!` output, but if
  it fails you see both the failure message and captured output. If you want
  to see printed output for passing tests run: `cargo test -- --show-output`.
- Running `cargo test` will run all tests. Passing a string after `cargo test`,
  like `cargo test greeting` will run all tests that contain the substring
  "greeting" in their function name or module name. Specifying
  `cargo test module_name` is a good way to run all the tests in a module.
- Not in the book: Cargo can also select tests by *target*, which is better for
  running fast unit tests on every change and slower integration tests before
  committing:

  | Command                 | Runs                                          |
  | ----------------------- | --------------------------------------------- |
  | `cargo test --lib`      | Unit tests in the library (*src/lib.rs* tree) |
  | `cargo test --bins`     | Unit tests in *src/main.rs* and *src/bin*     |
  | `cargo test --test api` | Only the integration test file *tests/api.rs* |
  | `cargo test --test '*'` | All integration tests                         |
  | `cargo test --doc`      | Only doc tests                                |
  | `cargo test`            | Everything                                    |

  Targets and name filters combine: `cargo test --lib parser::` runs just the
  parser module's unit tests. For a TDD loop, `bacon test -- --lib`. Avoid
  `--tests` (plural) for this: it runs unit and integration tests together.
- The `#[ignore]` attribute marks a test to not be run unless you call either
  `cargo test -- --ignored` to run only the ignored tests or
  `cargo test -- --include-ignored` to run the normal test suite along with the
  ignored tests.

### 11.3 - Test Organization

- *Unit tests* are small, focused tests that test one module in isolation at a
  time and can test private interfaces. *Integration tests* are entirely
  external to your library and use your code in the same way any other external
  code would, using only the public interface and potentially exercising
  multiple modules per test. Both types of test are important to ensure the
  pieces of your library do what you expect them to, separately and together.
- You put unit tests in the *src* directory in each file with the code that
  they're testing. The convention is to create a module named `tests` in each
  file to contain the test functions and to annotate the module with
  `#[cfg(test)]`. Because of the annotation, unit tests are not compiled unless
  you run `cargo test`. Integration tests don't need this annotation because
  they are in a different directory. The annotation applies to all code in the
  `tests` module, including test helpers. If you make a separate test helper
  module, annotate it `#[cfg(test)]` as well (see Testing Larger Projects
  below).
- Rust's test conventions allow you to test private functions. It is up to you
  if that is a good idea.
- In Rust, integration tests are entirely external to your library, and they use
  your library through the public API, like any other code would. You put
  integration tests in the *tests* directory. Each file in the *tests* directory
  is a separate crate, so we need to bring our library into each test crate's
  scope with `use`. Cargo automatically only compiles code in the *tests*
  directory when you run `cargo test`, so `#[cfg(test)]` is unnecessary.
- In the test output, unit tests then integration tests and finally doc tests
  are reported on separately. If any test in a section fails, the following
  sections will not be run (`cargo test --no-fail-fast` runs them anyway). Each
  integration test has its own section, so if you add more files to the *tests*
  directory, there will be more integration test sections. To only run the tests
  in one particular integration test, you can run
  `cargo test --test integration_test` for a test named `integration_test`.

  ```rs
  // ch11_adder/tests/integration_test.rs
  use adder::add_two;

  #[test]
  fn it_adds_two() {
      let result = add_two(2);
      assert_eq!(result, 4);
  }
  ```

- It is likely you will need a place for shared integration test code such as
  a shared `setup` function. If you place test helpers in *tests/common/mod.rs*,
  it will not show up as a separate integration test. The name tells Rust to not
  treat it as an integration test file. Here is our same integration test using
  a shared helper:

  ```rs
  // ch11_adder/tests/common/mod.rs
  pub fn setup() {
      // setup code specific to your library's tests would go here
  }

  // ch11_adder/tests/integration_test.rs
  use adder::add_two;

  mod common;

  #[test]
  fn it_adds_two() {
      common::setup();

      let result = add_two(2);
      assert_eq!(result, 4);
  }
  ```

- Only library crates expose functions that other crates can `use`; binary
  crates are meant to be run on their own. So integration tests have no way to
  bring functions defined in `src/main.rs` into scope. This is why we keep the
  code in our `src/main.rs` straightforward and call logic that lives in
  *src/lib.rs*. Using that structure, integration tests can test the library
  crate with `use`. If the important functionality works, the small amount of
  code in the *src/main.rs* file will work as well.
- Testing larger projects (not in the book): each module gets its own
  `#[cfg(test)] mod tests` child, because a test module only sees the private
  items of its own parent; `crate::tests` can't see inside sibling modules like
  `crate::parser`. To keep tests out of the source file (like Go's
  *parser_test.go* beside *parser.go*), end the module with
  `#[cfg(test)] mod tests;` and put the tests in *src/parser/tests.rs*; it is
  still a child module with private access.
- `pub(crate)` makes an item visible anywhere in the crate but not to other
  crates. Use it for code shared between modules, and for shared unit-test
  helpers: `#[cfg(test)] pub(crate) mod test_utils;` (no standard name;
  `test_utils` is the most common). Integration tests can't see `test_utils`,
  since they are separate crates; they share helpers through
  *tests/common/mod.rs* instead.
- Besides one integration test binary per `tests/*.rs` file, Cargo also builds
  `tests/<name>/main.rs` as a single binary that can pull in sibling files as
  modules. Linking fewer binaries is faster, so big projects often group their
  integration tests this way, named after what they test (or *tests/it/* for
  one all-in-one binary). Other subdirectories are only modules. Each
  workspace member has its own *tests/*.

  ```text
  src/
  |-- lib.rs            // #[cfg(test)] pub(crate) mod test_utils;
  |-- test_utils.rs     // shared unit-test helpers
  |-- parser.rs         // ends with: #[cfg(test)] mod tests;
  |-- parser/
  |   `-- tests.rs      // crate::parser::tests (sees parser's private items)
  |-- lexer.rs          // ends with: #[cfg(test)] mod tests;
  `-- lexer/
      `-- tests.rs      // crate::lexer::tests
  tests/
  |-- api.rs            // one integration test binary
  |-- common/
  |   `-- mod.rs        // shared integration helpers, not a test binary
  `-- parser/
      |-- main.rs       // one binary for all parser integration tests
      `-- errors.rs     // pulled in with `mod errors;`
  ```

- Even though Rust's type system and ownership rules help prevent some kinds of
  bugs, tests are still important to reduce logic bugs having to do with how
  your code is expected to behave.

#### Beyond the Book

- Naming tests: test names are function names, so no spaces, but nested
  modules give RSpec-style `describe`/`context`/`it` names joined by `::`. Each
  module needs its own `use super::*;`.

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
  }
  // cargo test prints: mode::when_the_list_is_empty::returns_none
  ```

- [rstest](https://docs.rs/rstest/latest/rstest/) - pytest-style fixtures and
  parametrized tests. `#[case(...)]` runs one test per row (like Go's
  table-driven tests or Spock's `where:` blocks), `#[values(...)]` runs every
  combination, and `#[fixture]` functions inject shared setup. The docs have
  good examples of all three.

  ```rs
  use rstest::rstest;

  #[rstest]
  #[case::rectangle(Shape::Rectangle { width: 12.0, height: 6.0 }, 72.0)]
  #[case::triangle(Shape::Triangle { base: 12.0, height: 6.0 }, 36.0)]
  fn area(#[case] shape: Shape, #[case] want: f64) {
      // floats: compare within a tolerance, not with assert_eq!
      let got = shape.area();
      assert!((got - want).abs() < 1e-9, "got {got}, want {want}");
  }
  // names: area::case_1_rectangle, area::case_2_triangle

  #[rstest]
  fn scaling_keeps_area_positive(
      #[values(1.0, 2.5, 10.0)] width: f64,
      #[values(1.0, 0.5)] scale: f64,   // 3 x 2 = 6 tests
  ) {
      let rect = Shape::Rectangle { width: width * scale, height: 4.0 };
      assert!(rect.area() > 0.0);
  }
  ```

- [test-case](https://docs.rs/test-case/) - like `#[case]`, but each case gets
  a plain-English description that becomes the test name. `=>` gives the
  expected return value (an implicit `assert_eq!`).

  ```rs
  use test_case::test_case;

  #[test_case(&[] => None ; "returns none for an empty list")]
  #[test_case(&[3, 1, 2] => Some(2.0) ; "returns the middle of an odd list")]
  fn median_works(v: &[i32]) -> Option<f64> {
      median(v)
  }
  ```

- [pretty_assertions](https://docs.rs/pretty_assertions/) - drop-in
  `assert_eq!` with colored diffs; add `use pretty_assertions::assert_eq;` to
  the test module.
- [approx](https://docs.rs/approx/) - `assert_relative_eq!` and
  `assert_abs_diff_eq!` for float comparisons.
- [proptest](https://docs.rs/proptest/) - property-based testing, the Rust
  take on QuickCheck/Hypothesis.
- Benchmarks: Rust's built-in `#[bench]` has been unstable for years and only
  works on the nightly compiler. On stable Rust, use the `criterion` crate
  (the long-standing standard, modeled on Haskell's criterion) or `divan`
  (newer and simpler). Go's built-in `testing.B` is more convenient here.

## Chapter 12 - An I/O Project: Building a Command Line Program

- Project time! We are going to build `grep` (globally search a regular
  expression and print). In the simplest case `grep` searches a specified file
  for a specified string. To do so, `grep` takes as its arguments a file path
  and a string. Then, it reads the file, finds lines in that file that contain
  the string argument, and prints those lines.

### 12.1 - Accepting Command Line Arguments

- Our first task after creating the new project is to make `minigrep` accept
  its two command line arguments: the file path and a string to search for.
  We will pass these arguments by calling `cargo run` with `--`:
  `cargo run -- searchstring example-filename.txt`. There are many good
  command-line argument parsing libraries, but we are going to do it ourselves.
- To enable `minigrep` to read the values of command line arguments we pass it,
  we will use the `std::env::args` function provided by Rust's standard library.
  It returns an iterator of the command line arguments passed to `minigrep`.
  Iterators will be covered in Chapter 13, but it is enough to know that
  iterators produce a series of values, and we can call the `collect` method on
  an iterator to turn it into a collection, such as a vector, which contains all
  the elements the iterator produces.

  ```rs
  // ch12_minigrep/src/main.rs
  use std::env;

  fn main() {
      let args: Vec<String> = env::args().collect();
      dbg!(args);
  }
  ```

- `collect` can return many varieties of collection. Although you don't have to
  annotate types in Rust often, `collect` is one function you do often need to
  annotate because Rust isn't able to infer the kind of collection you want.

  ```text
  $ cargo run
      Finished `dev` profile [unoptimized + debuginfo] target(s) in 0.00s
       Running `/Users/llcawthorne/git/book-notes/rust/the-rust-programming-language/target/debug/minigrep`
  [ch12_minigrep/src/main.rs:5:5] args = [
      "/Users/llcawthorne/git/book-notes/rust/the-rust-programming-language/target/debug/minigrep",
  ]

  $ cargo run needle haystack
      Finished `dev` profile [unoptimized + debuginfo] target(s) in 0.00s
       Running `/Users/llcawthorne/git/book-notes/rust/the-rust-programming-language/target/debug/minigrep needle haystack`
  [ch12_minigrep/src/main.rs:5:5] args = [
      "/Users/llcawthorne/git/book-notes/rust/the-rust-programming-language/target/debug/minigrep",
      "needle",
      "haystack",
  ]
  ```

- So let's pull out the first two args where we can use them:

  ```rs
  // ch12_minigrep/src/main.rs
  use std::env;

  fn main() {
      let args: Vec<String> = env::args().collect();

      let query = &args[1];
      let file_path = &args[2];

      println!("Searching for {query}");
      println!("In file {file_path}");
  }
  ```

- We know array indexing starts at 0, but `args[0]` is the filename of the
  program we're running.

### 12.2 - Reading a File

- Next we actually need to read a file, so we'll create a `poem.txt` in the
  root of our project.

  ```rs
  // ch12_minigrep/src/main.rs
  use std::env;
  use std::fs;

  fn main() {
      // --snip--
      println!("In file {file_path}");

      let contents = fs::read_to_string(file_path)
          .expect("Should have been able to read the file");

      println!("With text:\n{contents}");
  }
  ```

- Now if we `cargo run -- the poem.txt`, we get the contents of our text file.

### 12.3 - Refactoring to Improve Modularity and Error Handling

- To improve our program, we'll fix four problems that have to do with the
  program's structure and how it's handling potential errors. First, our `main`
  function now performs two tasks: it parses arguments and reads files. As our
  program grows, the number of separate tasks the `main` function handles will
  increase. As the function gains responsibilities, it becomes more difficult to
  reason about, harder to test, and harder to change without breaking one of its
  parts. It's best to separate functionality so that each function is
  responsible for one task.
- This issue also ties into the second problem: Although `query` and `file_path`
  are configuration variables to our program, variables like `contents` are
  used to perform the program's logic. The longer `main` becomes, the more
  variables we'll need to bring into scope; the more variables we have in scope,
  the harder it will be to keep track of the purpose of each. It's best to group
  the configuration variables into one structure to make their purpose clear.
- The third problem is that we've used `expect` to print an error message when
  reading the file fails, but the error message just prints
  `Should have been able to read the file.` Reading a file can fail in a
  number of ways: For example, the file could be missing, or we might not have
  permission to open it. Right now, regardless of the situation, we'd print the
  same error message for everything, which wouldn't give the user any
  information.
- Fourth, we use `expect` to handle an error, and if the user runs our program
  without specifying enough arguments, they'll get an `index out of bounds`
  error from Rust that doesn't clearly explain the problem. It would be best if
  all the error-handling code were in one place so that future maintainers had
  only one place to consult the code if the error-handling logic needed to
  change. Having all the error-handling code in one place will also ensure that
  we're printing messages that will be meaningful to our end users.
- The organization problem of allocating responsibility for multiple tasks to
  the `main` function is common to many binary projects. As a result, many Rust
  programmers find it useful to split up the separate concerns of a binary
  program when the `main` function starts getting large. This process has
  the following steps:
  - Split your program into a *main.rs* file and a *lib.rs* file and move your
    program's logic to *lib.rs*.
  - As long as your command line parsing logic is small, it can remain in the
    `main` function.
  - When the command line parsing logic starts getting complicated, extract it
    from the `main` function into other functions or types.
- The responsibilities that remain in the `main` function after refactoring
  should be limited to the following:
  - Calling the command line parsing logic with the argument values
  - Setting up any other configuration
  - Calling a `run` function (the book says in *lib.rs*, but in the current
    version `run` stays in *main.rs* and only `search` moves to *lib.rs*)
  - Handling the error if `run` returns an error
- This pattern is about separating concerns: *main.rs* handles running the
  program and *lib.rs* handles all the logic of the task at hand. Because you
  cannot test `main` function directly, this structure lets you test all of
  your program's logic by moving it out of the `main` function. The code that
  remains in the `main` function will be small enough to verify by inspection.
- First we need a `parse_config` function to handle arguments:

  ```rs
  // ch12_minigrep/src/main.rs
  fn main() {
      let args: Vec<String> = env::args().collect();

      let (query, file_path) = parse_config(&args);

      // --snip--
  }

  fn parse_config(args: &[String]) -> (&str, &str) {
      let query = &args[1];
      let file_path = &args[2];

      (query, file_path)
  }
  ```

- At the moment, we're returning a tuple, but then we immediately break that
  tuple down into individual parts again. This is a sign that perhaps we don't
  have the right abstraction yet. We'll instead put the two values in one struct
  and give each of the struct fields a meaningful name.

  ```rs
  // ch12_minigrep/src/main.rs
  use std::env;
  use std::fs;

  fn main() {
      let args: Vec<String> = env::args().collect();

      let config = parse_config(&args);

      println!("Searching for {}", config.query);
      println!("In file {}", config.file_path);

      let contents = fs::read_to_string(config.file_path)
          .expect("Should have been able to read the file");

      println!("With text:\n{contents}");
  }

  struct Config {
      query: String,
      file_path: String,
  }

  fn parse_config(args: &[String]) -> Config {
      let query = args[1].clone();
      let file_path = args[2].clone();

      Config { query, file_path }
  }
  ```

- Now we bundle our configuration parameters in a `Config` struct. We transfer
  ownership of our new struct when we return. We also clone our two `arg` values
  so our struct can contain owned `String` values. It would've been a violation
  of the borrowing rules if `Config` tried to take ownership of the values in
  `args` directly. Cloning isn't the most efficient solution, but it makes our
  code very straightforward because we don't have to manage the lifetimes of
  references.
- The primary point of `parse_config` is to create a struct now, so it's a
  constructor. We can make our code more idiomatic by naming it `new` and
  associating it with the `Config` struct.

  ```rs
  // ch12_minigrep/src/main.rs
  fn main() {
      let args: Vec<String> = env::args().collect();

      let config = Config::new(&args);

      // --snip--
  }

  // --snip--

  impl Config {
      fn new(args: &[String]) -> Config {
          let query = args[1].clone();
          let file_path = args[2].clone();

          Config { query, file_path }
      }
  }
  ```

- We don't have tests yet, but we're refactoring in small steps while keeping
  working code and running it between changes. Next up is fixing the panic when
  not enough arguments are provided. How about we `panic!` with a better
  message:

  ```rs
  // ch12_minigrep/src/main.rs
  // --snip--
      fn new(args: &[String]) -> Config {
          if args.len() < 3 {
              panic!("not enough arguments");
          }
          // --snip--
  ```

- Now the error message is better, but it's still a panic with line numbers of
  our code included. Let's try using `Result`. We're also going to change the
  name of our constructor from `new` to `build`, because many programmers
  expect `new` functions to never fail.

  ```rs
  // ch12_minigrep/src/main.rs
  use std::env;
  use std::fs;
  use std::process;

  fn main() {
      let args: Vec<String> = env::args().collect();

      let config = Config::build(&args).unwrap_or_else(|err| {
          println!("Problem parsing arguments: {err}");
          process::exit(1);
      });
      // --snip--
  }

  impl Config {
      fn build(args: &[String]) -> Result<Config, &'static str> {
          if args.len() < 3 {
              return Err("not enough arguments");
          }
          let query = args[1].clone();
          let file_path = args[2].clone();

          Ok(Config { query, file_path })
      }
  }
  ```

- We are exiting with a nonzero status since it is the convention to signal to
  the process that called our program that the program exited with an error
  state.
- Now we want to extract a function named `run` that will hold all the logic
  currently in `main` that isn't involved with setting up configuration or
  handling errors. It stays in *main.rs*; despite the book's earlier
  description, only the search logic ends up in *lib.rs*.

  ```rs
  // ch12_minigrep/src/main.rs
  fn main() {
      // --snip--

      println!("Searching for {}", config.query);
      println!("In file {}", config.file_path);

      run(config);
  }

  fn run(config: Config) {
      let contents = fs::read_to_string(config.file_path)
          .expect("Should have been able to read the file");

      println!("With text:\n{contents}");
  }
  // --snip--
  ```

- Ok, so the only logic left to move was reading the file. But we want to again
  improve error handling. Our `run` could return a `Result` too and let `main`
  sort out errors.

  ```rs
  // ch12_minigrep/src/main.rs
  use std::error::Error;

  // --snip--

  fn run(config: Config) -> Result<(), Box<dyn Error>> {
      let contents = fs::read_to_string(config.file_path)?;

      println!("With text:\n{contents}");

      Ok(())
  }
  ```

- For the return type, we left the success type of `run` as `()` but wrapped it
  in an `Ok`. Returning `()` or when using `Result` returning `Ok(())` is the
  idiomatic way to indicate we are calling `run` for its side effects only.
  For the error type, we used the trait object `Box<dyn Error>` and
  brought `std::error::Error` into scope. Trait objects will be covered in
  Chapter 18, but for now just know that `Box<dyn Error>` means the function
  will return a type that implements the `Error` trait, but we don't have to
  specify the particular type. This gives us flexibility to return error values
  of different types for different error cases. This is a lot cleaner than the
  panic caused by `expect`.
- If we run this now, we get a warning that we are ignoring the resulting value
  and that it might indicate an error occurred. It's so helpful:

  ```rs
  // ch12_minigrep/src/main.rs
  fn main() {
      // --snip--

      println!("Searching for {}", config.query);
      println!("In file {}", config.file_path);

      if let Err(e) = run(config) {
          println!("Application error: {e}");
          process::exit(1);
      }
  }
  ```

- In this case, `run` doesn't return a value we want to unwrap, so we'll just
  check for the `Err`. Now it's time to start our library code:

  ```rs
  // ch12_minigrep/src/lib.rs
  pub fn search<'a>(query: &str, contents: &'a str) -> Vec<&'a str> {
      unimplemented!();
  }

  // ch12_minigrep/src/main.rs
  use minigrep::search;
  // --snip--
  fn run(config: Config) -> Result<(), Box<dyn Error>> {
      let contents = fs::read_to_string(config.file_path)?;

      for line in search(&config.query, &contents) {
          println!("{line}");
      }

      Ok(())
  }
  ```

- The `unimplemented!` macro is just a placeholder that panics. It's also a good
  time to remove the two `println!` calls in `main` that print our arguments.
  Now we're moving on with more module code that handles errors well, and the
  work that is left is mostly in *src/lib.rs*.

### 12.4 - Adding Functionality with Test-Driven Development

- We're working in the *src/lib.rs* and we're working test first.

  ```rs
  // ch12_minigrep/src/lib.rs
  pub fn search<'a>(query: &str, contents: &'a str) -> Vec<&'a str> {
      unimplemented!();
  }

  #[cfg(test)]
  mod tests {
      use super::*;

      #[test]
      fn one_result() {
          let query = "duct";
          let contents = "\
  Rust:
  safe, fast, productive.
  Pick three.";

          assert_eq!(vec!["safe, fast, productive."], search(query, contents));
      }
  }
  ```

- First, we make our `search` function return an empty `vec!` so everything will
  compile and we can see our assertion fail:

  ```rs
  // ch12_minigrep/src/lib.rs
  pub fn search<'a>(query: &str, contents: &'a str) -> Vec<&'a str> {
      vec![]
  }
  ```

- It's worth mentioning our lifetime annotations. We're simply making it clear
  to the compiler that the string slices we return in the `Vec` refer to
  `contents` not `query` and will be valid as long as `contents` is valid.
  If we failed to include the annotation, the compiler would helpfully suggest
  we annotate all the arguments and return value with the same lifetime, but
  we know that our references will be to `contents`, not `query`, so `query`
  doesn't need a lifetime.
- So now we need `search` to do something for real to make the test pass:

  ```rs
  // ch12_minigrep/src/lib.rs
  pub fn search<'a>(query: &str, contents: &'a str) -> Vec<&'a str> {
      let mut results = Vec::new();

      for line in contents.lines() {
          if line.contains(query) {
              results.push(line);
          }
      }

      results
  }
  ```

- And our tests are green. We could use this opportunity to refactor, but
  `search` doesn't look half bad. There are some useful iterator features we
  aren't using, so we will revisit this project in Chapter 13. So basically by
  passing one test, we've implemented the whole program! Try it at the command
  line, it greps text just fine.

### 12.5 - Working with Environment Variables

- We will add a feature to turn on case insensitive searching by setting an
  environment variable. We could make it a command line option, but with an
  environment variable it can be set once for that terminal session.

  ```rs
  // ch12_minigrep/src/lib.rs
  #[cfg(test)]
  mod tests {
      use super::*;

      #[test]
      fn case_sensitive() {
          let query = "duct";
          let contents = "\
  Rust:
  safe, fast, productive.
  Pick three.
  Duct tape.";

          assert_eq!(vec!["safe, fast, productive."], search(query, contents));
      }

      #[test]
      fn case_insensitive() {
          let query = "rUsT";

          let contents = "\
  Rust:
  safe, fast, productive.
  Pick three.
  Trust me.";

          assert_eq!(
              vec!["Rust:", "Trust me."],
              search_case_insensitive(query, contents)
          );
      }
  }
  ```

- Note that we modified our first test case by renaming it and adding a line to
  `contents` that says "Duct tape." and shouldn't match "duct" in all
  lowercase. So we need a new function. First we make it a carbon copy of
  `search` to make sure our new test fails with a good error. Then we modify it
  to lowercase both its `query` and `contents`:

  ```rs
  // ch12_minigrep/src/lib.rs
  pub fn search_case_insensitive<'a>(
      query: &str,
      contents: &'a str,
  ) -> Vec<&'a str> {
      let query = query.to_lowercase();
      let mut results = Vec::new();

      for line in contents.lines() {
          if line.to_lowercase().contains(&query) {
              results.push(line);
          }
      }

      results
  }
  ```

- Since `to_lowercase` creates new data rather than referencing existing data,
  `query` is now a `String` instead of a string slice and we need to pass a
  reference to `contains` which takes a string slice.
- So our new function works. We are going to need to call it from `run` but
  first we need to add a field to our struct for the new option. Note that this
  will break the build, because we aren't initializing the field anywhere yet:

  ```rs
  // ch12_minigrep/src/main.rs
  pub struct Config {
      pub query: String,
      pub file_path: String,
      pub ignore_case: bool,
  }

  // same file
  use minigrep::{search, search_case_insensitive};

  // --snip--
  fn run(config: Config) -> Result<(), Box<dyn Error>> {
      let contents = fs::read_to_string(config.file_path)?;

      let results = if config.ignore_case {
          search_case_insensitive(&config.query, &contents)
      } else {
          search(&config.query, &contents)
      };

      for line in results {
          println!("{line}");
      }

      Ok(())
  }
  ```

- We've already done `use std::env` so we have access to the functions to work
  with environment variables.

  ```rs
  // ch12_minigrep/src/main.rs
  impl Config {
      fn build(args: &[String]) -> Result<Config, &'static str> {
          if args.len() < 3 {
              return Err("not enough arguments");
          }

          let query = args[1].clone();
          let file_path = args[2].clone();

          let ignore_case = env::var("IGNORE_CASE").is_ok();

          Ok(Config {
              query,
              file_path,
              ignore_case,
          })
      }
  }
  ```

- We don't actually care about the value of `IGNORE_CASE`, just that it is set.
  So we can just call `is_ok` to make sure `var` returns an `Ok` and not an
  `Err`. Testing the changes (beyond the tests of the library that pass) is as
  simple as running `cargo run -- to poem.txt` and
  `IGNORE_CASE=1 cargo run -- to poem.txt`.

### 12.6 - Redirecting Errors to Standard Error

- The `println!` macro only prints to `stdout`, so we need something else to
  print to `stderr`. If we run `cargo run > output.txt` we see our error goes to
  the file instead of the screen. All our error handling code is in `main`, so
  it's a pretty simple update. We use `eprintln!` to print to `stderr`:

  ```rs
  // ch12_minigrep/src/main.rs
  fn main() {
      let args: Vec<String> = env::args().collect();

      let config = Config::build(&args).unwrap_or_else(|err| {
          eprintln!("Problem parsing arguments: {err}");
          process::exit(1);
      });

      if let Err(e) = run(config) {
          eprintln!("Application error: {e}");
          process::exit(1);
      }
  }
  ```

## Chapter 13 - Functional Language Features: Iterators and Closures

### 13.1 - Closures

### 13.2 - Processing a Series of Items with Iterators

### 13.3 - Improving our I/O Project

### 13.4 - Performance in Loops vs Iterators
