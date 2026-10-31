# 100 Exercises To Learn Rust

---

- Site: <https://rust-exercises.com>
- Repo: <https://github.com/mainmatter/100-exercises-to-learn-rust>

---

- I actually did this book through JetBrains Academy in the RustRover IDE, so my
  changes aren't actually in the code folder. But if I have any notes, I'll be
  sure to include them here in my repo. Maybe after I finished, I put the
  solutions branch in my book-notes repo for comparison review since I didn't
  put my solutions in the repo.

## Introduction

- We switched off AI code completion. Otherwise when doing this project it
  won't give you time to answer. Go to
  **Settings | Editor | General | Code Completion | Inline** and clear the
  **Enable inline completion using language models** checkbox. Feel free to
  turn that back on later.
- I'm not going to write notes for all the trivial syntax details. I can
  just go to <https://learnxinyminutes.com/rust/> if I forget how to write a
  function or type a comment. I also took full notes on language features in
  my book notes for *The Rust Programming Language*.

## A Basic Calculator

- Rust does no automatic type conversion, even when the conversion is lossless.
- If the condition of an `if` statement is not a boolean, you get a compiler
  error. There are no truthy or falsy values.
- They suggest setting `overflow-checks = true` in release mode. You can do this
  in your *Cargo.toml*:

  ```toml
  [profile.release]
  overflow-checks = true
  ```

- If the target type can be inferred, you can cast with `as _` instead of
  specifying the type: `let c: u64 = a as _;`.
- `as` conversions are infallible. When going from a larger to a smaller type, the
  upper bits are truncated. It is better to use it when going from smaller to
  larger.

## Ticket v1

- Our running example is going to be a `Ticket`.

  ```rs
  struct Ticket {
      title: String,
      description: String,
      status: String,
  }

  // And we can create one like so:
  let ticket = Ticket {
      title: "Build a ticket system".into(),
      description: "A Kanban board".into(),
      status: "Open".into(),
  };

  // And we can define methods
  impl Ticket {
      fn new(title: String, description: String, status: String) -> Ticket {
          if title.is_empty() {
              panic!("Title cannot be empty");
          }
          if title.len() > 50 {
              panic!("Title cannot be longer than 50 bytes");
          }
          if description.is_empty() {
              panic!("Description cannot be empty");
          }
          if description.len() > 500 {
              panic!("Description cannot be longer than 500 bytes");
          }
          if status != "To-Do" && status != "In Progress" && status != "Done" {
              panic!("Only `To-Do`, `In Progress`, and `Done` statuses are allowed");
          }

          Ticket {
              title,
              description,
              status,
          }
      }

      fn is_open(&self) -> bool {
          self.status == "Open"
      }
  }
  ```

- Methods that take `self` are called like `ticket.is_open()`. Other methods are
  *static methods* and called like
  `let ticket2 = Ticket::new("My ticket".into(), "The best ticket".into(), "Open".into());`.
- Module rules can seem complicated, but you can handle 90% of situations by
  remembering that everything is private by default unless it is marked `pub`
  or access by a descendant (child/grandchild module).
- Common visibility modifiers:
  - `pub` makes a module, struct, method, etc., public, i.e. accessible from
    outside the module where it's defined, potentially from other crates.
  - `pub(crate)` makes a module, struct, method, etc., public within the crate.
  - `pub(super)` makes a module, struct, method, etc., public within the parent
    module.
  - `pub(in <module>)` makes a module, struct, method, etc., public within the
    specified module.
- Remember struct fields are private even when their struct is declared `pub`.
  This is by design so you can expose a type publicly while still forcing
  consumers to go through your constructor and getters/setters to guarantee
  invariants.
- Rust doesn't have a built-in way to generate accessor methods for you. You
  write them yourself like any other method. In other languages you might see
  `get_field()` and `set_field()`. In Rust, you just define methods like
  `field()` and `set_field()`. Example:

  ```rust
  impl Ticket {
      pub fn title(&self) -> &str {
          &self.title
      }

      pub fn set_title(&mut self, title: String) {
          self.title = title;
      }
  }
  ```

- Rust's ownership system is designed to ensure that:
  - Data is never mutated while it's being read
  - Data is never read while it's being mutated
  - Data is never accessed after it has been destroyed
- In Rust, each value has an **owner**, statically determined at compile-time.
  There is only one owner for each value at any given time. Ownership can be
  transferred. When the owner goes out of scope, the value is dropped.
- **borrowing** allows methods to read the value of a variable without taking
  ownership of it.
