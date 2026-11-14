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

## Chapter 1 - Introduction

- We switched off AI code completion. Otherwise when doing this project it won't
  give you time to answer. Go to **Settings | Editor | General | Code Completion
  | Inline** and clear the **Enable inline completion using language models**
  checkbox. Feel free to turn that back on later.
- I'm not going to write notes for all the trivial syntax details. I can just go
  to <https://learnxinyminutes.com/rust/> if I forget how to write a function or
  type a comment. I also took full notes on language features in my book notes
  for _The Rust Programming Language_.

## Chapter 2 - A Basic Calculator

- Rust does no automatic type conversion, even when the conversion is lossless.
- If the condition of an `if` statement is not a boolean, you get a compiler
  error. There are no truthy or falsy values.
- They suggest setting `overflow-checks = true` in release mode. You can do this
  in your _Cargo.toml_:

  ```toml
  [profile.release]
  overflow-checks = true
  ```

- If the target type can be inferred, you can cast with `as _` instead of
  specifying the type: `let c: u64 = a as _;`.
- `as` conversions are infallible. When going from a larger to a smaller type,
  the upper bits are truncated. It is better to use it when going from smaller
  to larger.

## Chapter 3 - Ticket v1

### Structs & Methods

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

- Methods that take `self` are called like `ticket.is_open()`. Methods without
  `self` are called **associated functions** (referred to as _static methods_ in
  other languages) and called like
  `let ticket2 = Ticket::new("My ticket".into(), "The best ticket".into(), "Open".into());`.

### Modules & Visibility

- Module rules can seem complicated, but you can handle 90% of situations by
  remembering that everything is private by default unless it is marked `pub` or
  accessed by a descendant (child/grandchild module).
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

### Accessor Methods & Builders

- Rust doesn't have a built-in way to generate accessor methods for you. You
  write them yourself like any other method. In other languages you might see
  `get_field()` and `set_field()`. In Rust, you just define methods like
  `field()` and `set_field()`. Example:

  ```rs
  impl Ticket {
      pub fn title(&self) -> &str {
          &self.title
      }

      pub fn set_title(&mut self, title: String) {
          self.title = title;
      }
  }
  ```

### Ownership, Borrowing & References

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
  time. You also cannot have more than one mutable reference. And if you have a
  mutable reference, the owner cannot read or mutate the value. If you have
  immutable references to a value, the owner cannot mutate the value either. So
  an immutable reference acts like a "read-only" lock, and a mutable one is like
  a "read-write" lock. You can only create a mutable reference to a mutable
  variable.
- The compiler checks these rules at compile time, so you get compile errors
  instead of runtime errors.
- You can use the **reference** keyword `&` to create an immutable reference and
  the **mutable reference** keyword `&mut` to create a mutable reference.
  Example:

  ```rs
  let x = 5;
  let y = &x;

  let mut z = 10;
  let w = &mut z;
  ```

- `&` and `&mut` in front of a variable create an immutable or mutable
  reference, but `&` and `&mut` in front of a type denote a different type, a
  reference to the original type. Example:

  ```rs
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

  // You would use this implementation like this:
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
  code in Rust. Rust tends to prefer `&mut self` since using the immutable form
  requires you to own the struct to call the setter. So you could not call
  `ticket.set_title("Title");` if `ticket` was inside a `Vec<Ticket>` or stored
  behind a reference or smart pointer.
- According to the official
  [Rust API Guidelines](https://rust-lang.github.io/api-guidelines/naming.html),
  there is a naming convention to distinguish between these two patterns:
  - `set_*(&mut self, ...)` is used for in-place mutation.
  - `with_*(mut self, ...) -> Self` is used for consuming / fluent methods.

  Many production crates provide both to give consumers the best of both worlds:

  ```rs
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

### Memory Layout & Alignment

- You can use `std::mem::size_of::<T>()` to see how much space a type takes on
  the stack: `assert_eq!(std::mem::size_of::<u8>(), 1);`. Note that `size_of`
  only measures the shallow, in-line footprint of a type at compile time, never
  any dynamically allocated heap memory it points to. There is no
  general-purpose API to determine size on the heap, but you can use a memory
  profiler to inspect heap usage.
- Note that the size of a type can be surprising due to memory alignment and
  padding. A tuple of two `bool` is really only two bytes, but, for example,
  `bool` is 1 byte and `u32` is 4 bytes, but a tuple of `(bool, u32)` is 8
  bytes, not 5! This is because Rust automatically adds 3 bytes of padding after
  the `bool` so that the `u32` starts on an address aligned to a multiple of its
  4-byte size.
- A `Vec<T>` is a tuple of a pointer to a heap-allocated array, the capacity of
  that array, and the length of the array. So `Vec<T>` itself is usually 24
  bytes (3 \* 8 bytes on a 64-bit system). This is true regardless of the size
  of `T`! So `Vec<u8>` and `Vec<u64>` are both 24 bytes. This is because the
  `Vec<T>` struct only stores the pointer, capacity, and length. The actual data
  is stored on the heap.
  - `std::mem::size_of::<u8>()` is 1 byte.
  - `std::mem::size_of::<u64>()` is 8 bytes.
  - `std::mem::size_of::<Vec<u8>>()` is 24 bytes.
  - `std::mem::size_of::<Vec<u64>>()` is 24 bytes.
  - `std::mem::size_of::<String>()` is 24 bytes.
  - `std::mem::size_of::<Vec<String>>()` is 24 bytes.
  - Most references are a pointer, so they take 8 bytes on a 64-bit system. A
    reference to a string (`&String`) is an 8-byte pointer to the 24-byte
    metadata header on the stack, not directly to the heap buffer. Not all
    pointers point to the heap!
  - Note that these values assume a 64-bit system. On a 32-bit system, they
    would be half the size.
- Why is `String` 24 bytes? While most `String` data lives on the heap, a small,
  constant-size portion lives on the stack. This buffer handle stores:
  1. The address of the heap data (`*mut u8`, 8 bytes)
  2. The length of the string in bytes (`usize`, 8 bytes)
  3. The capacity of the allocated memory (`usize`, 8 bytes)
- So while `String`'s contents can grow, its on-stack footprint stays constant.
  This is the exact same reason `Vec<T>` is always 24 bytes on the stack
  regardless of the size of `T`: it only stores a pointer to `T`, a capacity
  count, and a length count.
- `std` doesn't allocate when you call `String::new()`. Heap data will be
  reserved when you push onto the `String` for the first time.

### Scope & Destructors

- Scope has two meanings in Rust:
  1. **Lexical scope**: a variable is in scope until the end of the block in
     which it was declared.
  2. **Ownership scope**: a variable's scope ends early if ownership is
     transferred to someone else (a move). When a variable reaches the end of
     its lexical scope without being moved, Rust invokes its **destructor** and
     drops the value. If ownership was transferred, the original variable is no
     longer responsible for it, ensuring the destructor is called at most once.
     You can also manually invoke the destructor early with `std::mem::drop`.

### Outro - Order Struct

> [!NOTE] The course exercise tests required returning `&i32` to drill borrowing
> syntax before introducing the `Copy` trait in Chapter 4. In idiomatic Rust,
> small `Copy` types are always returned by value (`i32`), so we use `i32`
> below.

```rs
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
        if product_name.is_empty() {
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

## Chapter 4 - Traits

### Defining Traits

- Our `Ticket` struct can appear in assertions like
  `assert_eq!(ticket.title(), "A new title");` because `String` implements the
  `PartialEq` trait. But we couldn't create two tickets and do
  `assert_eq!(ticket1, ticket2)` or `ticket1 == ticket2`. For the latter, the
  error would be
  ``error[E0369]: binary operation `==` cannot be applied to type `Ticket` ``
  with the helpful suggestion
  ``note: an implementation of `PartialEq` might be missing for `Ticket` ``.
  `Ticket` is a new type, and out of the box it has no behavior attached to it.
  Traits are Rust's way of defining **interfaces**. A trait defines a set of
  methods that a type must implement to satisfy the trait's contract.
- The syntax for trait definition and implementation is straightforward:

  ```rs
  trait <TraitName> {
      fn <method_name>(<parameters>) -> <return_type>;
  }

  impl <TraitName> for <TypeName> {
      fn <method_name>(<parameters>) -> <return_type> {
          // Method body
      }
  }
  ```

- For example:

  ```rs
  pub trait IsEven {
      fn is_even(&self) -> bool;
  }

  impl IsEven for u32 {
      fn is_even(&self) -> bool {
          self % 2 == 0
      }
  }

  impl IsEven for i32 {
      fn is_even(&self) -> bool {
          self % 2 == 0
      }
  }
  ```

- Trait methods are invoked like instance methods but they require both that the
  trait be implemented for the receiver type AND that the trait is in scope. The
  latter requirement often requires a `use` statement for the trait unless it's
  defined in the same module or in the prelude.

### Default Implementations

- When defining a trait, you can optionally provide a default method body that
  implementers can use if they choose to not define their own. When using the
  default, you leave the `impl` block empty like `impl IsEven for i32 {}`. If a
  trait requires a mix of required and default methods, you implement all the
  required methods and don't mention the default ones. Rust will use the default
  implementation for any methods you don't explicitly implement. Many provided
  default methods are additional methods that call the required methods to
  provide some result based upon it.
- Overriding the default definition of a method when implementing a trait is the
  only real "override" in Rust, since there is no inheritance. There is seldom a
  reason to override a default unless knowledge of your type allows you to
  provide a more performant implementation than the generic default method or
  when overriding a "no-op" default in a hook or event-handler.

### Extension Traits & The Orphan Rule

- When a type is defined in another module, you cannot define new methods on it.
  The primary purpose of an _extension trait_ is to add methods to types defined
  elsewhere, like above where we implement `IsEven` for `i32` and `u32`. You
  cannot implement the same trait twice in a crate for the same type. Also, at
  least one of the following must be true:
  - The trait is defined in the current crate
  - The implementor is defined in the current crate
- The previous two points make up Rust's **orphan rule**. Put simply, you can
  define a new trait for a foreign type or you can define a foreign trait for a
  new type or you can even define a new trait for a new type, but you cannot
  define a foreign trait for a foreign type. At least one of the trait or the
  type must be defined in the current crate.

### Operator Overloading

- In Rust, operators are traits. For each operator, there is a corresponding
  trait that defines the behavior of that operator. By implementing the trait
  for your type, you unlock the usage of the corresponding operator(s). For
  example, `PartialEq` defines the behavior of `==` and `!=`.

  ```rs
  // The `PartialEq` trait definition, from Rust's standard library
  // (It is *slightly* simplified, for now)
  pub trait PartialEq {
      // Required method
      //
      // `Self` is a Rust keyword that stands for
      // "the type that is implementing the trait"
      fn eq(&self, other: &Self) -> bool;

      // Provided method
      fn ne(&self, other: &Self) -> bool {
          !self.eq(other)
      }
  }
  ```

- Arithmetic operators are defined in `std::ops` and comparison operators in
  `std::cmp`. The operator usage is replaced by the underlying trait method
  calls:
  - Addition (+): `std::ops::Add`
  - Subtraction (-): `std::ops::Sub`
  - Multiplication (\*): `std::ops::Mul`
  - Division (/): `std::ops::Div`
  - Remainder (%): `std::ops::Rem`
  - Bitwise AND (&): `std::ops::BitAnd`
  - Bitwise OR (|): `std::ops::BitOr`
  - Bitwise XOR (^): `std::ops::BitXor`
  - Left shift (<<): `std::ops::Shl`
  - Right shift (>>): `std::ops::Shr`
  - Equality (==, !=): `std::cmp::PartialEq`
  - Ordering (<, >, <=, >=): `std::cmp::PartialOrd`
- There is also a `std::cmp::Eq` and `std::cmp::Ord` that can be used as trait
  bounds, although the Partial traits are what the operators care about. This is
  primarily because of floats. All the primitives except floats implement `Eq`
  and `Ord`, but floats don't because `NaN != NaN` and `NaN <= 1.0` and
  `1.0 <= NaN` are both `false`. This is why floats can't be keys in a
  `HashMap<K, V>` or `BTreeMap<K, V>`, be part of a `BTreeSet<T>`, or be sorted
  in a `Vec<T>` which have trait bounds on `Eq` or `Ord`. If you want to sort a
  `Vec<f64>` you can do so with `vec.sort_by(...)`. The `partial_cmp` function
  defined by `PartialOrd` returns an `Option<Ordering>` which is `None` when
  `NaN` is involved, but the operators (</>/<=/>) are defined by the provided
  `lt`/`le`/`ge`/`gt` methods which return `false` when the result of
  `partial_cmp` would have been `None`, and the unwrapped `bool` otherwise.
- Going back to our running example of a ticket system, what if we wanted to be
  able to compare two `Ticket` instances with `==`?

  ```rs
  impl PartialEq for Ticket {
      fn eq(&self, other: &Self) -> bool {
          self.title == other.title
              && self.description == other.description
              && self.status == other.status
      }
  }
  ```

- If we add a field, we have to change the definition, and that's easy to
  forget. We could make up for this by destructuring our struct at the start of
  the `eq` method. Then if we add a field we will get a compiler error for
  incomplete destructuring.

  ```rs
  impl PartialEq for Ticket {
      fn eq(&self, other: &Self) -> bool {
          let Ticket {
              title,
              description,
              status,
          } = self;
          // [...]
      }
  }
  ```

### Deriving Traits

- It's still a bit tedious for testing the equality of each field one at a time
  though. Instead Rust allows us to derive the implementations of common traits.
  To do this, we add `#[derive(<TraitName>)]` above the struct (or enum)
  definition.

  ```rs
  #[derive(PartialEq)]
  pub struct Ticket {
      title: String,
      description: String,
      status: String,
  }
  ```

- Macros are simply code generators, and the derive macro writes code almost
  identically to how we did it manually. The advantages are:
  - You don't have to write it
  - It automatically includes any new fields without manual updates
- Another commonly derived trait is `Debug`. It allows you to output the value
  in a way that is useful for debugging. It is often used for testing, along
  with `PartialEq`, since both `assert_eq` and `assert_ne` use `Debug` to format
  the output when the assertion fails and `PartialEq` to enable the comparison.
  You can also call `println!("{:?}", ticket);` (and
  `println!("{:#?}", ticket);` for pretty-printed output) to print the value in
  a debug format.

  ```rs
  #[derive(Debug, PartialEq)]
  pub struct Ticket {
      title: String,
      description: String,
      status: String,
  }
  ```

### Generics & Trait Bounds

- So we have seen traits for unlocking "built-in" behavior (operator
  overloading) and using traits to add methods to existing types (extension
  traits), but traits are also used to specify behavior that generic code
  requires. This is known as using traits as **trait bounds**. We have been
  using concrete types so far. This leads to easy to write and understand code,
  but it also tends to lead to duplication. Generics allow us to write code that
  works with a **type parameter** instead of a concrete type. Instead of
  defining a function for every type of primitive that implements the `IsEven`
  trait, we could define `print_if_even` as follows:

  ```rs
  fn print_if_even<T>(n: T)
  where
      T: IsEven + Debug
  {
      if n.is_even() {
          println!("{n:?} is even");
      }
  }
  ```

- This function works for every type that implements both `IsEven` and `Debug`.
  `print_if_even` is a **generic function**. T is a **type parameter** and
  `IsEven + Debug` is a **trait bound**. The `+` allows us to specify more than
  one trait bound. Without them, the code can not compile. A bare `T` has no
  behavior at all from the compiler's point of view, but the trait bounds
  constrain the type parameter to only types that implement the specified
  traits, letting us know it is legal to, for example, call `is_even` and
  `Debug::fmt` on `n`.
- The `where` clause is an easy way to specify trait bounds, but you can also
  specify them inline when they don't require much room:

  ```rs
  fn print_if_even<T: IsEven + Debug>(n: T) {
      //           ^^^^^^^^^^^^^^^^^
      //           This is an inline trait bound
      // [...]
  }
  ```

- **Inline vs. `where` clauses**: Use inline bounds (`<T: Debug>`) for short,
  simple constraints. Switch to a `where` clause when bounds get complex or
  multiple parameters are involved, keeping the function's argument list clean
  and easy to scan.
- Type parameters use `UpperCamelCase`. `T` is standard when there is only a
  single generic type, but descriptive names (e.g., `Number: IsEven + Debug` or
  `Reader: Read`) are encouraged when multiple parameters are involved.
- **Why can't the compiler infer trait bounds from the body?** Rust deliberately
  requires explicit trait bounds on function signatures as an explicit contract
  between caller and callee. This prevents internal implementation changes from
  accidentally breaking external callers and enables fast, modular type
  checking.

### String Slices & Memory Layout

- So far we have been using string literals liberally with calls to `.to_string`
  or `.into`. When you define a string literal such as `let s = "Hello";`, it
  has the type `&str`; it is a reference to a string slice. If you defined your
  string like `let mut s = String::new(); s.push_str("Hello");`, then `s` has
  the type `String`. Using `String` is more expensive than using `&str` because
  it involves allocating memory on the heap. For the `String` variable, we store
  a pointer to the heap, a length (`usize`), and a capacity (`usize`) for a
  total of 24 bytes on the stack. If we refer to `&s`, it is a usize pointer to
  the 24 bytes on the stack, which itself contains a pointer to the heap.
  Whether we use `&s` (a `&String`) or `slice` (a `&str`), the underlying bytes
  remain on the heap without copying. A `&str` is a view into a string, a
  reference to a sequence of UTF-8 bytes stored elsewhere. Given our `String`
  `s`, we could define `let slice: &str = &s[1..];`. This creates a string slice
  of the string `s` starting from the second byte (index 1) to the end of the
  string. It does not create a new string, it just creates a new view into the
  existing string. In memory, `s` is still a pointer to the bytes on the heap, a
  length, and a capacity (24 bytes on the stack), and `slice` is a pointer to
  the same bytes on the heap, but with a length of 4 (16 bytes on the stack,
  with no concept of capacity). `slice` doesn't own the data; it just points to
  it. So `slice` is a reference to the `String`'s heap-allocated data. `slice`
  doesn't need to know capacity, because it isn't the owner and isn't modifying
  the data; it just points to it and tracks `length`.
- As a rule of thumb, use `&str` rather than `&String` whenever you need a
  reference to textual data. `&str` is more flexible and generally considered
  more idiomatic in Rust code. If a method returns a `&String`, you're promising
  that there is heap-allocated UTF-8 text somewhere that matches exactly the one
  you're returning a reference to. If a method returns a `&str`, instead, you
  have a lot more freedom: you're just saying that somewhere there's a bunch of
  text data and that a subset of it matches what you need, therefore you're
  returning a reference to it.
- Summary comparison of string types:

  | Type     | Role  | Stack                  | Storage   | Ownership    |
  | :------- | :---- | :--------------------- | :-------- | :----------- |
  | `String` | Owner | 24 B `(ptr, len, cap)` | Heap only | Owns & frees |
  | `str`    | Slice | N/A (`!Sized`)         | Anywhere  | N/A          |
  | `&str`   | View  | 16 B `(ptr, len)`      | Anywhere  | Borrowed     |

- **Why this matters in function signatures**:
  - **Accept `&str` instead of `&String`**: If a function takes `&String`, the
    caller _must_ allocate or own a heap `String`. If it takes `&str`, callers
    can pass string literals (`"hello"`), owned `String`s (`&my_string`), or
    slices (`&my_string[0..2]`) with **zero heap allocations**.
  - **Returning `&str`**: Promising that you're returning a view into data that
    already exists elsewhere and lives as long as the caller needs it (e.g., a
    field on `&self` or a static string).
  - **Returning `String`**: Handing the caller a brand-new, independent, owned
    piece of text that they now own, can mutate, or can keep arbitrarily long.