- You can have multiple **references** to a value, but they must all be
  immutable. You cannot have both mutable and immutable references at the same
  time. You also cannot have more than one mutable reference. And if you have
  a mutable reference, the owner cannot read or mutate the value. If you have
  immutable references to a value, the owner cannot mutate the value either.
  So an immutable reference acts like a "read-only" lock, and a mutable one is
  like a "read-write' lock. You can only create a mutable reference to a
  mutable variable.
- The compiler checks these rules at compile time, so you get compile errors
  instead of runtime errors.
- You can use the **reference** keyword `&` to create an immutable reference
  and the **mutable reference** keyword `&mut` to create a mutable reference.
  Example:

  ```rust
  let x = 5;
  let y = &x;

  let mut z = 10;
  let w = &mut z;
  ```

- `&` and `&mut` in front of a variable create an immutable or mutable
  reference, but `&` and `&mut` in front of a type denote a different type, a
  reference to the original type. Example:

  ```rust
  let x: i32 = 5;
  let y: &i32 = &x;

  let mut z: i32 = 10;
  let w: &mut i32 = &mut z;
  ```

- There are two common ways to code setters in Rust. One is to take `self` as
  input and return a new `self` transferring ownership. The other way is to take
  `&mut self` as input and return `()`.

  ```rs
  impl Ticket {
      pub fn set_title(mut self, new_title: String) -> Self {
          // Validate the new title [...]
          self.title = new_title;
          self
      }
  }

  // You would use this implementation like this;
  let ticket = Ticket::new(
      "Title".into(),
      "Description".into(),
      "To-Do".into()
  );
  let ticket = ticket.set_title("New title".into());

  // Or even:
  let ticket = ticket
    .set_title("New title".into())
    .set_description("New description".into())
    .set_status("In Progress".into());

  impl Ticket {
      pub fn set_title(&mut self, new_title: String) {
          // Validate the new title [...]
          self.title = new_title;
      }
  }

  // You'd use it like this:
  let mut ticket = Ticket::new(
      "Title".into(),
      "Description".into(),
      "To-Do".into()
  );
  ticket.set_title("New title".into());

  // But you can't chain calls with a mutable reference. If you want to modify
  // multiple fields, you would:
  ticket.set_title("New title".into());
  ticket.set_description("New description".into());
  ticket.set_status("In Progress".into());
  ```

- Note that working with immutable objects might be expensive in other
  languages, but these two operations often compile down to the same machine
  code in Rust. Rust tends to prefer `&mut self` since using the immutable
  form requires you to own the struct to call the setter. So you could not
  call `ticket.set_title("Title");` if `ticket` was inside a `Vec<Ticket>`
  or stored behind a reference or smart pointer.
- According to the official
  [Rust API Guidelines](https://rust-lang.github.io/api-guidelines/naming.html),
  there is a naming convention to distinguish between these two patterns:
  - `set_*(&mut self, ...)` is used for in-place mutation.
  - `with_*(mut self, ...) -> Self` is used for consuming / fluent methods.

  Many production crates provide both to give consumers the best of both
  worlds:

  ```rust
  impl Ticket {
      // In-place mutation (great for collections or references)
      pub fn set_title(&mut self, new_title: String) {
          self.title = new_title;
      }

      // Consuming builder / fluent method (great for chaining & rebinding)
      pub fn with_title(mut self, new_title: String) -> Self {
          self.title = new_title;
          self
      }
  }

  // Chained, immutable construction:
  let ticket = Ticket::new("Title".into(), "Desc".into(), "To-Do".into())
      .with_title("New Title".into())
      .with_status("In Progress".into());
  ```

- You see this pattern everywhere across std and major ecosystem crates:
  - `Config::default().with_port(8080).with_host("localhost")`
  - `Command::new("ls").with_arg("-la")`
  - `Request::get("/").with_header("Accept", "text/plain")`
- You can use `std::mem::size_of::<T>` to see how much space a type takes on the
  stack: `assert_eq!(std::mem::size_of::<u8>(), 1);`. Note that `size_of` only
  measures the shallow, in-line footprint of a type at compile time, never any
  dynamically allocated heap memory it points to. There is no general-purpose
  API to determine size on the heap, but you can use a memory profile to inspect
  heap usage.
- Note that the size of a type can be surprising due to memory alignment and
  padding. A tuple of two `bool` is really only two bytes, but, for example,
  `bool` is 1 byte and `u32` is 4 bytes, but a tuple of
  `(bool, u32)` is 8 bytes, not 5! This is because Rust automatically adds 3
  bytes of padding after the `bool` so that the `u32` starts on an address
  aligned to a multiple of its 4-byte size.
- A `Vec<T>` is a tuple of a pointer to a heap-allocated array, the capacity
  of that array, and the length of the array. So `Vec<T>` itself is usually 24
  bytes (3 * 8 bytes on a 64-bit system). This is true regardless of the size
  of `T`! So `Vec<u8>` and `Vec<u64>` are both 24 bytes. This is because the
  `Vec<T>` struct only stores the pointer, capacity, and length. The actual
  data is stored on the heap.
  - `std::mem::size_of::<u8>()` is 1 byte.
  - `std::mem::size_of::<u64>()` is 8 bytes.
  - `std::mem::size_of::<Vec<u8>>()` is 24 bytes.
  - `std::mem::size_of::<Vec<u64>>()` is 24 bytes.
  - `std::mem::size_of::<String>()` is 24 bytes.
  - `std::mem::size_of::<Vec<String>>()` is 24 bytes.
  - Most references are a pointer so are 8 bytes. A pointer to a string is a
    `usize` reference to the memory location where the string's metadata is
    stored. Not all pointers point to the heap!
  - Note that these values assume a 64-bit system. On a 32-bit system, they
    would be half the size.
- Why is `String` 24 bytes? While most `String` data lives on the heap, a
  small, constant-size portion lives on the stack. This buffer handle stores:
  1. The address of the heap data (`*mut u8`, 8 bytes)
  2. The length of the string in bytes (`usize`, 8 bytes)
  3. The capacity of the allocated memory (`usize`, 8 bytes)
- So while `String`'s contents can grow, its on-stack footprint stays constant.
  This is the exact same reason `Vec<T>` is always 24 bytes on the stack
  regardless of the size of `T`: it only stores a pointer to `T`, a capacity
  count, and a length count.
- `std` doesn't allocate when you call `String::new()`. Heap data will be
  reserved when you push onto the `String` for the first time.
- Scope has two meanings in Rust. There is lexical scope where a variable is in
  scope until the block in which the variable is declared ends. A variables
  scope is also ended if ownership is transferred to someone else. In both
  cases the variable is dropped when it goes out of scope.
- When a variable goes out of scope, Rust invokes its **destructor**. You can
  manually invoke the destructor by passing the variable to `std::mem::drop`.
  When you transfer ownership, you are transferring responsibility for cleaning
  up the resource. This ensures the destructor is called at most once.
- Outro Solution:

  > [!NOTE]
  > The course exercise tests required returning `&i32` to drill borrowing
  > syntax before introducing the `Copy` trait in Chapter 4. In idiomatic Rust,
  > small `Copy` types are always returned by value (`i32`), so we use `i32`
  > below.

  ```rust
  pub struct Order {
      product_name: String,
      quantity: i32,

      /// unit_price is in cents
      unit_price: i32,
  }

  impl Order {
      pub fn product_name(&self) -> &String {
          &self.product_name
      }

      pub fn quantity(&self) -> i32 {
          self.quantity
      }

      pub fn unit_price(&self) -> i32 {
          self.unit_price
      }

      pub fn total(&self) -> i32 {
          self.quantity * self.unit_price
      }

      pub fn set_product_name(&mut self, product_name: String) {
          Order::validate_product_name(&product_name);
          self.product_name = product_name;
      }

      pub fn set_quantity(&mut self, quantity: i32) {
          Order::validate_quantity(quantity);
          self.quantity = quantity;
      }

      pub fn set_unit_price(&mut self, unit_price: i32) {
          Order::validate_unit_price(unit_price);
          self.unit_price = unit_price;
      }

      pub fn new(product_name: String, quantity: i32, unit_price: i32) -> Self {
          Order::validate_product_name(&product_name);
          Order::validate_quantity(quantity);
          Order::validate_unit_price(unit_price);

          Self {
              product_name,
              quantity,
              unit_price,
          }
      }

      fn validate_product_name(product_name: &String) {
          if product_name == "" {
              panic!("The product name cannot be empty");
          }

          if product_name.len() > 300 {
              panic!("The product name cannot be longer than 300 bytes");
          }
      }

      fn validate_quantity(quantity: i32) {
          if quantity <= 0 {
              panic!("The quantity cannot be 0 or negative");
          }
      }

      fn validate_unit_price(unit_price: i32) {
          if unit_price <= 0 {
              panic!("The unit price cannot be 0 or negative");
          }
      }
  }
  ```

## Traits