### Deref Trait & Deref Coercion

- So let's go back to our trusty `Ticket` and make its accessors return `&str`.

  ```rs
  pub struct Ticket {
      title: String,
      description: String,
      status: String,
  }

  impl Ticket {
      pub fn new(title: String, description: String, status: String) -> Ticket {
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

      pub fn title(&self) -> &str {
          &self.title
      }

      pub fn description(&self) -> &str {
          &self.description
      }

      pub fn status(&self) -> &str {
          &self.status
      }
  }
  ```

- Let's review some facts about the previous code. `self.title` is a `String`.
  So `&self.title` is an `&String`. So why were we able to say it returns
  `&str`? `std::ops::Deref` trait is behind the mechanism known as **deref
  coercion**.

  ```rs
  // I've slightly simplified the definition for now.
  // We'll see the full definition later on.
  pub trait Deref {
      type Target;

      fn deref(&self) -> &Self::Target;
  }
  ```

- In the above, `Target` is an **associated type**. It acts as a placeholder for
  a concrete type that must be specified when the trait is implemented. By
  implementing `Deref<Target = U>` for a type `T`, you're telling the compiler
  that `&T` and `&U` are somewhat interchangeable. Specifically:
  - References to `T` are implicitly converted into references to `U` (i.e. `&T`
    becomes `&U`).
  - You can call all methods defined on `U` that take `&self` directly on `&T`.
    Many methods used on `String` (like `.len()`, `.trim()`, `.contains()`) are
    actually defined on `str`, which matters when looking up documentation.
  - And one more thing around the dereference operator (`*`), but you don't need
    it yet.
- `String` implements `Deref` with `Target = str`, so `&String` is automatically
  converted into `&str` when needed:

  ```rs
  impl Deref for String {
      type Target = str;

      fn deref(&self) -> &str {
          // [...]
      }
  }
  ```

- Don't abuse deref coercion because it can lead to confusing code, but feel
  free to return `&str` anytime you would reach for `&String`. It makes your
  functions much more flexible.

### Sized, DSTs & Marker Traits

- `str` is a **dynamically-sized type**, or **DST**. This means that at compile
  time, the compiler doesn't know the exact size of the value. A reference to a
  DST, like `&str`, is a **fat pointer**. It contains both a pointer to the data
  and the length of the data. Trying to call `std::mem::size_of::<str>()` or
  query the size of any other DST is a compile-time error.
- Rust has a `Sized` trait, which is a **marker trait** with no methods. It is
  implemented by all types whose size is known at compile time. A marker trait
  can be used by the compiler to enable behaviors or optimizations. `Sized` is
  also an **auto trait**; the compiler implements it automatically for you based
  on the type's definition. All the types we have looked at so far are `Sized`.
  Although we don't know the size of the data `&str` is pointing to, `&str`
  itself is `Sized`. It is two `usize` values (16 bytes on 64-bit) on the stack:
  a pointer and a length.

### Conversions: From & Into

- You may remember we had to call `into` on the strings we passed in to our
  `Ticket::new` method. `From` and `Into` are two traits for **infallible
  conversions** defined by the Rust standard library.

  ```rs
  pub trait From<T>: Sized {
      fn from(value: T) -> Self;
  }

  pub trait Into<T>: Sized {
      fn into(self) -> T;
  }
  ```

- **Infallible** means that the conversion will always succeed and the `from()`
  and `into()` methods do not return a `Result` or `Option`. So they can't
  communicate any failure cases to the caller.
- The `From<T>: Sized` syntax here implies that `From` is a subtrait of `Sized`,
  or equivalently, `Sized` is a supertrait of `From`. Any type that implements
  `From` must also implement `Sized`. Additionally, any generic type parameter
  `T` has an implicit `T: Sized` bound. So both the item implementing `From` and
  the item passed to `from` must be `Sized`. You can opt out of this implicit
  bound with `T: ?Sized`. This relaxation is exclusive to `Sized`; you cannot
  use `?Trait` with other traits.
- `String` implements `From<&str>`, so we can write
  `let s = String::from("Hello");`. However, we have also been using
  `"Hello".into()`.
- `From` and `Into` are **dual traits**. `From<T>` for `U` implies `Into<U>` for
  `T`, as `Into` is just `From` implemented in reverse. In the standard library,
  this is achieved via a **blanket implementation**:

  ```rs
  impl<T, U> Into<U> for T
  where
      U: From<T>,
  {
      fn into(self) -> U {
          U::from(self)
      }
  }
  ```

- **The Golden Rule of Conversions**: **Always implement `From`, never implement
  `Into`**. Implementing `From` automatically gives you `Into` for free via the
  blanket implementation above. The reverse is not true.
- Normally the target type we are converting to is inferred from the surrounding
  function/method signature or a type annotation.
- Here is an example of implementing `From` (and `Into`) for our own type:

  ```rs
  struct WrappingU32 {
      value: u32,
  }

  impl From<u32> for WrappingU32 {
      fn from(value: u32) -> Self {
          WrappingU32 { value }
      }
  }

  fn example() {
      let wrapping: WrappingU32 = 42.into();
      let wrapping = WrappingU32::from(42);
  }

  fn main() {}
  ```

### Associated Types vs. Generic Traits

- Recall two of the traits we've examined:

  ```rs
  pub trait From<T> {
      fn from(value: T) -> Self;
  }

  pub trait Deref {
      type Target;

      fn deref(&self) -> &Self::Target;
  }
  ```

- One uses a generic type `T` and the other uses an associated type `Target`.
  Due to how deref coercion works, there can only be one `Target` for a given
  type. An associated type is uniquely determined by the trait implementation.
  Since you cannot implement `Deref` more than once, you can only specify one
  `Target`. On the other hand, you can have many implementations of `From<T>`
  for a type as long as `T` is a different type. Here is an example of multiple
  `From` implementations for the same type:

  ```rs
  impl From<u32> for WrappingU32 {
      fn from(value: u32) -> Self {
          WrappingU32 { value }
      }
  }

  impl From<u16> for WrappingU32 {
      fn from(value: u16) -> Self {
          WrappingU32 { value: value.into() }
      }
  }
  ```

- This works because `From<u32>` and `From<u16>` are considered different
  traits.
- Consider the `Add` trait. It has both an associated type `Output` and a
  generic type parameter that defaults to `Self`.

  ```rs
  pub trait Add<RHS = Self> {
      type Output;

      fn add(self, rhs: RHS) -> Self::Output;
  }
  ```

- `RHS` is a generic type to allow for addition between different types. Since
  this is a different trait for each `RHS` value, we can have different `Output`
  associated types for each `RHS` value.

  ```rs
  impl Add<u32> for u32 {
      type Output = u32;

      fn add(self, rhs: u32) -> u32 {
        //                      ^^^
        // This could be written as `Self::Output` instead.
        // The compiler doesn't care, as long as the type you
        // specify here matches the type you assigned to `Output`
        // right above.
        // [...]
      }
  }

  impl Add<&u32> for u32 {
      type Output = u32;

      fn add(self, rhs: &u32) -> u32 {
          // [...]
      }
  }

  impl Add<&u32> for &u32 {
      type Output = u32;

      fn add(self, rhs: &u32) -> u32 {
          // [...]
      }
  }
  ```

- We could have limited the output value to `Self`, but then the third example
  would be forced to return an `&u32`. Defining `Output` per instance of the
  trait implementation gives us more flexibility. `Output` could not be a
  generic type, because the `Output` type must be uniquely determined by the
  types of the operands.
- Use an associated type when the type must be uniquely determined for a given
  trait implementation.
- Use a generic parameter when you want to allow multiple implementations of the
  trait for the same type, with different input types.
- **Generic Trait vs. Generic Method ("Who chooses `T`?")**:
  - **Generic Trait (`trait Trait<T>`)**: The **implementer** chooses `T`. You
    can write distinct `impl` blocks for specific types (e.g., `Add<u32>`,
    `Add<&u32>`) with different logic or associated types for each. It is
    illegal to call the method with a type it is not implemented for.
  - **Generic Method (`trait Trait { fn method<T>(...); }`)**: The **caller**
    chooses `T`. The implementer must provide a single method body that can
    handle _any_ type `T` the caller provides (usually constrained by trait
    bounds).
  - _Rule of thumb_: If a type needs to support multiple specific types with
    different implementations, make the **trait** generic. If a single
    implementation works for any type satisfying a bound, make the **method**
    generic.

### Clone

- The rules we introduced earlier on Rust ownership and borrowing can be
  somewhat limiting:
  - Every value in Rust has a single owner at any given time.
  - When a function takes ownership of a value ("it consumes it"), the caller
    can't use that value anymore.
- Sometimes we want to call a function that takes ownership of a value but still
  use that value afterwards. If a value implements `Clone`, it has a `clone`
  method that returns a new owned instance of the same type. `Clone` creates a
  deep copy of an object. You can almost always implement `Clone` by deriving
  it.

  ```rs
  pub trait Clone {
      fn clone(&self) -> Self;
  }
  ```

- Note: In well-designed Rust APIs, functions that only need to read data should
  take a reference `&T` instead of consuming `T` and forcing the caller to
  `.clone()`. Clone is for when true, independent ownership is actually
  necessary.

### Copy

- `Copy` is another trait in Rust's standard library. It is another marker trait
  like `Sized`.

  ```rs
  pub trait Copy: Clone { }
  ```

- If a type implements `Copy`, you don't need to call `.clone()` on a value of
  that type. Rust implicitly calls it for you. `u32` is an example of a type
  that implements `Copy`. All integer types do. Types must meet a few
  requirements to implement `Copy`.
  - The type must implement `Clone`.
  - The type doesn't manage any additional resources (e.g. heap memory, file
    handles, etc.) beyond the `std::mem::size_of` bytes that it occupies in
    memory.
  - The type is not a mutable reference (`&mut T`).
- This is often referred to as a `memcpy` after the C standard library function.
- `String` doesn't implement `Copy` because it manages heap resources.
- A `&mut u32` reference does not implement `Copy` because there can only be one
  mutable borrow of a value at any given time. `&mut T` never implements `Copy`
  for any `T`.
- Most of the time, if your type meets the requirements, you should derive
  `Copy` and you can do so at the same time as deriving `Clone`.

### Drop

- The `Drop` trait is a mechanism for you to define additional cleanup logic for
  your types, beyond what the compiler does for you automatically. Whatever you
  provide in the `drop` method will be executed when the value goes out of
  scope.

  ```rs
  pub trait Drop {
      fn drop(&mut self);
  }
  ```

- If your type has a `Drop` implementation, the compiler will assume you manage
  additional resources and not allow you to implement `Copy`.

### Outro - SaturatingU16

- Don't make a function generic if it is always invoked with a single type. It
  introduces indirection in your codebase, making it harder to understand and
  maintain.
- Don't create a trait if you only have one implementation. It's a sign that the
  trait is not needed.
- Implement standard traits for your types (Debug, PartialEq, etc.) whenever it
  makes sense. It will make your types more idiomatic and easier to work with,
  unlocking a lot of functionality provided by the standard library and
  ecosystem crates.
- Implement traits from third-party crates if you need the functionality they
  unlock within their ecosystem.
- Beware of making code generic solely to use mocks in your tests. The
  maintainability cost of this approach can be high, and it's often better to
  use a different testing strategy.
- This wasn't a very instructive final outro challenge, but it had us do a lot
  of things we've been shown all in one example.

  ```rs
  use std::ops::Add;
  use std::cmp::Ordering;

  #[derive(Debug, Clone, Copy, PartialEq, PartialOrd)]
  pub struct SaturatingU16 {
      value: u16,
  }

  impl From<u16> for SaturatingU16 {
      fn from(value: u16) -> Self {
          Self { value }
      }
  }

  impl From<u8> for SaturatingU16 {
      fn from(value: u8) -> Self {
          Self {
              value: value.into(),
          }
      }
  }

  impl From<&u16> for SaturatingU16 {
      fn from(value: &u16) -> Self {
          (*value).into()
      }
  }

  impl From<&u8> for SaturatingU16 {
      fn from(value: &u8) -> Self {
          (*value).into()
      }
  }

  impl Add for SaturatingU16 {
      type Output = SaturatingU16;

      fn add(self, rhs: Self) -> Self::Output {
          self + rhs.value
      }
  }

  impl Add<&SaturatingU16> for SaturatingU16 {
      type Output = SaturatingU16;

      fn add(self, rhs: &SaturatingU16) -> Self::Output {
          self + *rhs
      }
  }

  impl Add<u16> for SaturatingU16 {
      type Output = Self;

      fn add(self, rhs: u16) -> Self::Output {
          let sum = self.value.saturating_add(rhs);
          Self { value: sum }
      }
  }

  impl Add<&u16> for SaturatingU16 {
      type Output = SaturatingU16;

      fn add(self, rhs: &u16) -> Self::Output {
          self + *rhs
      }
  }

  impl PartialEq<u16> for SaturatingU16 {
      fn eq(&self, other: &u16) -> bool {
          self.value == *other
      }
  }

  impl PartialOrd<u16> for SaturatingU16 {
      fn partial_cmp(&self, other: &u16) -> Option<Ordering> {
          self.value.partial_cmp(other)
      }
  }

  impl PartialEq<SaturatingU16> for u16 {
      fn eq(&self, other: &SaturatingU16) -> bool {
          other == self
      }
  }

  impl PartialOrd<SaturatingU16> for u16 {
      fn partial_cmp(&self, other: &SaturatingU16) -> Option<Ordering> {
          self.partial_cmp(&other.value)
      }
  }

  #[cfg(test)]
  mod tests {
      use super::*;

      #[test]
      fn test_saturating_u16() {
          let a: SaturatingU16 = (&10u8).into();
          let b: SaturatingU16 = 5u8.into();
          let c: SaturatingU16 = u16::MAX.into();
          let d: SaturatingU16 = (&1u16).into();
          let e = &c;

          assert_eq!(a + b, SaturatingU16::from(15u16));
          assert_eq!(a + c, SaturatingU16::from(u16::MAX));
          assert_eq!(a + d, SaturatingU16::from(11u16));
          // Using `a` multiple times across additions requires `Copy`:
          assert_eq!(a + a, 20u16);
          // Heterogeneous addition (Add<u16>) and comparison (PartialEq<u16>):
          assert_eq!(a + 5u16, 15u16);
          assert_eq!(a + e, SaturatingU16::from(u16::MAX));

          let sat = SaturatingU16::from(20u16);
          assert!(sat > a);
          assert!(sat >= b);
          assert!(sat < c);
          assert!(sat <= c);
          assert!(sat > 10u16);
          assert!(sat <= 20u16);
          assert!(20u16 >= sat);
          assert!(10u16 < sat);
      }
  }
  ```

## Chapter 5 - Ticket v2

- Our first draft of `Ticket` screamed beginner all over. In this chapter, we
  will make a number of improvements.

### Enums

- First, we only allowed "To Do", "In Progress", and "Done" for status, and we
  did this by checking `String` values. The fact that `status` is a limited
  number of values isn't obvious from the `String` type. We can do better with
  **enumerations**. An enumeration is defined with the `enum` keyword and is a
  type that can have a fixed set of values called variants.

  ```rs
  enum Status {
      Todo,
      InProgress,
      Done,
  }
  ```

- Like `struct`, `enum` defines a new Rust type.
- Here is us using the `Status` enum in our `Ticket` struct:

  ```rs
  // `derive`s are recursive: it can only derive `PartialEq` if all fields also
  // implement `PartialEq`. Same holds for `Debug`.
  #[derive(Debug, PartialEq)]
  pub struct Ticket {
      title: String,
      description: String,
      status: Status,
  }

  #[derive(Debug, PartialEq, Clone, Copy)]
  pub enum Status {
      ToDo,
      InProgress,
      Done,
  }

  impl Ticket {
      pub fn new(title: String, description: String, status: Status) -> Ticket {
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

          Ticket {
              title,
              description,
              status,
          }
      }

      pub fn title(&self) -> &String {
          &self.title
      }

      pub fn description(&self) -> &String {
          &self.description
      }

      pub fn status(&self) -> &Status {
          &self.status
      }
  }
  ```

- As a general rule in Rust: if an enum has no payload (or all of its variant
  payloads are also `Copy`), derive `Copy` and `Clone` without hesitation.
- You can derive `PartialOrd` and `Ord` on an `enum` and the ordering will be
  defined by the order of the variants. The first is 0, the next is 1, etc. It's
  also possible to manually assign discriminants, and order will go by those,
  for example, `ToDo = 10, Low = 1`. If the variants have payloads, it goes by
  discriminant first, and then payload if both are the same variant.
- While `PartialEq` and `PartialOrd` are enough to use the operators, the rule
  of thumb is if your type can implement `Eq` and `Ord`, you should derive them.
  `Eq` requires `PartialEq`, and `Ord` requires `PartialOrd`, `PartialEq`, and
  `Eq`. So you often see all four derived together. So in general, derive all
  four unless your struct/enum has floating-point numbers. If your struct
  contains a `f32` or `f64`, you can only derive `PartialEq` and `PartialOrd`.

### Branching - match

- The most common thing to do with an `enum` is to `match` on it. You can think
  of a `match` statement like a type-level `if`. `match` is **exhaustive**,
  which means you must handle all `enum` variants. If you forget to handle a
  variant (perhaps a newly added one), Rust will stop you with a compile-time
  error. If you don't care about one or more variants, a `_` matches everything,
  but then you lose the compiler enforced handling of new variants. This is a
  good reason to avoid using `_` in `enum` `match` statements.

  ```rs
  impl Status {
      fn is_done(&self) -> bool {
          match self {
              Status::Done => true,
              // The `|` operator lets you match multiple patterns.
              // It reads as "either `Status::ToDo` or `Status::InProgress`".
              Status::InProgress | Status::ToDo => false,
          }
      }
  }
  ```

### Variants with data

- Our `Status` `enum` is a **C-style enum** since the variants contain no data.
  We can also attach data to variants of an enum. Then we have a **struct-like
  variant**.

  ```rs
  enum Status {
      ToDo,
      InProgress {
          assigned_to: String,
      },
      Done,
  }
  ```

- The struct is declared inline. To access `assigned_to` we need to pattern
  match on the `enum`.

  ```rs
  match status {
      Status::InProgress { assigned_to } => {
          println!("Assigned to: {}", assigned_to);
      }
      Status::ToDo | Status::Done => {
          println!("ToDo or Done");
      }
  }
  ```

- In the `match` pattern, `assigned_to` is a **binding**. We're
  **destructuring** the `Status::InProgress` variant and binding `assigned_to`
  field to a new variable, which we also named `assigned_to`. If we had instead
  put `Status::InProgress { assigned_to: person }`, `assigned_to` would be bound
  to a variable named `person`.

### Branching - if let and let/else

- If you only care about one variant, you can use `if let` without having to
  handle all the other variants.

  ```rs
  impl Ticket {
      pub fn assigned_to(&self) -> &str {
          if let Status::InProgress { assigned_to } = &self.status {
              assigned_to
          } else {
              panic!(
                  "Only `In-Progress` tickets can be assigned to someone"
              );
          }
      }
  }
  ```

- If the `else` branch is meant to return early like the `panic!` in the last
  example, you can use `let`/`else`. It allows you to assign the variable
  without incurring any "right drift".

  ```rs
  impl Ticket {
      pub fn assigned_to(&self) -> &str {
          let Status::InProgress { assigned_to } = &self.status else {
              panic!(
                  "Only `In-Progress` tickets can be assigned to someone"
              );
          };
          assigned_to
      }
  }
  ```

### Nullability

- It is rather blunt panicking for missing values. The `Option<T>` type provides
  a better solution. `Option` is a Rust type that represents nullable values.

  ```rs
  enum Option<T> {
      Some(T),
      None,
  }
  ```

- `Option` encodes that a value can be present or absent and forces you to
  explicitly handle both cases. `Option::Some` is a **tuple-like variant**.
  Tuple-like variants are often used when there is a single field to store,
  especially for wrapper types like `Option<T>`.
- Tuple-like structs aren't specific to `enum`s.

  ```rs
  struct Point(i32, i32);

  let point = Point(3, 4);
  let x = point.0;
  let y = point.1;
  ```

### Tuples

- We haven't actually covered tuples yet! A tuple is another primitive Rust type
  that groups together a fixed number of values with (potentially) different
  types.

  ```rs
  // Two values, same type
  let first: (i32, i32) = (3, 4);
  // Three values, different types
  let second: (i32, u32, u8) = (-42, 3, 8);

  assert_eq!(second.0, -42);
  assert_eq!(second.1, 3);
  assert_eq!(second.2, 8);
  ```

- Destructuring a tuple works similarly to destructuring a struct, except you
  use parentheses instead of braces.

  ```rs
  let (x, y) = first;

  let (a, b, c) = second;
  ```

### Fallibility

- `Result` is an `enum` defined in the standard library to signal that an
  operation may fail. It has two variants: `Ok(val)` and `Err(err)`.

  ```rs
  enum Result<T, E> {
      Ok(T),
      Err(E),
  }
  ```

- Both `Ok` and `Err` variants are tuple variants, with `Ok` holding the
  successful value and `Err` holding the error value. Both are generic, so you
  can specify your own type for both success and failure.
- You can pattern match on result in much the same way that we pattern matched
  on `Option<T>`.

  ```rs
  fn print_result(result: &Result<i32, String>) {
      match result {
          Ok(value) => {
              println!("Success! The value is {value}.");
          }
          Err(error) => {
              println!("Error! The error is {error}.");
          }
      }
  }
  ```

- Recoverable errors in Rust are represented by values. They are just an
  instance of a type being passed around and manipulated. Fallibility in Rust is
  encoded in the function's signature. It is clear from the return type whether
  a function can fail or not. The big advantage of `Result` is that it makes
  fallibility explicit.

  ```rs
  // Just by looking at the signature, you know that this function
  // can fail. You can also inspect `ParseIntError` to see what
  // kind of failures to expect.
  fn parse_int(s: &str) -> Result<i32, ParseIntError> {
      // ...
  }
  ```

- Many other languages handle failure with exceptions. Exceptions introduce a
  separate control flow path that can be hard to reason about and has poor
  locality. The exception might be handled far from where it is thrown. Also you
  cannot tell by looking at a function that it might throw an exception unless
  you are very familiar with its implementation or read the function's
  documentation. Keep in mind that panics still exist in Rust and are much like
  exceptions in other languages, but they are meant for **unrecoverable errors**
  and should be used sparingly.
- Here is a first pass at a `Ticket::new` function that returns a `Result`:

  ```rs
  #[derive(Debug, PartialEq)]
  pub struct Ticket {
      title: String,
      description: String,
      status: Status,
  }

  #[derive(Debug, PartialEq)]
  pub enum Status {
      ToDo,
      InProgress { assigned_to: String },
      Done,
  }

  impl Ticket {
      pub fn new(
          title: String,
          description: String,
          status: Status,
      ) -> Result<Ticket, String> {
          if title.is_empty() {
              return Err("Title cannot be empty".into());
          }
          if title.len() > 50 {
              return Err("Title cannot be longer than 50 bytes".into());
          }
          if description.is_empty() {
              return Err("Description cannot be empty".into());
          }

          Ok(Ticket {
              title,
              description,
              status,
          })
      }
  }
  ```

### Unwrap

- Unlike exceptions, `Result` forces you to handle errors at the call site.

  ```rs
  fn parse_int(s: &str) -> Result<i32, ParseIntError> {
      // ...
  }

  // This won't compile: we're not handling the error case.
  // We must either use `match` or one of the combinators provided by
  // `Result` to "unwrap" the success value or handle the error.
  let number = parse_int("42") + 2;

  // You can still choose to panic on the error if it is unrecoverable
  // or you simply don't know what to do with it.

  // `unwrap` panics if `parse_int` returns an `Err`.
  let number = parse_int("42").unwrap();
  // `expect` lets you specify a custom panic message.
  let number = parse_int("42").expect("Failed to parse integer");

  // `match` gives you complete control over how to handle both cases.
  match parse_int("42") {
      Ok(number) => println!("Parsed number: {}", number),
      Err(err) => eprintln!("Error: {}", err),
  }
  ```

### Error enums

- Matching on strings to pick out the error is less than ideal. A common pattern
  for handling different kinds of errors in Rust is to use an `enum` for the
  error type itself.

  ```rs
  // An error enum to represent the different error cases
  // that may occur when parsing a `u32` from a string.
  #[derive(Debug)]
  enum U32ParseError {
      NotANumber,
      TooLarge,
      Negative,
  }
  ```

- Using an error enum, you're encoding the different error cases in the type
  system - they become part of the signature of the fallible function.
- This simplifies error handling for the caller, as they can use a match
  expression to react to the different error cases:

  ```rs
  match s.parse_u32() {
      Ok(n) => n,
      Err(U32ParseError::Negative) => 0,
      Err(U32ParseError::TooLarge) => u32::MAX,
      Err(U32ParseError::NotANumber) => {
          panic!("Not a number: {}", s);
      }
  }
  ```

- So here's a take on ticket with real error `enum`s:

  ```rs
  #[derive(Debug)]
  enum TicketNewError {
      TitleError(String),
      DescriptionError(String),
  }

  pub fn easy_ticket(
      title: String,
      description: String,
      status: Status,
  ) -> Ticket {
      match Ticket::new(title.clone(), description, status.clone()) {
          Ok(ticket) => ticket,
          Err(TicketNewError::DescriptionError(_)) => Ticket::new(
              title,
              "Description not provided".to_string(),
              status,
          )
          .unwrap(),
          Err(TicketNewError::TitleError(error)) => panic!("{error}"),
      }
  }

  #[derive(Debug, PartialEq)]
  pub struct Ticket {
      title: String,
      description: String,
      status: Status,
  }

  #[derive(Debug, PartialEq, Clone)]
  pub enum Status {
      ToDo,
      InProgress { assigned_to: String },
      Done,
  }

  impl Ticket {
      pub(crate) fn new(
          title: String,
          description: String,
          status: Status,
      ) -> Result<Ticket, TicketNewError> {
          if title.is_empty() {
              return Err(TicketNewError::TitleError(
                  "Title cannot be empty".to_string(),
              ));
          }
          if title.len() > 50 {
              return Err(TicketNewError::TitleError(
                  "Title cannot be longer than 50 bytes".to_string(),
              ));
          }
          if description.is_empty() {
              return Err(TicketNewError::DescriptionError(
                  "Description cannot be empty".to_string(),
              ));
          }
          if description.len() > 500 {
              return Err(TicketNewError::DescriptionError(
                  "Description cannot be longer than 500 bytes".to_string(),
              ));
          }

          Ok(Ticket {
              title,
              description,
              status,
          })
      }

      pub fn title(&self) -> &str {
          &self.title
      }

      pub fn description(&self) -> &str {
          &self.description
      }

      pub fn status(&self) -> &Status {
          &self.status
      }
  }
  ```

### Error - trait

- It's still a little fiddly pulling the `String` out of our error and then
  reporting the result. Rust provides the `std::error::Error` trait to help with
  this. You can use any type for the error side of your `Result`, but it is
  convenient to use something that implements the `Error` trait.

  ```rs
  // Slightly simplified definition of the `Error` trait
  pub trait Error: Debug + Display {}

  // `Debug`
  pub trait Debug {
      fn fmt(&self, f: &mut Formatter<'_>) -> Result<(), Error>;
  }

  // `Display`
  pub trait Display {
      fn fmt(&self, f: &mut Formatter<'_>) -> Result<(), Error>;
  }
  ```

- It's worth mentioning `Debug` and `Display`. They are for formatting messages.
  `Display` is a format for end-users and must be implemented manually, while
  `Debug` can be derived using the `#[derive(Debug)]` attribute since it is
  usually a one-to-one mapping of the internal state. Here is a more complete
  definition of `Error` and how it relates to `Debug` and `Display`:

  ```rs
  use std::fmt::{Debug, Display, Formatter};

  pub trait Error: Debug + Display {
      // We left this out since it has a default implementation
      fn source(&self) -> Option<&(dyn Error + 'static)> {
          None
      }
  }
  ```

- The way we write this doesn't change much, so I'll just demonstrate
  implementing `Error` and `Display` for our `enum`:

  ```rs
  // We need `Debug` but can derive it
  #[derive(Debug)]
  pub enum TicketNewError {
      TitleError(String),
      DescriptionError(String),
  }

  // We need to define `Display`
  impl std::fmt::Display for TicketNewError {
      fn fmt(&self, f: &mut std::fmt::Formatter) -> std::fmt::Result {
          match self {
              TicketNewError::TitleError(msg) => write!(f, "{}", msg),
              TicketNewError::DescriptionError(msg) => write!(f, "{}", msg),
          }
      }
  }

  // `source` has a default implementation that returns `None`, so `Error`
  // can be an empty implementation
  impl std::error::Error for TicketNewError {}

  // `easy_ticket` should panic when the title is invalid, using the error
  // message stored inside the relevant variant of the `TicketNewError` enum.
  // When the description is invalid, instead, it should use a default
  // description: "Description not provided".
  pub fn easy_ticket(
      title: String,
      description: String,
      status: Status,
  ) -> Ticket {
      match Ticket::new(title.clone(), description, status.clone()) {
          Ok(ticket) => ticket,
          Err(err) => match err {
              // We no longer need to bind the `String`; just call `panic!` with
              // a format string for the `err` we matched on.
              TicketNewError::TitleError(_) => panic!("{err}"),
              TicketNewError::DescriptionError(_) => Ticket::new(
                  title,
                  "Description not provided".to_string(),
                  status,
              )
              .unwrap(),
          },
      }
  }
  // ... rest unchanged
  ```

- You'll notice we just called `panic!("{err}")`. The `panic!` macro is actually
  a formatting macro like `println!` and `format!`.

### Packages

- And here is where we will introduce our first dependency. `thiserror` is a
  convenient macro for defining custom error types. You can find it on
  [crates.io](https://crates.io/crates/thiserror). It simplifies some of the
  ceremony in declaring `Error` types.
- A Rust package is defined by the `[package]` section in a Cargo.toml file,
  also known as its manifest. Within `[package]` you can set the package's
  metadata, such as its name and version.
- Inside a package, you have one or more crates, also known as **targets**. The
  two most common crate types are **binary crates** (which contain a `main`
  function in a _src/main.rs_ or alternatively a _src/bin/name.rs_ for some
  name) and **library crates** (which contain a _src/lib.rs_). You can override
  default filenames by explicitly declaring targets in _Cargo.toml_. A package
  can contain multiple crates, but only one library crate.

### Dependencies

- You can add dependencies to your _Cargo.toml_.

  ```toml
  [dependencies]
  thiserror = "1"
  ```

- Your _Cargo.lock_ file contains resolved versions of your dependencies and
  should be checked into source control. Running `cargo update` will cause the
  compiler to re-resolve the dependencies and update _Cargo.lock_. Otherwise you
  will always build with the same versions as specified in the lock file.
- You can also specify dependencies with a local path. The path is relative to
  the _Cargo.toml_ file that is declaring the dependency.

  ```toml
  [dependencies]
  my-library = { path = "../my-library" }
  ```

- You can also specify dev-dependencies that aren't required to run your
  program, but are useful for development, testing, or documentation.

  ```toml
  [dev-dependencies]
  static_assertions = "1.1.0"
  ```

### thiserror

- `thiserror` is a dependency that provides a procedural macro that lets you
  derive `Error`.

  ```rs
  #[derive(thiserror::Error, Debug)]
  enum TicketNewError {
      #[error("{0}")]
      TitleError(String),
      #[error("{0}")]
      DescriptionError(String),
  }
  ```

- Each procedural macro can define its own syntax. For `thiserror`:
  - `#[derive(thiserror::Error)]`: this is the syntax to derive the Error trait
    for a custom error type, helped by thiserror.
  - `#[error("{0}")]`: this is the syntax to define a `Display` implementation
    for each variant of the custom error type. `{0}` is replaced by the zero-th
    field of the variant (`String`, in this case) when the error is displayed.
- After adding `thiserror` to our dependencies, we can rewrite the last example.
  We will use more specific values in our enum so each error has one message
  rather than carrying a `String`.

  ```rs
  #[derive(Debug, thiserror::Error)]
  pub enum TicketNewError {
      #[error("Title cannot be empty")]
      TitleCannotBeEmpty,
      #[error("Title cannot be longer than 50 bytes")]
      TitleTooLong,
      #[error("Description cannot be empty")]
      DescriptionCannotBeEmpty,
      #[error("Description cannot be longer than 500 bytes")]
      DescriptionTooLong,
  }
  ```

### TryFrom - trait

- Last chapter we looked at `From` and `Into`, the infallible conversion
  mechanisms. Both have fallible counterparts, `TryFrom` and `TryInto`.
  `TryFrom` is a trait for converting one type into another that may fail. It
  has one method, `try_from` that returns a `Result`. Both are defined in
  `std::convert`.

  ```rs
  pub trait TryFrom<T>: Sized {
      type Error;
      fn try_from(value: T) -> Result<Self, Self::Error>;
  }

  pub trait TryInto<T>: Sized {
      type Error;
      fn try_into(self) -> Result<T, Self::Error>;
  }
  ```

- Both `TryFrom` and `TryInto` have an associated `Error` type. This allows each
  implementation to specify its own error type, ideally the most appropriate for
  the conversion being attempted. `Self::Error` is a way to refer to the Error
  associated type defined in the trait itself.
- Just like `From`, if you implement `TryFrom`, you get `TryInto` for free.

  ```rs
  #[derive(Debug, PartialEq, Clone)]
  pub enum Status {
      ToDo,
      InProgress,
      Done,
  }

  #[derive(Debug, thiserror::Error)]
  #[error("{invalid_status} is not a valid status")]
  pub struct ParseStatusError {
      invalid_status: String,
  }

  impl TryFrom<String> for Status {
      type Error = ParseStatusError;

      fn try_from(value: String) -> Result<Self, Self::Error> {
          value.as_str().try_into()
      }
  }

  impl TryFrom<&str> for Status {
      type Error = ParseStatusError;

      fn try_from(value: &str) -> Result<Self, Self::Error> {
          match value.to_lowercase().as_str() {
              "todo" => Ok(Status::ToDo),
              "inprogress" => Ok(Status::InProgress),
              "done" => Ok(Status::Done),
              _ => Err(ParseStatusError {
                  invalid_status: value.to_string(),
              }),
          }
      }
  }
  ```

- Two small items worth pointed out in the previous example...
  - `match` isn't just for enums: In Rust, pattern matching works on integers,
    chars, tuples, references, and string slices (`&str`)!
  - Why `.as_str()` was needed: `value.to_lowercase()` allocates and returns an
    owned `String` (because converting case can alter byte lengths in UTF-8).
    String literals like "todo" and "done" are `&str`. Calling `.as_str()`
    borrows that temporary String as an `&str` so the compiler can match it
    against "todo", "inprogress", and "done". `match` expressions do not perform
    deref coercion. Deref coercion happens to function/method arguments,
    explicit variable assignments, and function return expressions. `as_str()`
    is the idiomatic way to borrow a `String` as a `&str` slice.

### Error - source

- So far, we've been ignoring the `source` method since a default implementation
  is provided. The `source` method is a way to access the error's cause, if any.
  Here we return `std::io::Error` as the source of a `DatabaseError`:

  ```rs
  use std::error::Error;

  #[derive(Debug)]
  struct DatabaseError {
      source: std::io::Error
  }

  impl std::fmt::Display for DatabaseError {
      fn fmt(&self, f: &mut std::fmt::Formatter) -> std::fmt::Result {
          write!(f, "Failed to connect to the database")
      }
  }

  impl std::error::Error for DatabaseError {
      fn source(&self) -> Option<&(dyn Error + 'static)> {
          Some(&self.source)
      }
  }
  ```

- `&(dyn Error + 'static)` is a reference to a trait object that implements the
  `Error` trait and is valid for the entire program execution. `dyn Error`
  refers to any type that implements `Error`. `'static` is a lifetime annotation
  that means the trait object is valid for the entire program execution.
- `thiserror` provides three ways to automatically implement `source` for your
  error types.
  - A field named `source` will automatically be used as the source of an error.

    ```rs
    use thiserror::Error;

    #[derive(Error, Debug)]
    pub enum MyError {
        #[error("Failed to connect to the database")]
        DatabaseError {
            source: std::io::Error
        }
    }
    ```

  - A field annotated with `#[source]` will automatically be used as the source
    of an error.

    ```rs
    use thiserror::Error;

    #[derive(Error, Debug)]
    pub enum MyError {
        #[error("Failed to connect to the database")]
        DatabaseError {
            #[source]
            inner: std::io::Error
        }
    }
    ```

  - A field annotated with the `#[from]` attribute will automatically be used as
    the source of the error and `thiserror` will automatically generate a `From`
    implementation to convert the annotated type into your error type.

    ```rs
    use thiserror::Error;

    #[derive(Error, Debug)]
    pub enum MyError {
        #[error("Failed to connect to the database")]
        DatabaseError {
            #[from]
            inner: std::io::Error
        }
    }
    ```

#### The ? operator

- The `?` operator is shorthand for propagating errors. When used in a function
  that returns a `Result`, `?` will unwrap the `Ok` value or return the `Err`
  value from the function.

  ```rs
  use std::fs::File;

  fn read_file() -> Result<String, std::io::Error> {
      let mut file = File::open("file.txt")?;
      let mut contents = String::new();
      file.read_to_string(&mut contents)?;
      Ok(contents)
  }
  ```

- is equivalent to:

  ```rs
  use std::fs::File;

  fn read_file() -> Result<String, std::io::Error> {
      let mut file = match File::open("file.txt") {
          Ok(file) => file,
          Err(e) => {
              return Err(e);
          }
      };
      let mut contents = String::new();
      match file.read_to_string(&mut contents) {
          Ok(_) => (),
          Err(e) => {
              return Err(e);
          }
      }
      Ok(contents)
  }
  ```

- You can use the `?` operator to shorten your error handling code
  significantly.
- In particular, the `?` operator will automatically convert the error type of
  the fallible operation into the error type of the function, if a conversion is
  possible (i.e. if there is a suitable `From` implementation).

  ```rs
  // src/lib.rs
  pub use crate::status::{ParseStatusError, Status};

  mod status;

  #[derive(Debug, thiserror::Error)]
  pub enum TicketNewError {
      #[error("Title cannot be empty")]
      TitleCannotBeEmpty,
      #[error("Title cannot be longer than 50 bytes")]
      TitleTooLong,
      #[error("Description cannot be empty")]
      DescriptionCannotBeEmpty,
      #[error("Description cannot be longer than 500 bytes")]
      DescriptionTooLong,
      #[error("{0}")]
      InvalidStatus(#[from] ParseStatusError),
  }

  #[derive(Debug, PartialEq, Clone)]
  pub struct Ticket {
      title: String,
      description: String,
      status: Status,
  }

  impl Ticket {
      pub fn new(
          title: String,
          description: String,
          status: String,
      ) -> Result<Self, TicketNewError> {
          if title.is_empty() {
              return Err(TicketNewError::TitleCannotBeEmpty);
          }
          if title.len() > 50 {
              return Err(TicketNewError::TitleTooLong);
          }
          if description.is_empty() {
              return Err(TicketNewError::DescriptionCannotBeEmpty);
          }
          if description.len() > 500 {
              return Err(TicketNewError::DescriptionTooLong);
          }

          let status = Status::try_from(status)?;

          Ok(Ticket {
              title,
              description,
              status,
          })
      }
  }

  // src/status.rs
  #[derive(Debug, PartialEq, Clone)]
  pub enum Status {
      ToDo,
      InProgress,
      Done,
  }

  impl TryFrom<String> for Status {
      type Error = ParseStatusError;

      fn try_from(value: String) -> Result<Self, Self::Error> {
          let value = value.to_lowercase();
          match value.as_str() {
              "todo" => Ok(Status::ToDo),
              "inprogress" => Ok(Status::InProgress),
              "done" => Ok(Status::Done),
              _ => Err(ParseStatusError {
                  invalid_status: value,
              }),
          }
      }
  }

  #[derive(Debug, thiserror::Error)]
  #[error(
      "`{invalid_status}` is not a valid status. \
      Use one of: ToDo, InProgress, Done"
  )]
  pub struct ParseStatusError {
      invalid_status: String,
  }

  // tests/test.rs
  #[cfg(test)]
  mod tests {
      use common::{valid_description, valid_title};
      use std::convert::TryFrom;
      use std::error::Error;
      use task_error_source::*;

      #[test]
      fn invalid_status() {
          let err = Ticket::new(
              valid_title(),
              valid_description(),
              "invalid".into(),
          )
          .unwrap_err();
          assert_eq!(
              err.to_string(),
              "`invalid` is not a valid status. \
              Use one of: ToDo, InProgress, Done"
          );
          assert!(err.source().is_some());
      }

      #[test]
      fn test_try_from_string() {
          let status = Status::try_from("ToDO".to_string()).unwrap();
          assert_eq!(status, Status::ToDo);

          let status = Status::try_from("inproGress".to_string()).unwrap();
          assert_eq!(status, Status::InProgress);

          let status = Status::try_from("Done".to_string()).unwrap();
          assert_eq!(status, Status::Done);
      }
  }
  ```

### Outro - Validated Ticket

- In our final take on `Ticket`, we plan to introduce a new type for each of the
  fields in `Ticket`. Every time someone accesses a `TicketField`, they will get
  back a value that is guaranteed to be valid. For example, a `TicketTitle` will
  always be a non-empty `String` less than 50 bytes long.

  ```rs
  // src/lib.rs
  mod description;
  mod status;
  mod title;

  // A common pattern in Rust is to split code into multiple (private)
  // modules and then re-export the public parts of those modules at the
  // root of the crate.
  //
  // This hides the internal structure of the crate from your users, while
  // still allowing you to organize your code however you like.
  pub use description::TicketDescription;
  pub use status::Status;
  pub use title::TicketTitle;

  #[derive(Debug, PartialEq, Eq, PartialOrd, Ord, Clone)]
  // We no longer need to make the fields private!
  // Since each field encapsulates its own validation logic, there is no risk
  // of a user of `Ticket` modifying the fields in a way that would break the
  // invariants of the struct.
  //
  // Careful though: if you had any invariants that spanned multiple fields,
  // you would need to ensure that those invariants are still maintained and
  // go back to making the fields private.
  pub struct Ticket {
      pub title: TicketTitle,
      pub description: TicketDescription,
      pub status: Status,
  }

  // src/title.rs
  // TODO: Implement `TryFrom<String>` and `TryFrom<&str>` for `TicketTitle`,
  // enforcing that the title is not empty and is not longer than 50 bytes.

  #[derive(Debug, PartialEq, Eq, PartialOrd, Ord, Clone)]
  pub struct TicketTitle(String);

  impl TicketTitle {
      pub fn value(&self) -> &str {
          &self.0
      }
  }

  #[derive(Debug, thiserror::Error)]
  pub enum TicketTitleError {
      #[error("The title cannot be empty")]
      Empty,
      #[error("The title cannot be longer than 50 bytes")]
      TooLong,
  }

  impl TryFrom<String> for TicketTitle {
      type Error = TicketTitleError;

      fn try_from(value: String) -> Result<Self, Self::Error> {
          validate(&value)?;
          Ok(Self(value))
      }
  }

  impl TryFrom<&str> for TicketTitle {
      type Error = TicketTitleError;

      fn try_from(value: &str) -> Result<Self, Self::Error> {
          validate(value)?;
          Ok(Self(value.to_string()))
      }
  }

  fn validate(title: &str) -> Result<(), TicketTitleError> {
      if title.is_empty() {
          Err(TicketTitleError::Empty)
      } else if title.len() > 50 {
          Err(TicketTitleError::TooLong)
      } else {
          Ok(())
      }
  }

  // src/description.rs
  // TODO: Implement `TryFrom<String>` and `TryFrom<&str>` for
  // `TicketDescription`, enforcing that the description is not empty and is
  // not longer than 500 bytes.

  #[derive(Debug, PartialEq, Eq, PartialOrd, Ord, Clone)]
  pub struct TicketDescription(String);

  impl TicketDescription {
      pub fn value(&self) -> &str {
          &self.0
      }
  }

  #[derive(Debug, thiserror::Error)]
  pub enum TicketDescriptionError {
      #[error("The description cannot be empty")]
      Empty,
      #[error("The description cannot be longer than 500 bytes")]
      TooLong,
  }

  impl TryFrom<String> for TicketDescription {
      type Error = TicketDescriptionError;

      fn try_from(value: String) -> Result<Self, Self::Error> {
          validate(&value)?;
          Ok(Self(value))
      }
  }

  impl TryFrom<&str> for TicketDescription {
      type Error = TicketDescriptionError;

      fn try_from(value: &str) -> Result<Self, Self::Error> {
          validate(value)?;
          Ok(Self(value.to_string()))
      }
  }

  fn validate(description: &str) -> Result<(), TicketDescriptionError> {
      if description.is_empty() {
          Err(TicketDescriptionError::Empty)
      } else if description.len() > 500 {
          Err(TicketDescriptionError::TooLong)
      } else {
          Ok(())
      }
  }

  // src/status.rs
  // TODO: Implement `TryFrom<String>` and `TryFrom<&str>` for `Status`.
  // The parsing should be case-insensitive.

  #[derive(Debug, PartialEq, Eq, PartialOrd, Ord, Clone, Copy)]
  pub enum Status {
      ToDo,
      InProgress,
      Done,
  }

  impl TryFrom<String> for Status {
      type Error = ParseStatusError;

      fn try_from(value: String) -> Result<Self, Self::Error> {
          let value = value.to_lowercase();
          match value.as_str() {
              "todo" => Ok(Status::ToDo),
              "inprogress" => Ok(Status::InProgress),
              "done" => Ok(Status::Done),
              _ => Err(ParseStatusError {
                  invalid_status: value,
              }),
          }
      }
  }

  impl TryFrom<&str> for Status {
      type Error = ParseStatusError;

      fn try_from(value: &str) -> Result<Self, Self::Error> {
          value.to_lowercase().try_into()
      }
  }

  #[derive(Debug, thiserror::Error)]
  #[error(
      "`{invalid_status}` is not a valid status. \
      Use one of: ToDo, InProgress, Done"
  )]
  pub struct ParseStatusError {
      invalid_status: String,
  }

  // tests/integration.rs
  #[cfg(test)]
  mod tests {
      use std::convert::TryFrom;
      use task_ticket_v2_outro::*;

      // description
      #[test]
      fn description_test_try_from_string() {
          let description = TicketDescription::try_from(
              "A description".to_string(),
          )
          .unwrap();
          assert_eq!(description.value(), "A description");
      }

      #[test]
      fn description_test_try_from_empty_string() {
          let err = TicketDescription::try_from("".to_string()).unwrap_err();
          assert_eq!(err.to_string(), "The description cannot be empty");
      }

      #[test]
      fn description_test_try_from_long_string() {
          let description = "\
              At vero eos et accusamus et iusto odio dignissimos ducimus \
              qui blanditiis praesentium voluptatum deleniti atque corrupti \
              quos dolores et quas molestias excepturi sint occaecati \
              cupiditate non provident, similique sunt in culpa qui officia \
              deserunt mollitia animi, id est laborum et dolorum fuga. \
              Et harum quidem rerum facilis est et expedita distinctio. \
              Nam libero tempore, cum soluta nobis est eligendi optio \
              cumque nihil impedit quo minus id quod maxime placeat facere \
              possimus, omnis voluptas assumenda est, omnis dolor \
              repellendus. Temporibus autem quibusdam et aut officiis \
              debitis aut rerum necessitatibus saepe eveniet ut et \
              voluptates repudiandae sint et molestiae non recusandae. \
              Itaque earum rerum hic tenetur a sapiente delectus, ut aut \
              reiciendis voluptatibus maiores alias consequatur aut \
              perferendis doloribus asperiores repellat.\
          "
          .to_string();
          let err = TicketDescription::try_from(description).unwrap_err();
          assert_eq!(
              err.to_string(),
              "The description cannot be longer than 500 bytes"
          );
      }

      #[test]
      fn description_test_try_from_str() {
          let description =
              TicketDescription::try_from("A description").unwrap();
          assert_eq!(description.value(), "A description");
      }

      // status
      #[test]
      fn status_test_try_from_string() {
          let status = Status::try_from("ToDO".to_string()).unwrap();
          assert_eq!(status, Status::ToDo);

          let status = Status::try_from("inproGress".to_string()).unwrap();
          assert_eq!(status, Status::InProgress);

          let status = Status::try_from("Done".to_string()).unwrap();
          assert_eq!(status, Status::Done);
      }

      #[test]
      fn status_test_try_from_str() {
          let status = Status::try_from("ToDO").unwrap();
          assert_eq!(status, Status::ToDo);

          let status = Status::try_from("inproGress").unwrap();
          assert_eq!(status, Status::InProgress);

          let status = Status::try_from("Done").unwrap();
          assert_eq!(status, Status::Done);
      }

      #[test]
      fn status_test_try_from_invalid() {
          let status = Status::try_from("Invalid");
          assert!(status.is_err());
      }

      // title
      #[test]
      fn title_test_try_from_string() {
          let title = TicketTitle::try_from("A title".to_string()).unwrap();
          assert_eq!(title.value(), "A title");
      }

      #[test]
      fn title_test_try_from_empty_string() {
          let err = TicketTitle::try_from("".to_string()).unwrap_err();
          assert_eq!(err.to_string(), "The title cannot be empty");
      }

      #[test]
      fn title_test_try_from_long_string() {
          let title = "\
              A title that's definitely longer than what should be \
              allowed in a development ticket\
          "
          .to_string();
          let err = TicketTitle::try_from(title).unwrap_err();
          assert_eq!(
              err.to_string(),
              "The title cannot be longer than 50 bytes"
          );
      }

      #[test]
      fn title_test_try_from_str() {
          let title = TicketTitle::try_from("A title").unwrap();
          assert_eq!(title.value(), "A title");
      }
  }
  ```

- **The Newtype Pattern**: Wrapping a primitive type in a single-field tuple
  struct (`pub struct TicketTitle(String);`) is called the newtype pattern
  (borrowed from Haskell's `newtype`). In memory, it has zero runtime overhead
  and the exact same layout as the inner type.
- **Enforcing Invariants**: Because the inner field `.0` is private, callers
  cannot construct or mutate it directly. The only way to create or update a
  `TicketTitle` is through `TryFrom`. To modify a field, callers parse and
  replace it (`ticket.title = TicketTitle::try_from(...)?;`).
- **Parse, Don't Validate**: This embodies Alexis King's famous principle:
  [Parse, don't validate](https://lexi-lambda.github.io/blog/2019/11/05/parse-don-t-validate/).
  Instead of validating raw strings with `if` checks across the application, you
  parse the data once at the system boundary into a dedicated type. Any function
  taking `TicketTitle` is guaranteed a valid, non-empty title by the type
  system.
- **Public Fields**: Because each field guarantees its own validity, `Ticket`
  can safely expose its fields as `pub` without risking broken invariants.

## Chapter 6 - Ticket Management

### Arrays

- Arrays in Rust are fixed-size collections of elements of the same type.

  ```rs
  // Array type syntax: [ <type> ; <number of elements> ]
  let numbers: [u32; 3] = [1, 2, 3];
  ```

- The type `[u32; 3]` reads as "an array of `u32`s with a length of 3". If all
  array elements are the same, you can use a shorter syntax to initialize it:

  ```rs
  // [ <value> ; <number of elements> ]
  let numbers: [u32; 3] = [1; 3];  // [1, 1, 1]
  ```

  - You can access elements using square brackets, and the index must be
    `usize`. Like everything else in Rust, indexes start at 0. Out-of-bounds
    access will panic at runtime. Instead you can use `get` which returns an
    `Option<&T>`. Like `assert_eq!(numbers.get(0), Some(&1));`. Out-of-bounds
    indexing with `get` will return `None`. You can access and replace elements
    in `O(1)` time, and the array is stored on the stack.

  ```rs
  pub struct WeekTemperatures {
      temperatures: [Option<i32>; 7],
  }

  pub enum Weekday {
      Monday,
      Tuesday,
      Wednesday,
      Thursday,
      Friday,
      Saturday,
      Sunday,
  }

  impl WeekTemperatures {
      pub fn new() -> Self {
          WeekTemperatures {
              temperatures: [None; 7],
          }
      }

      pub fn get_temperature(&self, day: Weekday) -> Option<i32> {
          let index = weekday2index(&day);
          self.temperatures[index]
      }

      pub fn set_temperature(&mut self, day: Weekday, temperature: i32) {
          let index = weekday2index(&day);
          self.temperatures[index] = Some(temperature);
      }
  }

  fn weekday2index(day: &Weekday) -> usize {
      match day {
          Weekday::Monday => 0,
          Weekday::Tuesday => 1,
          Weekday::Wednesday => 2,
          Weekday::Thursday => 3,
          Weekday::Friday => 4,
          Weekday::Saturday => 5,
          Weekday::Sunday => 6,
      }
  }
  ```

### Vectors

- Arrays' strength is also their weakness: their size must be known upfront, at
  compile-time. We clearly don't know how many tickets we need to hold ahead of
  time, so they are a poor fit for our ticketing system. But `Vec` is a growable
  array type provided by the standard library. You can create an empty vector
  with `Vec::new()` or `vec![]` then `push` elements onto it. If you know some
  values at creation, you can initialize it with the `vec!` macro:
  `let v = vec![1, 2, 3];`. The syntax for accessing elements is the same as
  arrays. `Vec` is allocated on the heap and has `O(1)` complexity.
- A `Vec` keeps track of three things:
  - A **pointer** to the heap region you reserved.
  - The **length** of the vector; how many elements there are.
  - The **capacity** of the vector; the number of elements that can fit in space
    reserved on the heap.
- A `String` is just a `Vec<u8>` with some extra methods.

  ```rs
  pub fn fibonacci(n: u32) -> u32 {
      let n = n as usize;
      let mut memo = vec![0, 1];
      for i in 2..=n {
          memo.push(memo[i - 1] + memo[i - 2]);
      }
      memo[n]
  }
  ```

### Resizing

- When a `Vec` exhausts its capacity, it will ask the allocator for a new
  (larger) chunk of heap memory, copy the elements over, and deallocate the old
  memory. This operation can be expensive, as it involves a new memory
  allocation and copying all existing elements.
- If you have a rough idea of how many elements you are going to store in the
  `Vec`, you can pre-allocate memory with `Vec::with_capacity()`.

  ```rs
  pub fn fibonacci(n: u32) -> u32 {
      let n = n as usize;
      let mut memo = Vec::with_capacity(n + 1);

      memo.push(0);
      memo.push(1);

      for i in 2..=n {
          memo.push(memo[i - 1] + memo[i - 2]);
      }
      memo[n]
  }
  ```

### Iterators

- You can iterate over collections other than ranges with a `for` loop. The
  following `for` loop desugars into the code below it:

  ```rs
  let v = vec![1, 2, 3];
  for n in v {
      println!("{}", n);
  }

  let mut iter = IntoIterator::into_iter(v);
  loop {
      match iter.next() {
          Some(n) => {
              println!("{}", n);
          }
          None => break,
      }
  }
  ```

- The `next` method above comes from the `Iterator` trait. `Iterator` is a
  standard library trait that provides a shared interface for types that can
  produce a sequence of values.

  ```rs
  trait Iterator {
      type Item;
      fn next(&mut self) -> Option<Self::Item>;
  }
  ```

- A call to `next` returns an `Option` containing the next value in the sequence
  if there is one, or `None` if the iterator is exhausted. Be careful: there is
  no guarantee that an iterator is exhausted when it returns `None`. That's only
  guaranteed if the iterator implements the (more restrictive) `FusedIterator`
  trait. The standard collections all implement this. `iter.fuse()` can be used
  to fuse an iterator that doesn't implement `FusedIterator`.
- The `IntoIterator` trait defines an `into_iter` method that consumes the
  original value and returns an iterator over its elements. A type can only have
  one implementation of `IntoIterator`. Every type that implements `Iterator`
  implements `IntoIterator` by returning itself. The `for` loop only requires
  that a type implements `IntoIterator`.

  ```rs
  trait IntoIterator {
      type Item;
      type IntoIter: Iterator<Item = Self::Item>;
      fn into_iter(self) -> Self::IntoIter;
  }
  ```

- Here is our `TicketStore` implementing `IntoIterator` to yield owned `Ticket`
  values:

  ```rs
  #[derive(Clone)]
  pub struct TicketStore {
      tickets: Vec<Ticket>,
  }

  impl TicketStore {
      pub fn new() -> Self {
          Self {
              tickets: Vec::new(),
          }
      }

      pub fn add_ticket(&mut self, ticket: Ticket) {
          self.tickets.push(ticket);
      }

      pub fn tickets(&self) -> &Vec<Ticket> {
          &self.tickets
      }
  }

  impl IntoIterator for TicketStore {
      type Item = Ticket;
      type IntoIter = std::vec::IntoIter<Self::Item>;

      fn into_iter(self) -> Self::IntoIter {
          self.tickets.into_iter()
      }
  }
  ```

### Iter

- `IntoIterator` **consumes** `self` to create an iterator. This has its
  benefits: you get owned values from the iterator. For example: if you call
  `.into_iter()` on a `Vec<Ticket>` you'll get an iterator that returns `Ticket`
  values. That's also its downside: you can no longer use the original
  collection after calling `.into_iter()` on it. Quite often you want to iterate
  over a collection without consuming it, looking at **references** to the
  values instead. Most collections expose a method called `.iter()` which
  returns an iterator over references to the collection's elements. This pattern
  can be simplified by implementing _IntoIterator_ for a reference to the
  collection. The standard library does this, so if we do `for n in &v` we get
  back references to `n`. It's idiomatic to provide both options:
  - An implementation of `IntoIterator` for a reference to the collection.
  - An `.iter()` method that returns an iterator over references to the
    collection's elements.
- Consider our `TicketStore`. We likely want to iterate over `&Ticket`.

  ```rs
  #[derive(Clone)]
  pub struct TicketStore {
      tickets: Vec<Ticket>,
  }

  impl TicketStore {
      pub fn new() -> Self {
          Self {
              tickets: Vec::new(),
          }
      }

      pub fn add_ticket(&mut self, ticket: Ticket) {
          self.tickets.push(ticket);
      }

      pub fn iter(&self) -> std::slice::Iter<'_, Ticket> {
          self.tickets.iter()
      }
  }
  ```

### Lifetimes

- Lifetimes are labels used by the Rust compiler to keep track of how long a
  reference is valid. The lifetime of a reference is constrained by the scope of
  the value it refers to. Naming how long a specific reference is valid becomes
  important when you have multiple references and you need to clarify how they
  relate to each other.

  ```rs
  impl<T> Vec<T> {
      // Slightly simplified
      pub fn iter<'a>(&'a self) -> Iter<'a, T> {
          // [...]
      }
  }
  ```

- In this case lifetime annotations tell the compiler that the returned iterator
  will live exactly as long as the vector it is called on. In other words, the
  references yielded by the iterator will not outlive the vector itself. This
  prevents us from accidentally keeping references around longer than the data
  they point to (a dangling reference), a common source of bugs in other
  languages.
- The **lifetime elision rules** allow us to omit lifetime annotations in many
  common cases. Often the compiler can automatically infer the correct
  lifetimes. Elision rules imply that the lifetime of the returned `Iter` is
  tied to `self` without it being specifically annotated. You can count on the
  compiler to remind you when you didn't annotate a necessary case. The full
  rules are at <https://doc.rust-lang.org/reference/lifetime-elision.html>.

  ```rs
  impl<T> Vec<T> {
      pub fn iter(&self) -> Iter<'_, T> {
          // [...]
      }
  }
  ```

- We can implement `IntoIterator` on `&TicketStore` with lifetimes:

  ```rs
  impl<'a> IntoIterator for &'a TicketStore {
      type Item = &'a Ticket;
      type IntoIter = std::slice::Iter<'a, Ticket>;

      fn into_iter(self) -> Self::IntoIter {
          self.tickets.iter()
      }
  }
  ```

- **Why `self` is already a reference**: In
  `impl<'a> IntoIterator for &'a TicketStore`, the type implementing the trait
  is `&'a TicketStore`. The trait signature is
  `fn into_iter(self) -> Self::IntoIter`. Because `Self` is `&'a TicketStore`,
  `self` is already a reference! You do not need `&self.tickets`—calling
  `self.tickets.iter()` automatically borrows the vector's elements as slice
  references for lifetime `'a`.
- **The Three `IntoIterator` Patterns**: Idiomatic collections implement
  `IntoIterator` in three distinct variations:

| Impl for          | self Type      | Item Type    | for Loop Usage    |
| :---------------- | :------------- | :----------- | :---------------- |
| `TicketStore`     | owned `Self`   | `Ticket`     | `for t in store`  |
| `&'a TicketStore` | `&'a Self`     | `&'a Ticket` | `for t in &store` |
| `&'a mut Store`   | `&'a mut Self` | `&'a mut T`  | `for t in &mut s` |

### Combinators

- Iterators enable a number of methods called **combinators**.
  - `map` applies a function to each element of the iterator.
  - `filter` keeps only the elements that satisfy a predicate.
  - `filter_map` combines filter and map in one step.
  - `cloned` converts an iterator of references into an iterator of values,
    cloning each element.
  - `enumerate` returns a new iterator that yields (index, value) pairs.
  - `skip` skips the first n elements of the iterator.
  - `take` stops the iterator after n elements.
  - `chain` combines two iterators into one.
- These can be chained together to perform complex transformations.

  ```rs
  let numbers = vec![1, 2, 3, 4, 5];
  // The sum of the squares of the even numbers
  let outcome: u32 = numbers.iter()
      .filter(|&n| n % 2 == 0)
      .map(|&n| n * n)
      .sum();
  ```

- `filter` and `map` take **closures** as arguments. Closures are **anonymous
  functions**, i.e. functions not defined with the `fn` syntax. They are defined
  like `|args| body` where body is in braces `{}` if it is more than one line.
  They can also include a return type if it cannot be inferred. A closure can
  also be assigned to a variable like `let add_one = |x| x + 1;`
- When you are done transforming the elements in the way that you want, you can
  either iterate over the elements with a `for` or use `collect` to consume the
  iterator and create a new collection from the elements. For example, you could
  `collect` the even squares into a `Vec<u32>`:

  ```rs
  let numbers = vec![1, 2, 3, 4, 5];
  let squares_of_evens: Vec<u32> = numbers.iter()
    .filter(|&n| n % 2 == 0)
    .map(|&n| n * n)
    .collect();
  ```

- `collect` is generic over its return type, so you usually need to provide a
  type hint to help the compiler infer the correct type. We did this above by
  annotating `squares_of_evens` with `: Vec<u32>`. You could also use the
  **turbofish syntax** to specify the type:

  ```rs
  let squares_of_evens = numbers.iter()
      .filter(|&n| n % 2 == 0)
      .map(|&n| n * n)
      // Turbofish syntax: `<method_name>::<type>()`
      // It's called turbofish because `::<>` looks like a fish
      .collect::<Vec<u32>>();
  ```

- Or in our `TicketStore` we could return a vector of references to tickets in
  the `ToDo` status:

  ```rs
  pub fn to_dos(&self) -> Vec<&Ticket> {
      self.tickets
          .iter()
          .filter(|ticket| ticket.status == Status::ToDo)
          .collect()
  }
  ```

### impl Trait

- The previous method always allocates memory on the heap to return the vector
  of `&Ticket` references. That may be unnecessary depending on what the caller
  wants to do with the vector of references. An alternative approach is to
  return an **iterator**. But imagine we wanted to do this:

  ```rs
  impl TicketStore {
      pub fn to_dos(&self) -> ??? {
          self.tickets.iter().filter(|t| t.status == Status::ToDo)
      }
  }
  ```

  - What is the return type of `filter`? We can look it up. `filter` returns an
    instance of `std::iter::Filter` which has the following definition:

    ```rs
    pub struct Filter<I, P> { /* fields omitted */ }
    ```

- `I` is `std::slice::Iter<'_, Ticket>` and `P` is a closure type representing
  the predicate used to filter elements. The problem is that `P` is a unique,
  anonymous type for each closure. We cannot name it in the return type. Rust's
  solution for this is `impl Trait`. It allows you to return a type without
  specifying its name. You just declare what traits the type implements, and the
  compiler figures out the exact type. Since we know we want to return an
  `Iterator` reference, we could define `to_dos`:

  ```rs
  impl TicketStore {
      pub fn to_dos(&self) -> impl Iterator<Item = &Ticket> {
          self.tickets.iter().filter(|t| t.status == Status::ToDo)
      }
  }
  ```

- The return type of a function using `impl Trait` is fixed at compile time.
  There will only be a single implementation for it. This is different from
  generics where the caller can specify any type and the function must take it.
  A function with a generic type is **polymorphic** and the compiler generates a
  different implementation for each type. `impl Trait` is called an **opaque
  return type** since the caller doesn't know the exact type of the return
  value, only that it implements the specified trait. But the compiler knows the
  exact type and no polymorphism is involved. Using an `impl Trait` in the
  return position is known as **RPIT** or **Return Position Impl Trait**.

  ```rs
  pub fn in_progress(&self) -> impl Iterator<Item = &Ticket> {
      self.tickets
          .iter()
          .filter(|t| t.status == Status::InProgress)
  }
  ```

### impl Trait, pt.2

- You can also use the `impl Trait` syntax in the argument position. When used
  in the argument position, `impl Trait` is equivalent to a generic parameter
  with a trait bound. As a rule of thumb, prefer generics to `impl Trait` in the
  argument position. Generics allow the caller to specify a type with the
  turbofish syntax ( `::<>` ), whereas `impl Trait` does not.

  ```rs
  fn print_iter(iter: impl Iterator<Item = i32>) {
      for i in iter {
          println!("{}", i);
      }
  }

  // is equivalent to:
  fn print_iter<T>(iter: T)
  where
      T: Iterator<Item = i32>
  {
      for i in iter {
          println!("{}", i);
      }
  }
  ```

- Here is a useful function with trait bounds for our `TicketStore`:

  ```rs
  pub fn add_ticket<T: Into<Ticket>>(&mut self, ticket: T) {
      self.tickets.push(ticket.into());
  }
  ```

### Slices

- `[T]` is a slice of a contiguous sequence of elements of type `T`. It is most
  commonly used in borrowed form `&[T]`. There are various ways to create a
  slice reference from a `Vec`:

  ```rs
  let numbers = vec![1, 2, 3];
  // Via index syntax
  let slice: &[i32] = &numbers[..];
  // Via a method
  let slice: &[i32] = numbers.as_slice();
  // Or for a subset of the elements
  let slice: &[i32] = &numbers[1..];
  ```

- `Vec` implements the `Deref` trait using `[T]` as the target type, so you can
  use slice methods on a `Vec` directly thanks to deref coercion:

  ```rs
  let numbers = vec![1, 2, 3];
  // Surprise, surprise: `iter` is not a method on `Vec`!
  // It's a method on `&[T]`, but you can call it on a `Vec`
  // thanks to deref coercion.
  let sum: i32 = numbers.iter().sum();
  ```

- An `&[T]` is a **fat pointer** just like `&str`. It consists of a pointer to
  the first element of a slice and the length of the slice.
- When you need to pass an immutable reference to a `Vec` to a function, prefer
  `&[T]` over `&Vec<T>`. This allows the function to accept any kind of slice,
  not necessarily one backed by a `Vec`. Array slices and `Vec` slices are the
  same, so you can pass slices and references to arrays to a function defined
  for `&[T]`.

  ```rs
  pub fn sum(slice: &[u32]) -> u32 {
      slice.iter().sum()
  }
  ```

### Mutable slices

- Slices of both strings and vectors can be mutable. Mutable slices are less
  flexible than mutable references. You cannot add or remove elements from a
  mutable slice, only change values that are there. So a `&mut Vec` or a
  `&mut String` are strictly more powerful than a `&mut [T]` or a `&mut str`.

  ```rs
  // square a slice of `i32` in place
  pub fn squared(slice: &mut [i32]) {
      for i in slice.iter_mut() {
          *i *= *i;
      }
  }
  ```

### Two states

- We consider adding an `id: TicketId` to our `Ticket` struct. The first problem
  with this is we don't know the `id` beforehand, so cannot initialize it on
  creation. We could make it an `Option<TicketId>` but then we have to deal with
  unwrapping an option when we know the id exists. So instead we decide to model
  the ticket with two states. `TicketDraft` with no `id`, and `Ticket` with all
  information.

  ```rs
  pub struct TicketDraft {
      pub title: TicketTitle,
      pub description: TicketDescription,
  }

  pub struct Ticket {
      pub id: TicketId,
      pub title: TicketTitle,
      pub description: TicketDescription,
      pub status: Status,
  }
  ```

- A `TicketDraft` is a `Ticket` that hasn't been created yet and has no `id` and
  no `status`. Since each field embeds its constraints within its type, we don't
  have to duplicate logic across the two types.

  ```rs
  use ticket_fields::{TicketDescription, TicketTitle};

  #[derive(Clone)]
  pub struct TicketStore {
      tickets: Vec<Ticket>,
      counter: u64,
  }

  #[derive(Clone, Copy, Debug, PartialEq)]
  pub struct TicketId(u64);

  #[derive(Clone, Debug, PartialEq)]
  pub struct Ticket {
      pub id: TicketId,
      pub title: TicketTitle,
      pub description: TicketDescription,
      pub status: Status,
  }

  #[derive(Clone, Debug, PartialEq)]
  pub struct TicketDraft {
      pub title: TicketTitle,
      pub description: TicketDescription,
  }

  #[derive(Clone, Debug, Copy, PartialEq)]
  pub enum Status {
      ToDo,
      InProgress,
      Done,
  }

  impl TicketStore {
      pub fn new() -> Self {
          Self {
              tickets: Vec::new(),
              counter: 0,
          }
      }

      pub fn add_ticket(&mut self, draft: TicketDraft) -> TicketId {
          let id = self.counter;
          self.counter += 1;
          let ticket = Ticket {
              id: TicketId(id),
              title: draft.title,
              description: draft.description,
              status: Status::ToDo,
          };
          self.tickets.push(ticket);
          TicketId(id)
      }

      pub fn get(&self, id: TicketId) -> Option<&Ticket> {
          self.tickets.iter().find(|ticket| ticket.id == id)
      }
  }
  ```

### Index trait

- The `Index` trait allows indexing with array-like syntax.

  ```rs
  // Slightly simplified
  pub trait Index<Idx>
  {
      type Output;

      // Required method
      fn index(&self, index: Idx) -> &Self::Output;
  }
  ```

- `Index` has:
  - One generic parameter, `Idx`, to represent the index type
  - One associated type, `Output`, to represent the type we retrieved using the
    index
- Note that `index` doesn't return an `Option<T>`. The assumption is that it
  will panic if you try to access an element that is not there.

  ```rs
  impl Index<TicketId> for TicketStore {
      type Output = Ticket;

      fn index(&self, id: TicketId) -> &Self::Output {
          self.tickets.iter().find(|&t| t.id == id).unwrap()
      }
  }

  impl Index<&TicketId> for TicketStore {
      type Output = Ticket;

      fn index(&self, id: &TicketId) -> &Self::Output {
          &self[*id]
      }
  }
  ```

### IndexMut trait

- `Index` allows read-only access. You need to implement `IndexMut` to modify
  values. `IndexMut` can only be implemented on a type that implements `Index`.

  ```rs
  // Slightly simplified
  pub trait IndexMut<Idx>: Index<Idx>
  {
      // Required method
      fn index_mut(&mut self, index: Idx) -> &mut Self::Output;
  }
  ```

- Here is how it would work for our `TicketStore`.

  ```rs
  impl IndexMut<TicketId> for TicketStore {
      fn index_mut(&mut self, index: TicketId) -> &mut Self::Output {
          self.tickets.iter_mut().find(|t| t.id == index).unwrap()
      }
  }

  impl IndexMut<&TicketId> for TicketStore {
      fn index_mut(&mut self, index: &TicketId) -> &mut Self::Output {
          &mut self[*index]
      }
  }
  ```

- Once you implement `index_mut` normal array syntax will return a mutable ref
  when appropriate.

### HashMap

- Our implementation of `Index`/`IndexMut` is not ideal: we need to iterate over
  the entire `Vec` to retrieve a ticket by `id`; the algorithmic complexity is
  `O(n)`, where `n` is the number of tickets in the store. We can do better by
  using a different data structure for storing tickets: a `HashMap<K, V>`.

  ```rs
  use std::collections::HashMap;

  // Type inference lets us omit an explicit type signature (which
  // would be `HashMap<String, String>` in this example).
  let mut book_reviews = HashMap::new();

  book_reviews.insert(
      "Adventures of Huckleberry Finn".to_string(),
      "My favorite book.".to_string(),
  );
  ```

- HashMaps work with key-value pairs and are generic over both. The expected
  cost of insertions, retrievals, and removals is constant or `O(1)`.
- There are no trait bounds on HashMap's struct definition, but there are some
  on its methods.

  ```rs
  // Slightly simplified
  impl<K, V> HashMap<K, V>
  where
      K: Eq + Hash,
  {
      pub fn insert(&mut self, k: K, v: V) -> Option<V> {
          // [...]
      }
  }
  ```

- The key type must implement `Eq` and `Hash` traits.
- `Hash` is from `std::Hash` and you usually will derive it.

  ```rs
  pub trait Hash {
      // Required method
      fn hash<H>(&self, state: &mut H)
         where H: Hasher;
  }
  ```

- `Eq` expands `PartialEq` to require reflexivity. It is a marker trait.

  ```rs
  pub trait Eq: PartialEq {
      // No additional methods
  }
  ```

- You can derive `Eq` automatically when you derive `PartialEq`.
- There is a contract between `Eq` and `Hash`. When two objects are equal, they
  must have the same hash value. This is crucial for `HashMap` to work.

  ```rs
  // `HashMap` implementation of `TicketStore`
  use std::collections::HashMap;
  use std::ops::{Index, IndexMut};
  use ticket_fields::{TicketDescription, TicketTitle};

  #[derive(Clone)]
  pub struct TicketStore {
      tickets: HashMap<TicketId, Ticket>,
      counter: u64,
  }

  #[derive(Clone, Copy, Debug, PartialEq, Eq, Hash)]
  pub struct TicketId(u64);

  #[derive(Clone, Debug, PartialEq)]
  pub struct Ticket {
      pub id: TicketId,
      pub title: TicketTitle,
      pub description: TicketDescription,
      pub status: Status,
  }

  #[derive(Clone, Debug, PartialEq, Eq)]
  pub struct TicketDraft {
      pub title: TicketTitle,
      pub description: TicketDescription,
  }

  #[derive(Clone, Debug, Copy, PartialEq, Eq)]
  pub enum Status {
      ToDo,
      InProgress,
      Done,
  }

  impl TicketStore {
      pub fn new() -> Self {
          Self {
              tickets: HashMap::new(),
              counter: 0,
          }
      }

      pub fn add_ticket(&mut self, ticket: TicketDraft) -> TicketId {
          let id = TicketId(self.counter);
          self.counter += 1;
          let ticket = Ticket {
              id,
              title: ticket.title,
              description: ticket.description,
              status: Status::ToDo,
          };
          self.tickets.insert(id, ticket);
          id
      }

      pub fn get(&self, id: TicketId) -> Option<&Ticket> {
          self.tickets.get(&id)
      }

      pub fn get_mut(&mut self, id: TicketId) -> Option<&mut Ticket> {
          self.tickets.get_mut(&id)
      }
  }

  impl Index<TicketId> for TicketStore {
      type Output = Ticket;

      fn index(&self, index: TicketId) -> &Self::Output {
          self.get(index).unwrap()
      }
  }

  impl Index<&TicketId> for TicketStore {
      type Output = Ticket;

      fn index(&self, index: &TicketId) -> &Self::Output {
          &self[*index]
      }
  }

  impl IndexMut<TicketId> for TicketStore {
      fn index_mut(&mut self, index: TicketId) -> &mut Self::Output {
          self.get_mut(index).unwrap()
      }
  }

  impl IndexMut<&TicketId> for TicketStore {
      fn index_mut(&mut self, index: &TicketId) -> &mut Self::Output {
          &mut self[*index]
      }
  }
  ```

### BTreeMap

- When we were backed by our `Vec`, tickets were stored in the order we created
  them. But with a `HashMap` order is not guaranteed. We can recover consistent
  ordering by switching from a `HashMap` to a `BTreeMap`. A `BTreeMap`
  guarantees the entries are sorted by their keys.
- Just like `HashMap`, the trait bounds are on the methods instead of the
  struct:

  ```rs
  // `K` and `V` stand for the key and value types, respectively,
  // just like in `HashMap`.
  impl<K, V> BTreeMap<K, V> {
      pub fn insert(&mut self, key: K, value: V) -> Option<V>
      where
          K: Ord,
      {
          // implementation
      }
  }
  ```

- `Hash` is no longer required, but keys must implement `Ord` which in turn
  requires `Eq` (and `PartialOrd` and `PartialEq`). It is defined in
  `std::cmp::Ord`.

  ```rs
  pub trait Ord: Eq + PartialOrd {
      fn cmp(&self, other: &Self) -> Ordering;
  }
  ```

- Where `partial_cmp` returns an `Option<Ordering>`, `cmp` returns an
  `Ordering`. Both `Ord` and `PartialOrd` can be derived for your types. If
  implementing them yourself, be sure `Ord` and `PartialOrd` are consistent with
  `Eq` and `PartialEq` as well as with each other.

  ```rs
  // `BTreeMap` implementation of `TicketStore`
  // src/lib.rs
  use std::collections::BTreeMap;
  use std::ops::{Index, IndexMut};
  use ticket_fields::{TicketDescription, TicketTitle};

  #[derive(Clone)]
  pub struct TicketStore {
      tickets: BTreeMap<TicketId, Ticket>,
      counter: u64,
  }

  #[derive(Clone, Copy, Debug, PartialEq, Ord, PartialOrd, Eq)]
  pub struct TicketId(u64);

  #[derive(Clone, Debug, PartialEq)]
  pub struct Ticket {
      pub id: TicketId,
      pub title: TicketTitle,
      pub description: TicketDescription,
      pub status: Status,
  }

  #[derive(Clone, Debug, PartialEq, Eq)]
  pub struct TicketDraft {
      pub title: TicketTitle,
      pub description: TicketDescription,
  }

  #[derive(Clone, Debug, Copy, PartialEq, Eq)]
  pub enum Status {
      ToDo,
      InProgress,
      Done,
  }

  impl TicketStore {
      pub fn new() -> Self {
          Self {
              tickets: BTreeMap::new(),
              counter: 0,
          }
      }

      pub fn add_ticket(&mut self, ticket: TicketDraft) -> TicketId {
          let id = TicketId(self.counter);
          self.counter += 1;
          let ticket = Ticket {
              id,
              title: ticket.title,
              description: ticket.description,
              status: Status::ToDo,
          };
          self.tickets.insert(id, ticket);
          id
      }

      pub fn get(&self, id: TicketId) -> Option<&Ticket> {
          self.tickets.get(&id)
      }

      pub fn get_mut(&mut self, id: TicketId) -> Option<&mut Ticket> {
          self.tickets.get_mut(&id)
      }
  }

  impl Index<TicketId> for TicketStore {
      type Output = Ticket;

      fn index(&self, index: TicketId) -> &Self::Output {
          self.get(index).unwrap()
      }
  }

  impl Index<&TicketId> for TicketStore {
      type Output = Ticket;

      fn index(&self, index: &TicketId) -> &Self::Output {
          &self[*index]
      }
  }

  impl IndexMut<TicketId> for TicketStore {
      fn index_mut(&mut self, index: TicketId) -> &mut Self::Output {
          self.get_mut(index).unwrap()
      }
  }

  impl IndexMut<&TicketId> for TicketStore {
      fn index_mut(&mut self, index: &TicketId) -> &mut Self::Output {
          &mut self[*index]
      }
  }

  impl<'a> IntoIterator for &'a TicketStore {
      type Item = &'a Ticket;
      type IntoIter = std::collections::btree_map::Values<'a, TicketId, Ticket>;

      fn into_iter(self) -> Self::IntoIter {
          self.tickets.values()
      }
  }

  // tests/integration.rs
  #[cfg(test)]
  mod tests {
      use task_btree_map::{Status, TicketDraft, TicketId, TicketStore};
      use ticket_fields::test_helpers::{ticket_description, ticket_title};

      #[test]
      fn works() {
          let mut store = TicketStore::new();

          let n_tickets = 5;

          for i in 0..n_tickets {
              let draft = TicketDraft {
                  title: ticket_title(),
                  description: ticket_description(),
              };
              let id = store.add_ticket(draft.clone());
              let ticket = &store[id];
              assert_eq!(draft.title, ticket.title);
              assert_eq!(draft.description, ticket.description);
              assert_eq!(ticket.status, Status::ToDo);

              let ticket = &mut store[id];
              ticket.status = Status::InProgress;

              let ticket = &store[id];
              assert_eq!(ticket.status, Status::InProgress);
          }

          let ids: Vec<TicketId> =
              (&store).into_iter().map(|t| t.id).collect();
          let sorted_ids = {
              let mut v = ids.clone();
              v.sort();
              v
          };
          assert_eq!(ids, sorted_ids);
      }
  }
  ```

- Tip: You can put `type IntoIter = ()` and run `cargo check` and it will tell
  you what type it found being returned instead.

## Chapter 7 - Threads

### Threads

- A **thread** is an execution context managed by the underlying operating
  system. Each thread has its own stack and instruction pointer.
- A single **process** can manage multiple threads. These threads share the same
  memory space, which means they can access the same data.
- Threads are a logical construct. In the end, you can only run one set of
  instructions at a time on a CPU core, the physical execution unit. Since there
  can be many more threads than there are CPU cores, the operating system's
  scheduler is in charge of deciding which thread to run at any given time,
  partitioning CPU time among them to maximize throughput and responsiveness.
- When a Rust program starts, it runs on a single thread, the **main thread**.
- The `std::thread` library allows you to create and manage threads.
  - `thread::spawn` creates new threads and executes code on them.
  - `thread::JoinHandle::join` is called on a thread's `JoinHandle` (returned
    from spawn) to wait for the thread to finish.
- By default all threads end when main ends. `join` introduces a form of
  **synchronization** between the two threads. You're guaranteed to see the
  results of the thread before the program exits.

  ```rs
  use std::thread;

  pub fn sum(v: Vec<i32>) -> i32 {
      let mid = v.len() / 2;
      let (v1, v2) = v.split_at(mid);
      let v1 = v1.to_vec();
      let v2 = v2.to_vec();

      let handle1 = thread::spawn(move || v1.into_iter().sum::<i32>());
      let handle2 = thread::spawn(move || v2.into_iter().sum::<i32>());

      handle1.join().unwrap() + handle2.join().unwrap()
  }
  ```

### 'static lifetime

- Since a spawned thread can outlive the thread that spawned it (its parent
  thread) and run until the program exits, it must not borrow any values that
  can be dropped before the program exits.
- All values in Rust have a lifetime, not just a reference. `spawn` requires a
  thread and all references it uses be `'static`. You can interpret `'static` as
  saying:
  - Give me an owned value (it won't disappear before the thread is done).
  - Give me a reference that is valid for the entire duration of the program.
- Transferring ownership with the `move` keyword is the easiest way to satisfy
  this if you own the data.
- One of the most common `'static` values is a reference to **static data**, in
  a region known as the **read-only data segment**, such as string literals:

  ```rs
  let s: &'static str = "Hello world!";
  ```

- When passed a `'static` reference, we can use it and references to it without
  `move`. In the tests, these passed `ARRAY` variable is declared with the
  `static` keyword after doing `use task_static_lifetime::*`.

  ```rs
  use std::thread;

  pub fn sum(slice: &'static [i32]) -> i32 {
      let mid = slice.len() / 2;
      let (slice1, slice2) = slice.split_at(mid);

      let handle1 = thread::spawn(move || slice1.iter().sum::<i32>());
      let handle2 = thread::spawn(move || slice2.iter().sum::<i32>());

      handle1.join().unwrap() + handle2.join().unwrap()
  }
  ```

### Leaking memory

- You can make a `'static` reference to heap data by using `Box::leak`.

  ```rs
  // Allocate a `u32` on the heap, by wrapping it in a `Box`.
  let x = Box::new(41u32);
  // Tell Rust that you'll never free that heap allocation
  // using `Box::leak`. You can thus get back a 'static reference.
  let static_ref: &'static mut u32 = Box::leak(x);
  ```

- Leaked memory is process scoped, so when the process exits, the operating
  system will reclaim that memory. So it can be valid to leak memory when:
  - The amount of memory you need to leak is bounded/known upfront, or
  - Your process is short-lived and you're confident you won't exhaust all the
    available memory before it exits.
- There are different `leak` implementations available for different types, like
  `Vec::leak`.

  ```rs
  use std::thread;

  pub fn sum(v: Vec<i32>) -> i32 {
      let v = Vec::leak(v);
      let mid = v.len() / 2;
      let (left, right) = v.split_at(mid);
      let t1 = thread::spawn(|| left.iter().sum::<i32>());
      let t2 = thread::spawn(|| right.iter().sum::<i32>());
      t1.join().unwrap() + t2.join().unwrap()
  }
  ```

- It is also not incorrect to use `move`, and since `move` is necessary most of
  the time, it is very common to see even with `'static` references. And `leak`
  is available as a method on the `Vec`:

  ```rs
  use std::thread;

  pub fn sum(v: Vec<i32>) -> i32 {
      let v = v.leak();
      let mid = v.len() / 2;
      let (v1, v2) = v.split_at(mid);

      let handle1 = thread::spawn(move || v1.into_iter().sum::<i32>());
      let handle2 = thread::spawn(move || v2.into_iter().sum::<i32>());

      handle1.join().unwrap() + handle2.join().unwrap()
  }
  ```

### Scoped threads

- We can also sidestep the issue of a thread outliving its parent by using
  **scoped threads**.

  ```rs
  let v = vec![1, 2, 3];

  let midpoint = v.len() / 2;

  std::thread::scope(|scope| {
      scope.spawn(|| {
          let first = &v[..midpoint];
          println!("Here's the first half of v: {first:?}");
      });
      scope.spawn(|| {
          let second = &v[midpoint..];
          println!("Here's the second half of v: {second:?}");
      });
  });

  println!("Here's v: {v:?}");
  ```

- All threads spawned by using a `Scope` will be **automatically joined** when
  the scope ends. You can still manually call `join`.

  ```rs
  pub fn sum(v: Vec<i32>) -> i32 {
      let mid = v.len() / 2;
      let (left, right) = v.split_at(mid);

      std::thread::scope(|s| {
          let left = s.spawn(|| left.iter().sum::<i32>());
          let right = s.spawn(|| right.iter().sum::<i32>());
          left.join().unwrap() + right.join().unwrap()
      })
  }
  ```

### Channels

- So far we have had limited communication.
  - The spawned thread borrowed/consumed data from the parent context.
  - The spawned thread returned data to the parent when joined.
- However, we plan to design a client-server architecture with one long-running
  server thread and multiple client threads sending commands and queries to the
  stateful thread in order to change its state (e.g. add a ticket) or retrieve
  information (e.g. the status of a ticket). So clients need to be able to send
  or receive data from the server thread after it has been launched. We can
  solve the issue with **channels**.
- Rust's standard library provides **multi-producer, single-consumer** (mpsc)
  channels in its `std::sync::mpsc` module. There are two channel flavours:
  bounded and unbounded. We'll use unbounded for now. Channel creation is like:

  ```rs
  use std::sync::mpsc::channel;

  let (sender, receiver) = channel();
  ```

- You get a sender and receiver end.
  - You call `send` on the `sender` to push data into the channel.
  - You call `recv` on the `receiver` to pull data from the channel.
  - `Sender` is cloneable; we can create one per client and they will all push
    data onto the same channel.
  - `Receiver` is not cloneable; there can be only one `receiver` per channel.
  - Both `Sender` and `Receiver` are generic over a type parameter `T`. That's
    the type of the messages that can travel on our channel. It could be a
    `u64`, a `struct`, an `enum`, etc.
  - `send` returns an error if the receiver has been dropped.
  - `recv` returns an error if all senders have been dropped and the channel is
    empty.
  - In other words, `send` and `recv` error when the channel is effectively
    closed.
- This example was a relatively simple demonstration of sending on a channel,
  but a good reminder that we're building a ticket system.

  ```rs
  // src/lib.rs
  use crate::data::TicketDraft;
  use crate::store::TicketStore;
  use std::sync::mpsc::{Receiver, Sender};

  pub mod data;
  pub mod store;

  pub enum Command {
      Insert(TicketDraft),
  }

  // Start the system by spawning the server thread.
  // It returns a `Sender` instance which can then be used
  // by one or more clients to interact with the server.
  pub fn launch() -> Sender<Command> {
      let (sender, receiver) = std::sync::mpsc::channel();
      std::thread::spawn(move || server(receiver));
      sender
  }

  // The server task should **never** stop.
  // Enter a loop: wait for a command to show up in
  // the channel, then execute it, then start waiting
  // for the next command.
  pub fn server(receiver: Receiver<Command>) {
      let mut store = TicketStore::new();
      while let Ok(command) = receiver.recv() {
          match command {
              Command::Insert(ticket_draft) => {
                  store.add_ticket(ticket_draft);
              }
          }
      }
  }

  // src/data.rs
  use crate::store::TicketId;
  use ticket_fields::{TicketDescription, TicketTitle};

  #[derive(Clone, Debug, PartialEq)]
  pub struct Ticket {
      pub id: TicketId,
      pub title: TicketTitle,
      pub description: TicketDescription,
      pub status: Status,
  }

  #[derive(Clone, Debug, PartialEq, Eq)]
  pub struct TicketDraft {
      pub title: TicketTitle,
      pub description: TicketDescription,
  }

  #[derive(Clone, Debug, Copy, PartialEq, Eq)]
  pub enum Status {
      ToDo,
      InProgress,
      Done,
  }

  // src/store.rs
  use crate::data::{Status, Ticket, TicketDraft};
  use std::collections::BTreeMap;

  #[derive(Clone, Copy, Debug, PartialEq, Eq, PartialOrd, Ord)]
  pub struct TicketId(u64);

  #[derive(Clone)]
  pub struct TicketStore {
      tickets: BTreeMap<TicketId, Ticket>,
      counter: u64,
  }

  impl TicketStore {
      pub fn new() -> Self {
          Self {
              tickets: BTreeMap::new(),
              counter: 0,
          }
      }

      pub fn add_ticket(&mut self, ticket: TicketDraft) -> TicketId {
          let id = TicketId(self.counter);
          self.counter += 1;
          let ticket = Ticket {
              id,
              title: ticket.title,
              description: ticket.description,
              status: Status::ToDo,
          };
          self.tickets.insert(id, ticket);
          id
      }
  }

  // tests/tests.rs
  use std::time::Duration;
  use task_channels::data::TicketDraft;
  use task_channels::{launch, Command};
  use ticket_fields::test_helpers::{ticket_description, ticket_title};

  #[test]
  fn a_thread_is_spawned() {
      let sender = launch();
      std::thread::sleep(Duration::from_millis(200));

      sender
          .send(Command::Insert(TicketDraft {
              title: ticket_title(),
              description: ticket_description(),
          }))
          // If the thread is no longer running, this will panic
          // because the channel will be closed.
          .expect("Did you actually spawn a thread? The channel is closed!");
  }
  ```

### Interior Mutability

- `Sender<T>` is not only immutable but is cloneable, despite obviously changing
  the contents of the channel. Whenever a type allows you to mutate data through
  a shared reference, you're dealing with **interior mutability**.
- You can tell the compiler "No, this shared reference is actually mutable" by
  wrapping the data in an `UnsafeCell`. Every time you see a type that allows
  interior mutability, you can be certain that UnsafeCell is involved, either
  interior mutability, you can be certain that `UnsafeCell` is involved, either
  directly or indirectly. Using `UnsafeCell`, raw pointers and unsafe code, you
  can mutate data through shared references. `unsafe` code is still subject to
  the rules about borrowing and aliasing. When you use `unsafe`, you are telling
  the compiler "I know what I am doing, I won't violate your invariants, trust
  me."
- Every time you call an unsafe function, there will be documentation explaining
  its safety preconditions: under what circumstances it's safe to execute its
  `unsafe` block.
- `Rc<T>` is a reference-counted pointer. It wraps around a value and keeps
  track of how many references to the value exist. When the last reference is
  dropped, the value is deallocated. The value wrapped in an `Rc` is immutable:
  you can only get shared references to it. `Rc` uses `UnsafeCell` internally to
  allow shared references to increment and decrement the reference count.
- `RefCell<T>` is one of the most common examples of interior mutability in
  Rust. It allows you to mutate the value wrapped in a `RefCell` even if you
  only have an immutable reference to the `RefCell` itself. This is done via
  runtime borrow checking. The `RefCell` keeps track of the number (and type) of
  references to the value it contains at runtime. If you try to borrow the value
  mutably while it's already borrowed immutably, the program will panic,
  ensuring that Rust's borrowing rules are always enforced.

  ```rs
  use std::cell::RefCell;
  use std::rc::Rc;

  pub struct DropTracker<T> {
      value: T,
      counter: Rc<RefCell<usize>>,
  }

  impl<T> DropTracker<T> {
      pub fn new(value: T, counter: Rc<RefCell<usize>>) -> Self {
          Self { value, counter }
      }
  }

  impl<T> Drop for DropTracker<T> {
      fn drop(&mut self) {
          *self.counter.borrow_mut() += 1;
      }
  }

  // tests/tests.rs
  # [cfg(test)]
  #[cfg(test)]
  mod tests {
      use std::cell::RefCell;
      use std::rc::Rc;
      use task_interior_mutability::*;

      #[test]
      fn it_works() {
          let counter = Rc::new(RefCell::new(0));
          let _ = DropTracker::new((), Rc::clone(&counter));
          assert_eq!(*counter.borrow(), 1);
      }

      #[test]
      fn multiple() {
          let counter = Rc::new(RefCell::new(0));

          {
              let a = DropTracker::new(5, Rc::clone(&counter));
              let b = DropTracker::new(6, Rc::clone(&counter));
          }

          assert_eq!(*counter.borrow(), 2);
      }
  }
  ```

### Ack pattern

- We need a way for the server to send a response back to the client. There are
  various ways to do this, but the simplest option is to include a `Sender`
  channel in the message that the client sends to the server. After processing
  the message, the server can use this channel to send a response back to the
  client.
- This is a fairly common pattern in Rust applications built on top of
  message-passing primitives.

  ```rs
  // src/lib.rs
  use crate::data::{Ticket, TicketDraft};
  use crate::store::{TicketId, TicketStore};
  use std::sync::mpsc::{Receiver, Sender};

  pub mod data;
  pub mod store;

  // Refer to the tests to understand the expected schema.
  pub enum Command {
      Insert {
          draft: TicketDraft,
          response_sender: Sender<TicketId>,
      },
      Get {
          id: TicketId,
          response_sender: Sender<Option<Ticket>>,
      },
  }

  pub fn launch() -> Sender<Command> {
      let (sender, receiver) = std::sync::mpsc::channel();
      std::thread::spawn(move || server(receiver));
      sender
  }

  // TODO: handle incoming commands as expected.
  pub fn server(receiver: Receiver<Command>) {
      let mut store = TicketStore::new();
      loop {
          match receiver.recv() {
              Ok(Command::Insert {
                  draft,
                  response_sender,
              }) => {
                  let id = store.add_ticket(draft);
                  let _ = response_sender.send(id);
              }
              Ok(Command::Get {
                  id,
                  response_sender,
              }) => {
                  let ticket = store.get(id);
                  let _ = response_sender.send(ticket.cloned());
              }
              Err(_) => {
                  // There are no more senders, so we can safely break
                  // and shut down the server.
                  break;
              }
          }
      }
  }

  // tests/tests.rs
  use task_ack_pattern::data::{Status, Ticket, TicketDraft};
  use task_ack_pattern::store::TicketId;
  use task_ack_pattern::{launch, Command};
  use ticket_fields::test_helpers::{ticket_description, ticket_title};

  #[test]
  fn insert_works() {
      let sender = launch();
      let (response_sender, response_receiver) = std::sync::mpsc::channel();

      let draft = TicketDraft {
          title: ticket_title(),
          description: ticket_description(),
      };
      let command = Command::Insert {
          draft: draft.clone(),
          response_sender,
      };

      sender
          .send(command)
          // If the thread is no longer running, this will panic
          // because the channel will be closed.
          .expect("Did you actually spawn a thread? The channel is closed!");

      let ticket_id: TicketId =
          response_receiver.recv().expect("No response received!");

      let (response_sender, response_receiver) = std::sync::mpsc::channel();
      let command = Command::Get {
          id: ticket_id,
          response_sender,
      };
      sender
          .send(command)
          .expect("Did you actually spawn a thread? The channel is closed!");

      let ticket: Ticket = response_receiver
          .recv()
          .expect("No response received!")
          .unwrap();
      assert_eq!(ticket_id, ticket.id);
      assert_eq!(ticket.status, Status::ToDo);
      assert_eq!(ticket.title, draft.title);
      assert_eq!(ticket.description, draft.description);
  }
  ```

- Doing `let _ = response_sender.send(...)` explicitly tells the compiler: "I
  know this can fail if the client went away, and I am deliberately ignoring it
  so the server stays alive." It stops warnings about unused `Result` values.

### Client

- All the interactions from the client side have been fairly low-level: you have
  to manually create a response channel, build the command, send it to the
  server, and then call `recv` on the response channel to get the response.

  ```rs
  // src/lib.rs
  use crate::data::{Ticket, TicketDraft};
  use crate::store::{TicketId, TicketStore};
  use std::sync::mpsc::{Receiver, Sender};

  pub mod data;
  pub mod store;

  #[derive(Clone)]
  // TODO: flesh out the client implementation.
  pub struct TicketStoreClient {
      sender: Sender<Command>,
  }

  impl TicketStoreClient {
      // Feel free to panic on all errors, for simplicity.
      pub fn insert(&self, draft: TicketDraft) -> TicketId {
          let (response_sender, response_receiver) = std::sync::mpsc::channel();
          self.sender
              .send(Command::Insert {
                  draft,
                  response_channel: response_sender,
              })
              .unwrap();
          response_receiver.recv().unwrap()
      }

      pub fn get(&self, id: TicketId) -> Option<Ticket> {
          let (response_sender, response_receiver) = std::sync::mpsc::channel();
          self.sender
              .send(Command::Get {
                  id,
                  response_channel: response_sender,
              })
              .unwrap();
          response_receiver.recv().unwrap()
      }
  }

  pub fn launch() -> TicketStoreClient {
      let (sender, receiver) = std::sync::mpsc::channel();
      std::thread::spawn(move || server(receiver));
      TicketStoreClient { sender }
  }

  // No longer public! This becomes an internal detail of the library now.
  enum Command {
      Insert {
          draft: TicketDraft,
          response_channel: Sender<TicketId>,
      },
      Get {
          id: TicketId,
          response_channel: Sender<Option<Ticket>>,
      },
  }

  fn server(receiver: Receiver<Command>) {
      let mut store = TicketStore::new();
      loop {
          match receiver.recv() {
              Ok(Command::Insert {
                  draft,
                  response_channel,
              }) => {
                  let id = store.add_ticket(draft);
                  let _ = response_channel.send(id);
              }
              Ok(Command::Get {
                  id,
                  response_channel,
              }) => {
                  let ticket = store.get(id);
                  let _ = response_channel.send(ticket.cloned());
              }
              Err(_) => {
                  // There are no more senders, so we can safely break
                  // and shut down the server.
                  break;
              }
          }
      }
  }

  // tests/test.rs
  use task_client::data::{Status, TicketDraft};
  use task_client::launch;
  use ticket_fields::test_helpers::{ticket_description, ticket_title};

  #[test]
  fn insert_works() {
      // Notice how much simpler the test is now that we have a client to
      // handle the details!
      let client = launch();
      let draft = TicketDraft {
          title: ticket_title(),
          description: ticket_description(),
      };
      let ticket_id = client.insert(draft.clone());
      let client2 = client.clone();
      let ticket = client2.get(ticket_id).unwrap();
      assert_eq!(ticket_id, ticket.id);
      assert_eq!(ticket.status, Status::ToDo);
      assert_eq!(ticket.title, draft.title);
      assert_eq!(ticket.description, draft.description);
  }
  ```

### Bounded channels

- Never use an unbounded channel in a production system. You can enforce an
  upper limit on the number of messages that can be enqueued with a **bounded
  channel**. You create one by calling `sync_channel` with a capacity greater
  than zero.

  ```rs
  use std::sync::mpsc::sync_channel;

  let (sender, receiver) = sync_channel(10);
  ```

- `receiver` still has type `Receiver<T>` but `sender` is `SyncSender<T>`. You
  have two methods to send with:
  - `send`: if there is space in the channel, it will enqueue the message and
    return `Ok(())`. If the channel is full, it will block and wait until there
    is space available.
  - `try_send`: if there is space in the channel, it will enqueue the message
    and return `Ok(())`. If the channel is full, it will return
    `Err(TrySendError::Full(value))`, where `value` is the message that couldn't
    be sent.
- Bounded channels provide a form of **backpressure**, and prevent end users
  from overwhelming the system with requests.

  ```rs
  // src/lib.rs
  use crate::data::{Ticket, TicketDraft};
  use crate::store::{TicketId, TicketStore};
  use std::sync::mpsc::{Receiver, SyncSender};

  pub mod data;
  pub mod store;

  #[derive(Clone)]
  pub struct TicketStoreClient {
      sender: SyncSender<Command>,
  }

  impl TicketStoreClient {
      pub fn insert(&self, draft: TicketDraft) -> Result<TicketId, OverloadedError> {
          let (response_sender, response_receiver) = std::sync::mpsc::sync_channel(1);
          self.sender
              .try_send(Command::Insert {
                  draft,
                  response_channel: response_sender,
              })
              .map_err(|_| OverloadedError)?;
          Ok(response_receiver.recv().unwrap())
      }

      pub fn get(&self, id: TicketId) -> Result<Option<Ticket>, OverloadedError> {
          let (response_sender, response_receiver) = std::sync::mpsc::sync_channel(1);
          self.sender
              .try_send(Command::Get {
                  id,
                  response_channel: response_sender,
              })
              .map_err(|_| OverloadedError)?;
          Ok(response_receiver.recv().unwrap())
      }
  }

  #[derive(Debug, thiserror::Error)]
  #[error("The store is overloaded")]
  pub struct OverloadedError;

  pub fn launch(capacity: usize) -> TicketStoreClient {
      let (sender, receiver) = std::sync::mpsc::sync_channel(capacity);
      std::thread::spawn(move || server(receiver));
      TicketStoreClient { sender }
  }

  enum Command {
      Insert {
          draft: TicketDraft,
          response_channel: SyncSender<TicketId>,
      },
      Get {
          id: TicketId,
          response_channel: SyncSender<Option<Ticket>>,
      },
  }

  fn server(receiver: Receiver<Command>) {
      let mut store = TicketStore::new();
      loop {
          match receiver.recv() {
              Ok(Command::Insert {
                  draft,
                  response_channel,
              }) => {
                  let id = store.add_ticket(draft);
                  let _ = response_channel.send(id);
              }
              Ok(Command::Get {
                  id,
                  response_channel,
              }) => {
                  let ticket = store.get(id);
                  let _ = response_channel.send(ticket.cloned());
              }
              Err(_) => {
                  // There are no more senders, so we can safely break
                  // and shut down the server.
                  break;
              }
          }
      }
  }

  // tests/tests.rs
  use task_bounded_channels::data::{Status, TicketDraft};
  use task_bounded_channels::launch;
  use ticket_fields::test_helpers::{ticket_description, ticket_title};

  #[test]
  fn works() {
      let client = launch(5);
      let draft = TicketDraft {
          title: ticket_title(),
          description: ticket_description(),
      };
      let ticket_id = client.insert(draft.clone()).unwrap();

      let client2 = client.clone();
      let ticket = client2.get(ticket_id).unwrap().unwrap();
      assert_eq!(ticket_id, ticket.id);
      assert_eq!(ticket.status, Status::ToDo);
      assert_eq!(ticket.title, draft.title);
      assert_eq!(ticket.description, draft.description);
  }
  ```

### Patching

- In the single-threaded version, we just returned a `mut` reference for
  updating. But `SyncSender<&mut Ticket>` isn't `'static` because `&mut Ticket`
  doesn't satisfy `'static` lifetime, so it cannot be captured by the closure we
  pass to `std::thread::spawn`. We can get a mutable reference on the server
  though and do the update for the client. We'll have the client send a
  `TicketPatch`.

  ```rs
  struct TicketPatch {
      id: TicketId,
      title: Option<TicketTitle>,
      description: Option<TicketDescription>,
      status: Option<TicketStatus>,
  }
  ```

- The `id` is mandatory to identify the `Ticket`, but the other fields are
  optional. If the field is `None`, the `Ticket` field should not be changed. A
  `Some` holds the new value for the corresponding field.

  ```rs
  impl TicketStoreClient {
  // --snip--
      pub fn update(&self, ticket_patch: TicketPatch) -> Result<(), OverloadedError> {
          let (response_sender, response_receiver) = sync_channel(1);
          self.sender
              .try_send(Command::Update {
                  patch: ticket_patch,
                  response_channel: response_sender,
              })
              .map_err(|_| OverloadedError)?;
          Ok(response_receiver.recv().unwrap())
      }
  }
  // --snip--
  enum Command {
      // --snip--
      Update {
          patch: TicketPatch,
          response_channel: SyncSender<()>,
      },
  }

  pub fn server(receiver: Receiver<Command>) {
      // --snip--
              Ok(Command::Update {
                  patch,
                  response_channel,
              }) => {
                  if let Some(ticket) = store.get_mut(patch.id) {
                      if let Some(title) = patch.title {
                          ticket.title = title;
                      }
                      if let Some(description) = patch.description {
                          ticket.description = description;
                      }
                      if let Some(status) = patch.status {
                          ticket.status = status;
                      }
                  }
                  let _ = response_channel.send(());
              }
              // --snip--
  }
  ```

### Mutex, Send, and Arc

- Our last version of this code had a problem with race conditions on updates.
  If A and B both send an update, they will be applied in the order received and
  the last updates will "win". One way to fix this is **optimistic concurrency
  control** where you assign the `Ticket` a version number which is updated on
  applying an update, and you only apply updates that have a matching version
  number. Another solution is a lock. Rust's standard library provides two
  different locking primitives: `Mutex<T>` and `RwLock<T>`.
- `Mutex<T>` allows one thread to access the data, whether its for reading or
  writing. The `Mutex` wraps the data it locks and you get a reference with
  `lock` or `try_lock`. `lock` will wait until the data is available where
  `try_lock` returns with an error if the lock cannot be acquired.

  ```rs
  use std::sync::Mutex;

  // An integer protected by a mutex lock
  let lock = Mutex::new(0);

  // Acquire a lock on the mutex
  let mut guard = lock.lock().unwrap();

  // Modify the data through the guard,
  // leveraging its `Deref` implementation
  *guard += 1;

  // The lock is released when `data` goes out of scope
  // This can be done explicitly by dropping the guard
  // or happen implicitly when the guard goes out of scope
  drop(guard)
  ```

- We could wrap our entire `TicketStore` in a `Mutex`. This is known as
  **coarse-grained locking**, and the problem is it severely limits performance
  of the system. It would be better to use **fine-grained locking**, where each
  ticket is protected by its own lock. This way, clients can keep working with
  tickets in parallel, as long as they aren't trying to access the same ticket.

  ```rs
  // The new structure, with a lock for each ticket

  struct TicketStore {
      tickets: BTreeMap<TicketId, Mutex<Ticket>>,
  }
  ```

- One drawback is that `TicketStore` is now aware of the multi-threaded nature
  of the system. Also for this scheme to work, the client should hold the lock
  for the ticket they are working with. We can't send `Mutex<Ticket>` across a
  channel, because `Mutex` is not `Clone` and we can't move it out of
  `TicketStore` and transfer ownership. We cannot use send the `MutexGuard` due
  to thread safety. `MutexGuard` does not implement `Send`.
- `Send` is a marker trait that indicates that a type can be safely transferred
  from one thread to another. `Send` is another auto-trait. You can implement it
  manually, but it requires `unsafe`. Channels are `Send` only if their generic
  type `T` is `Send`. `MutexGuard` is not `Send` because the underlying
  operating system primitives that `Mutex` uses to implement the lock require
  (on some platforms) that the lock must be released by the same thread that
  acquired it. If we were to send a `MutexGuard` to another thread, the lock
  would be released by a different thread, which would lead to undefined
  behavior.
- Our challenges:
  - We can't send a `MutexGuard` over a channel. So we can't lock on the
    server-side and then modify the ticket on the client-side.
  - Sending `Mutex<Ticket>` itself _is_ allowed by `Send` (because `Mutex<T>` is
    `Send` when `T` is `Send`), **but** ownership gets in the way: we can't move
    the `Mutex` out of `TicketStore` without losing it from the store, and
    `Mutex` isn't `Clone`.
- Looking at this differently, to lock a `Mutex` we don't need an owned value. A
  shared reference is enough since `Mutex` uses interior mutability. So it would
  be enough to send a shared reference to the client, but the reference would
  have to be `'static`. So we need an "owned shared reference".
- `Arc` stands for **atomic reference counting**. `Arc` wraps around a value and
  keeps track of how many references to the value exist. When the last reference
  is dropped, the value is deallocated. The value wrapped in an `Arc` is
  immutable: you can only get shared references to it.

  ```rs
  use std::sync::Arc;

  let data: Arc<u32> = Arc::new(0);
  let data_clone = Arc::clone(&data);

  // `Arc<T>` implements `Deref<T>`, so can convert
  // a `&Arc<T>` to a `&T` using deref coercion
  let data_ref: &u32 = &data;
  ```

- The difference between `Rc` and `Arc` is that `Arc` is thread-safe and `Send`,
  where `Rc` is not.
- `Arc<Mutex<T>>`. If we pair `Arc` with `Mutex`, we finally get a type that:
  - Can be sent between threads, because:
    - `Arc` is `Send` if `T` is `Send`, and
    - `Mutex` is `Send` if `T` is `Send`.
    - `T` is `Ticket`, which is `Send`.
  - Can be cloned, because `Arc` is `Clone` no matter what `T` is. Cloning an
    `Arc` increments the reference count, the data is not copied.
  - Can be used to modify the data it wraps, because `Arc` lets you get a shared
    reference to `Mutex<T>` which can in turn be used to acquire a lock.

  ```rs
  // lib/store.rs
  use crate::data::{Status, Ticket, TicketDraft};
  use std::collections::BTreeMap;
  use std::sync::{Arc, Mutex};

  #[derive(Clone, Copy, Debug, PartialEq, Eq, PartialOrd, Ord)]
  pub struct TicketId(u64);

  #[derive(Clone)]
  pub struct TicketStore {
    tickets: BTreeMap<TicketId, Arc<Mutex<Ticket>>>,
    counter: u64,
  }

  impl TicketStore {
      pub fn new() -> Self {
          Self {
              tickets: BTreeMap::new(),
              counter: 0,
          }
      }

      pub fn add_ticket(&mut self, ticket: TicketDraft) -> TicketId {
          let id = TicketId(self.counter);
          self.counter += 1;
          let ticket = Ticket {
              id,
              title: ticket.title,
              description: ticket.description,
              status: Status::ToDo,
          };
          self.tickets.insert(id, Arc::new(Mutex::new(ticket)));
          id
      }

      // The `get` method should return a handle to the ticket
      // which allows the caller to either read or modify the ticket.
      pub fn get(&self, id: TicketId) -> Option<Arc<Mutex<Ticket>>> {
          self.tickets.get(&id).cloned()
      }
  }

  // tests/tests.rs
  use task_mutex_send_arc::data::{Status, TicketDraft};
  use task_mutex_send_arc::launch;
  use ticket_fields::test_helpers::{ticket_description, ticket_title};

  #[test]
  fn works() {
      let client = launch(5);
      let draft = TicketDraft {
          title: ticket_title(),
          description: ticket_description(),
      };
      let ticket_id = client.insert(draft.clone()).unwrap();

      let ticket = client.get(ticket_id).unwrap().unwrap();
      {
          let mut ticket = ticket.lock().unwrap();
          assert_eq!(ticket_id, ticket.id);
          assert_eq!(ticket.status, Status::ToDo);
          assert_eq!(ticket.title, draft.title);
          assert_eq!(ticket.description, draft.description);

          ticket.status = Status::InProgress;
      }

      let ticket = client.get(ticket_id).unwrap().unwrap();
      {
          let ticket = ticket.lock().unwrap();
          assert_eq!(ticket_id, ticket.id);
          assert_eq!(ticket.status, Status::InProgress);
      }
  }
  ```

- Here is the exact type at each step from the above example:

  ```rs
  let ticket = client.get(ticket_id).unwrap().unwrap();
  ```

  1. **`client.get(ticket_id)`** returns:
     `Result<Option<Arc<Mutex<Ticket>>>, OverloadedError>` _(from the
     bounded-channel `TicketStoreClient` you wrote in the previous chapter)_
  2. **1st `.unwrap()`** unwraps the **`Result`**, asserting the bounded channel
     wasn't full (`OverloadedError`), leaving: `Option<Arc<Mutex<Ticket>>>`
  3. **2nd `.unwrap()`** unwraps the **`Option`**, asserting `TicketStore`
     actually found a ticket for `ticket_id`, leaving: `Arc<Mutex<Ticket>>`

- Then a few lines later:

  ```rs
  let mut ticket = ticket.lock().unwrap();
  ```

  1. **`ticket.lock()`** (through `Arc`'s `Deref` to `&Mutex<Ticket>`) returns
     `Result<MutexGuard<'_, Ticket>, PoisonError<...>>`, and **`.unwrap()`**
     asserts no thread panicked while holding that lock, giving you the
     `MutexGuard<'_, Ticket>`.

- `self.tickets.get(&id)` returns `Option<&Arc<Mutex<Ticket>>>`—an `Option`
  holding a **reference**.
  - **`.clone()`** calls `Clone` on the **`Option` itself**. Since a shared
    reference `&T` is `Copy`, cloning `Option<&T>` just gives you another
    `Option<&T>` (`Option<&Arc<Mutex<Ticket>>>`)—still a reference.
  - **`.cloned()`** reaches _inside_ the `Option` and clones the **inner `T`**,
    turning `Option<&T>` into `Option<T>` (`Option<Arc<Mutex<Ticket>>>`).
  - It's shorthand for:

    ```rs
    self.tickets.get(&id).map(|arc| arc.clone())
    ```

  - _(Same idea on iterators: `iter.cloned()` turns an iterator of `&T` into an
    iterator of owned `T`.)_

- It only peels off **one level of `&` reference**—it isn't "shallow vs. deep":
  - `Option<&T>` has an `&` inside it.
    - `.clone()` clones the **`Option<&T>`** itself (copying the `&T` pointer →
      still `Option<&T>`).
    - `.cloned()` steps **one level in**, calls `T::clone()` on the pointed-to
      `T`, and gives you `Option<T>`.
  - Two quick sanity checks that show how it's just "one `&` deeper":
    - Here, `T` is `Arc<Mutex<Ticket>>`, so `T::clone()` is still just a cheap
      `Arc` ref-count bump—it doesn't deep-copy `Ticket`.
    - If you somehow had `Option<&&T>`, `.cloned()` would only strip one `&`,
      leaving `Option<&T>`.

### RwLock

- Our new `TicketStore` works, but its read performance is not great: there can
  only be one client at a time reading a specific ticket, because `Mutex<T>`
  doesn't distinguish between readers and writers. We can solve the issue by
  using a different locking primitive: `RwLock<T>`. `RwLock<T>` stands for
  read-write lock. It allows multiple readers to access the data simultaneously,
  but only one writer at a time. `RwLock<T>` has two methods to acquire a lock:
  `read` and `write`. `read` returns a guard that allows you to read the data,
  while `write` returns a guard that allows you to modify it.

  ```rs
  use std::sync::RwLock;

  // An integer protected by a read-write lock
  let lock = RwLock::new(0);

  // Acquire a read lock on the RwLock
  let guard1 = lock.read().unwrap();

  // Acquire a **second** read lock
  // while the first one is still active
  let guard2 = lock.read().unwrap();
  ```

- On the surface, `RwLock<T>` seems like a no-brainer: it provides a superset of
  the functionality of `Mutex<T>`. Why would you ever use `Mutex<T>` if you can
  use `RwLock<T>` instead?
  - Locking a `RwLock<T>` is more expensive than locking a `Mutex<T>`. This is
    because `RwLock<T>` has to keep track of the number of active readers and
    writers, while `Mutex<T>` only has to keep track of whether the lock is held
    or not. This performance overhead is not an issue if there are more readers
    than writers, but if the workload is write-heavy `Mutex<T>` might be a
    better choice.
  - `RwLock<T>` can cause writer starvation. If there are always readers waiting
    to acquire the lock, writers might never get a chance to run.
  - `RwLock<T>` doesn't provide any guarantees about the order in which readers
    and writers are granted access to the lock. It depends on the policy
    implemented by the underlying OS, which might not be fair to writers.
- We can expect our workload to be read-heavy (since most clients will be
  reading tickets, not modifying them), so `RwLock<T>` is a good choice.
- The exercise for this one was simply replacing `Mutex` with `RwLock` in the
  previous example. The most notable difference was that the test now uses
  `read` and `write` to get access to the resource.
- Another change I didn't really notice until this example is now we are
  accessing our `BTreeMap` exclusively with `get`. We never need to `get_mut`,
  since we are using interior mutability from a `Mutex` or `RwLock`.
  `TicketStore` doesn't need to know or care whether the caller intends to read
  or modify the ticket.

### Without channels

- We currently use channels to share `TicketStore` across threads and
  synchronize access to the store. Without channels, we could share access to
  `TicketStore` with `Arc`. And if we remove the channels, we need to introduce
  another lock to synchronize access to the `TicketStore` itself (when actually
  inserting or removing a ticket from the store). If we use a `Mutex`, then it
  makes no sense to use an additional `RwLock` for each ticket: the `Mutex` will
  already serialize access to the entire store. If we use a `RwLock`, instead,
  we can read tickets in parallel. We just need to pause all reads while
  inserting or removing a ticket.
- The change for this exercise was a one-liner in the tests. We instantiate the
  `TicketStore` with an `Arc` and `RwWrite` lock, then the client uses clones
  directly via the `read` and `write` methods. We didn't have to modify
  store.rs, and most of the changes to lib.rs were removing the client type, the
  launch function, and the command enum. Our final concurrent solution:

  ```rs
  // tests/tests.rs
  use std::sync::{Arc, RwLock};
  use std::thread::spawn;

  use task_without_channels::data::TicketDraft;
  use task_without_channels::store::TicketStore;
  use ticket_fields::test_helpers::{ticket_description, ticket_title};

  #[test]
  fn works() {
      let store = Arc::new(RwLock::new(TicketStore::new()));

      let store1 = store.clone();
      let client1 = spawn(move || {
          let draft = TicketDraft {
              title: ticket_title(),
              description: ticket_description(),
          };
          store1.write().unwrap().add_ticket(draft)
      });

      let store2 = store.clone();
      let client2 = spawn(move || {
          let draft = TicketDraft {
              title: ticket_title(),
              description: ticket_description(),
          };
          store2.write().unwrap().add_ticket(draft)
      });

      let ticket_id1 = client1.join().unwrap();
  }

  // src/lib.rs
  pub mod data;
  pub mod store;

  // src/store.rs
  use std::collections::BTreeMap;
  use std::sync::{Arc, RwLock};
  use crate::data::{Status, Ticket, TicketDraft};

  #[derive(Clone, Copy, Debug, PartialEq, Eq, PartialOrd, Ord)]
  pub struct TicketId(u64);

  #[derive(Clone)]
  pub struct TicketStore {
      tickets: BTreeMap<TicketId, Arc<RwLock<Ticket>>>,
      counter: u64,
  }

  impl TicketStore {
      pub fn new() -> Self {
          Self {
              tickets: BTreeMap::new(),
              counter: 0,
          }
      }

      pub fn add_ticket(&mut self, ticket: TicketDraft) -> TicketId {
          let id = TicketId(self.counter);
          self.counter += 1;
          let ticket = Ticket {
              id,
              title: ticket.title,
              description: ticket.description,
              status: Status::ToDo,
          };
          let ticket = Arc::new(RwLock::new(ticket));
          self.tickets.insert(id, ticket);
          id
      }

      pub fn get(&self, id: TicketId) -> Option<Arc<RwLock<Ticket>>> {
          self.tickets.get(&id).cloned()
      }
  }

  // src/data.rs
  use crate::store::TicketId;
  use ticket_fields::{TicketDescription, TicketTitle};

  #[derive(Clone, Debug, PartialEq)]
  pub struct Ticket {
      pub id: TicketId,
      pub title: TicketTitle,
      pub description: TicketDescription,
      pub status: Status,
  }

  #[derive(Clone, Debug, PartialEq, Eq)]
  pub struct TicketDraft {
      pub title: TicketTitle,
      pub description: TicketDescription,
  }

  #[derive(Clone, Debug, Copy, PartialEq, Eq)]
  pub enum Status {
      ToDo,
      InProgress,
      Done,
  }
  ```

- The code looks very similar to the one from the previous exercise. The main
  difference is that we don't have a client type anymore. Instead, we just pass
  around the `Arc` to the store. This implementation has much of the
  functionality we've built out previously with no code in lib.rs at all (it
  just re-exports and declares `data` and `store` modules).
- In Go or Elixir, the channel implementation would have been the final
  implementation, but in Rust where we have good data-race free locking
  mechanisms, it's unnecessary. Channels are still built into the standard
  library, but in practice, Rust codebases tend to use `Arc<Mutex<T>>` /
  `Arc<RwLock<T>>` (or concurrent maps like `DashMap`) for shared state, and
  reserve channels/actors for work queues, backpressure, or decoupling
  independent tasks.

### Sync trait

- `Sync` is an auto trait, just like `Send`. It is automatically implemented by
  all types that can be safely shared between threads. In other words: `T` is
  `Sync` if `&T` is `Send`. `T: Sync` doesn't imply `T: Send` (ex: `MutexGuard`,
  which isn't `Send` due to the same thread needing to manage the lock) and
  `T: Send` doesn't imply `T: Sync` (ex: `RefCell<T>`, which isn't `Sync` due to
  non-atomic counters).

## Chapter 8 - Futures

### Asynchronous Functions

- You define an asynchronous function with the `async` keyword. Asynchronous
  functions in Rust are lazy, so if you call them directly, they do nothing. The
  `await` keyword is the most common way to ask an asynchronous function to do
  some work. You have to choose an asynchronous executor with Rust, and we will
  use `tokio`, which is optimized for general purpose use.
- In `tokio` you label your `main` with `#[tokio::main]` and mark it `async`,
  unless you need sync-first startup (parsing CLI args, loading config, etc).
  There is also a `#[tokio::test]` function for asynchronous tests. These are
  both convenient and not magic. Here is the expanation of `#[tokio::main]`:

  ```rs
  #[tokio::main]
  async fn main() {
      // Your async code goes here
  }
  // which expands to:
  fn main() {
      let rt = tokio::runtime::Runtime::new().unwrap();
      rt.block_on(
          // Your async function goes here
          // [...]
      );
  }

  // And here is how you declare an async test
  #[tokio::test]
  async fn my_test() {
      // Your async test code goes here
  }
  ```

- The exercise was a simple asynchronous `echo` function.

  ```rs
  // src/lib.rs
  use tokio::net::TcpListener;

  pub async fn echo(listener: TcpListener) -> Result<(), anyhow::Error> {
      loop {
          let (mut socket, _) = listener.accept().await?;
          let (mut reader, mut writer) = socket.split();
          tokio::io::copy(&mut reader, &mut writer).await?;
      }
  }

  // tests/tests.rs
  #[cfg(test)]
  mod tests {
      use task_async_functions::*;
      use tokio::io::{AsyncReadExt, AsyncWriteExt};
      use tokio::net::TcpListener;

      #[tokio::test]
      async fn test_echo() {
          let listener = TcpListener::bind("127.0.0.1:0").await.unwrap();
          let addr = listener.local_addr().unwrap();
          tokio::spawn(echo(listener));

          let requests = vec!["hello", "world", "foo", "bar"];

          for request in requests {
              let mut socket = tokio::net::TcpStream::connect(addr).await.unwrap();
              let (mut reader, mut writer) = socket.split();

              // Send the request
              writer.write_all(request.as_bytes()).await.unwrap();
              // Close the write side of the socket
              writer.shutdown().await.unwrap();

              // Read the response
              let mut buf = Vec::with_capacity(request.len());
              reader.read_to_end(&mut buf).await.unwrap();
              assert_eq!(&buf, request.as_bytes());
          }
      }
  }
  ```

### Spawning tasks

- `tokio::spawn` allows you to hand a task off to the executor without waiting
  for it to complete like you would with `await`. Here is a version of the last
  exercise that handles multiple requests simultaneously.

  ```rs
  use tokio::net::TcpListener;

  pub async fn echo(listener: TcpListener) -> Result<(), anyhow::Error> {
      loop {
          let (mut socket, _) = listener.accept().await?;
          // Spawn a background task to handle the connection
          // thus allowing the main task to immediately start
          // accepting new connections
          tokio::spawn(async move {
              let (mut reader, mut writer) = socket.split();
              tokio::io::copy(&mut reader, &mut writer).await?;
          });
      }
  }
  ```

- In the last example, we use an **asynchronous block**. This is a quick way to
  define a section of code as asynchronous without declaring a separate async
  function.
- `tokio::spawn` returns a `JoinHandle`. You can use the `JoinHandle` to await a
  background task, much like we used `join` for spawned threads.
- If a task spawned by `tokio::spawn` panics, it will be caught by the executor.
  The `JoinHandle` returns a `Result` with the error type `JoinError`. You can
  call `JoinError::is_panic` to check if the task panicked.

  ```rs
  pub async fn run() {
      let handle = tokio::spawn(work());
      if let Err(e) = handle.await {
          if let Ok(reason) = e.try_into_panic() {
              // Resume unwinding the panic, propagating it to the current task
              panic::resume_unwind(reason);
          }
      }
  }

  pub async fn work() {
      // [...]
  }
  ```

- The main difference between `tokio::spawn` and `thread::spawn` is that the
  `thread` method hands off control to the operating system while `tokio` gives
  it to the executor that runs in user space.

  ```rs
  use tokio::net::TcpListener;

  pub async fn echoes(first: TcpListener, second: TcpListener) -> Result<(), anyhow::Error> {
      let handle1 = tokio::spawn(echo(first));
      let handle2 = tokio::spawn(echo(second));
      let (outcome1, outcome2) = tokio::join!(handle1, handle2);
      outcome1??;
      outcome2??;
      Ok(())
  }

  async fn echo(listener: TcpListener) -> Result<(), anyhow::Error> {
      loop {
          let (mut socket, _) = listener.accept().await?;
          tokio::spawn(async move {
              let (mut reader, mut writer) = socket.split();
              tokio::io::copy(&mut reader, &mut writer).await.unwrap();
          });
      }
  }
  ```

### Runtime

- `tokio` has both `Builder::new_multi_thread` and `Builder::new_current_thread`
  to build runtimes. `#[tokio::main]` is multithreaded by default and
  `#[tokio::test]` is single threaded. Single threaded runs one task at a time
  but interleaves tasks. Multithreaded has an OS thread for each CPU core. Also,
  `tokio` performs **work-stealing** to keep threads busy. `tokio::spawn` works
  with either, but it's signature has to be prepared for the "worst case";
  multithreaded.

  ```rs
  pub fn spawn<F>(future: F) -> JoinHandle<F::Output>
  where
      F: Future + Send + 'static,
      F::Output: Send + 'static,
  { /* */ }
  ```

- In the following, `T` isn't `Clone`, so we can't just clone `reply` for each
  task. We can't borrow `&reply` into `tokio::spawn` because it requires
  `F: Future + Send + 'static`, and a reference to `reply` is tied to
  `fixed_reply`'s stack frame so isn't `'static`, and we can't use `Rc<T>`
  because `tokio::spawn` requires `F: Send`. However, `Arc<T>` solves all three
  problems. It gives each spawned task an owned, `'static`, thread-safe handle
  to the same `reply` without requiring `T: Clone`.

  ```rs
  use std::fmt::Display;
  use std::sync::Arc;
  use tokio::io::AsyncWriteExt;
  use tokio::net::TcpListener;

  pub async fn fixed_reply<T>(first: TcpListener, second: TcpListener, reply: T)
  where
      // `T` cannot be cloned. How do you share it between the two server tasks?
      T: Display + Send + Sync + 'static,
  {
      let reply = Arc::new(reply);
      let handle1 = tokio::spawn(_fixed_reply(first, Arc::clone(&reply)));
      let handle2 = tokio::spawn(_fixed_reply(second, reply));

      tokio::join!(handle1, handle2,);
  }

  async fn _fixed_reply<T>(listener: TcpListener, reply: Arc<T>)
  where
      T: Display + Send + Sync + 'static,
  {
      loop {
          let (mut socket, _) = listener.accept().await.unwrap();
          let (_reader, mut writer) = socket.split();
          writer
              .write_all(format!("{}", reply).as_bytes())
              .await
              .unwrap();
      }
  }
  ```

### Futures

- You can think of a `Future` like a state-machine with two states: pending and
  ready.

  ```rs
  trait Future {
      type Output;

      // Ignore `Pin` and `Context` for now
      fn poll(
        self: Pin<&mut Self>,
        cx: &mut Context<'_>
      ) -> Poll<Self::Output>;
  }
  ```

  - When you call `poll`, you're asking the `Future` to do some work. `poll`
    tries to make some progress then returns `Poll::Pending` or
    `Poll::Ready(value)`. The `Future` has completed once it returns
    `Poll::Ready` and it should not be polled again. You don't call `poll`
    manually; that is the job of your asynchronous runtime.

  ```rs
  // a standard asynchronous function
  use std::rc::Rc;
  use tokio::task::yield_now;

  async fn example() {
      let non_send = Rc::new(1);
      yield_now().await;
      println!("{}", non_send);
  }

  // The compiler would transform it into an enum that looks somewhat like this:
  pub enum ExampleFuture {
      NotStarted,
      YieldNow(Rc<i32>),
      Terminated,
  }
  ```

- As you've just seen with example, every .await point creates a new
  intermediate state in the lifecycle of a future. Await points are also called
  **yield points**.
- Note that the `example` function above won't compile if called by
  `tokio::spawn`. It holds a value in an `Rc<i32>` which must be stored at the
  yield point, but `Rc` is not `Send` so cannot be safely sent across threads.
  Any value that is held across an await point by an asynchronous function must
  be `Send`, because the runtime may move the function to another thread and has
  to move that stored state with it.

### Blocking the runtime

- Unlike threads, Rust tasks may not be preempted. Control goes back to the
  executor only when a task yields. **Blocking the runtime** is when a task
  never yields, so the runtime is never able to run another task. As a rule of
  thumb, try to spend less than 100 microseconds between yield points. This is
  not always obvious and can lead to deadlocks and starvation. You should avoid
  synchronous IO and expensive computation in asynchronous code. With `tokio`,
  you can move a synchronous operation to the **blocking pool** threads reserved
  for this purpose using `tokio::task::spawn_blocking`. Using the pool is
  cheaper than spawning your own thread.

  ```rs
  use tokio::task;

  fn expensive_computation() -> u64 {
      // [...]
  }

  async fn run() {
      let handle = task::spawn_blocking(expensive_computation);
      // Do other stuff in the meantime
      let result = handle.await.unwrap();
  }
  ```

- The exercise continued our running example of an echo server.

  ```rs
  use std::io::{Read, Write};
  use tokio::net::TcpListener;
  use tokio::task::spawn_blocking;

  pub async fn echo(listener: TcpListener) -> Result<(), anyhow::Error> {
      loop {
          let (socket, _) = listener.accept().await?;
          let mut socket = socket.into_std()?;
          spawn_blocking(move || -> Result<(), anyhow::Error> {
              socket.set_nonblocking(false)?;
              let mut buffer = Vec::new();
              socket.read_to_end(&mut buffer)?;
              socket.write_all(&buffer)?;
              Ok(())
          });
      }
  }
  ```

### Async-aware primitives

- When working in an asynchronous context, prefer `tokio`'s async primitives
  that mirror types found in the standard library. Use `tokio::sync::Mutex`
  instead of `std::sync::Mutex` to prevent deadlocks. The `std` version isn't
  async aware and can hold a lock through a yield point. Another task would not
  yield back to the task if it needed to acquire the lock. `tokio`'s version
  yields while waiting for the lock so control would go back to the original
  thread which could finish and release the lock. Multithreaded doesn't solve
  this; it just makes it take more participants to deadlock. `Mutex` was an
  example, but this applies to `RwLock`, semaphores, channels, etc. Prefer
  async-aware versions when working in an asynchronous context. It is sometimes
  worth it for performance to use standard `Mutex` and `RwLock` if you aren't
  holding the lock across an `await`. `tokio` also has `tokio::net`,
  `tokio::fs`, and `tokio::process`, in addition to `tokio::time::sleep` for
  other async aware code.
- The exercise for this was simple. Just change `std` to `tokio` in a `use`
  statement and add in a few invocations of `await`.

### Cancellation

- Cancellation often happens in the wild when working with timeouts. When a
  timeout expires, the `Future` will be cancelled.

  ```rs
  use tokio::time::timeout;
  use tokio::sync::oneshot;
  use std::time::Duration;

  async fn http_call() {
      // [...]
  }

  async fn run() {
      // Wrap the future with a `Timeout` set to expire in 10 milliseconds.
      let duration = Duration::from_millis(10);
      if let Err(_) = timeout(duration, http_call()).await {
          println!("Didn't receive a value within 10 ms");
      }
  }
  ```

- To gracefully cancel an operation, you can implement the `Drop` trait to
  cleanup resources. You might spawn a new task, send a message on a channel, or
  spawn a background thread to complete cleanup. If cleanup is synchronous and
  fast you can handle it yourself in the `Drop` method. There is no asynchronous
  `Drop`.
- The `JoinHandle` returned by `tokio::spawn` has an `abort` method you can use
  to cancel a task.
- Further reading
  - Be extremely careful when using tokio's `select!` macro to "race" two
    different futures. Retrying the same task in a loop is dangerous unless you
    can ensure cancellation safety. Check out
    [select!'s documentation](https://tokio.rs/tokio/tutorial/select) for more
    details.
  - If you need to interleave two asynchronous streams of data (e.g. a socket
    and a channel), prefer using `StreamExt::merge` instead. A
    `CancellationToken` may be preferable to `JoinHandle::abort` in some cases.

### Outro

- A few recommendations:
  - Pick a runtime and stick to it. It's not worth it to try to write runtime
    agnostic code.
  - There is no stable `Stream`/`AsyncIterator` interface yet, but you can use
    `tokio_stream`.
  - Be careful with buffering. It leads to subtle bugs.
  - There is no equivalent to scoped threads for asynchronous tasks.
  - Despite the warning, asynchronous Rust is being used at massive scale.
