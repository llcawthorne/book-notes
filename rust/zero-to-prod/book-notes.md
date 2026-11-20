# Zero To Production In Rust

<https://www.zero2prod.com/index.html?country_code=US>

## Chapter 1 - Getting Started

- Chain testing with `cargo watch -x check -x test -x run`, or use `bacon`.
- You can check your code coverage with `cargo tarpaulin --ignore-tests`.

## Chapter 2 - Building An Email Newsletter

- We will be using `actix-web` to build our web API.
- There are other good books to learn the more popular choice `axum` later,
  including <https://leanpub.com/modernwebdevelopmentwithrustandaxum> and _Rust
  Web Programming_. Many ideas will carry over. `axum` is less macro driven and
  maintained by the `tokio` team.
- We want the the most basic endpoint, a `/health_check` URL that responds with
  `200 OK` to a `GET` request with no body. You could combine this with a SaaS
  service like <https://pingdom.com/> to be alerted when your API is down. It
  could also be useful with a container orchestrator (like Kubernetes or Nomad)
  trigger a restart if the container becomes unresponsive.
- We'll actually start from the _Hello World!_ example.

  ```rs
  use actix_web::{web, App, HttpRequest, HttpServer, Responder};

  async fn greet(req: HttpRequest) -> impl Responder {
      let name = req.match_info().get("name").unwrap_or("World");
      format!("Hello {}!", &name)
  }

  #[tokio::main]
  async fn main() -> Result<(), std::io::Error> {
      HttpServer::new(|| {
          App::new()
              .route("/", web::get().to(greet))
              .route("/{name}", web::get().to(greet))
      })
      .bind("127.0.0.1:8000")?
      .run()
      .await
  }
  ```

- This example won't compile without some dependencies. Either edit your
  _Cargo.toml_ or run `cargo add actix-web@4` and
  `cargo add tokio@1 --features macros,rt-multi-thread`.
- The `HttpServer` handles all _transport level concerns_. You use it to declare
  where you are listening for incoming request, the maximum number of concurrent
  connetions, whether or not to enable TLS, etc.
- `App` is where all your application logic lives: routing, middlewares, request
  handlers, etc. The `route` method is the simplest way to add a new endpoint to
  our app. `route` takes a `path`, possibly templated, and a `route`,
  specifically an instance of the `Route` struct. `Route` combines a _handler_
  with a set of _guards_. Guards specify conditions that a request must satisfy
  in order to "match" and be passed over to the handler. _Guards_ implement the
  `Guard` trait and `Guard::check` is where the magic happens. Some of this is
  obsucred in our example by the fact that `web::get()` is a shortcut for
  `Route::new().guard(guard::Get())`, aka the request should be passed to the
  handler if and only if its HTTP method is `GET`. A convenient enough mental
  model is the idea that `App` iterates over all registered endpoints until it
  find a matching one (both path template and guards are satisfied) and passes
  over the request object to the handler.
- A handler is simple an asynchronous function that takes an `HttpRequest` as
  input and returns _something_ that implements the `Responder` trait. A type
  implements the `Responder` trait if it can be converted into an
  `HttpResponse`, which includes strings, status codes, bytes, `HttpResponse`,
  and more. `actix-web` allows for a variety of signatures for handlers, and we
  will see other inputs than `HttpRequest`.
- You can see your code with macros expanded by running `cargo expand`.

  ```rs
  use actix_web::{App, HttpResponse, HttpServer, Responder, web};

  async fn health_check() -> impl Responder {
      HttpResponse::Ok()
  }

  #[tokio::main]
  async fn main() -> Result<(), std::io::Error> {
      HttpServer::new(|| {
          App::new()
              .route("/health_check", web::get().to(health_check))
          })
          .bind("127.0.0.1:8000")?
          .run()
          .await
  }
  ```

- Our actual health check implementation is a bit simpler than the "Hello World"
  we started from. One thing we did simplify, is that we removed the
  `HttpRequest` parameter entirely since we don't use any information from it.
- The endpoints we expose in our API define the _contract_ between us and our
  clients: a share agreement about the inputs and the outputs of the system, its
  _interface_. We perform _black box testing_, interacting with the API in the
  same way our user's would, to make sure we don't introduce unexpected breaking
  changes. While we could clearly define a unit test to test our handler input
  and output directly, we will not be satisfied without hitting the
  `/health_check` endpoint and making sure it returns `200 OK`.
- Here's everything we have so far with it's very own unit test.

  ```rs
  use actix_web::{App, HttpResponse, HttpServer, web};

  async fn health_check() -> HttpResponse {
      // We need to call `finish` now to build an `HttpResponse`
      HttpResponse::Ok().finish()
  }

  #[tokio::main]
  async fn main() -> Result<(), std::io::Error> {
      HttpServer::new(|| {
          App::new()
              .route("/health_check", web::get().to(health_check))
          })
          .bind("127.0.0.1:8000")?
          .run()
          .await
  }

  #[cfg(test)]
  mod test {
      use super::*;

      #[tokio::test]
      async fn health_check_succeeds() {
          let response = health_check().await;
          // This requires changing the return type of `health_check`
          // from `impl Responder` to `HttpResponse` to compile
          // You also need to import it with `use actix_web::HttpResponse`!
          assert!(response.status().is_success())
      }
  }
  ```

- This tests the function but doesn't check that `health_check` is invoked on
  `GET` requests to `/health_check` which is required by our API contract.
- `actix_web` has ways to interact with `App` without skipping the routing
  logic, but this would couple our tests to our implementation. Instead we will
  run integration tests by starting our app and using and off-the-shelf HTTP
  client (`reqwest`).
- We run into an immediate problem regarding integration tests that we cannot
  `use zero2prod::main` because it is a binary crate, so we will refactor into a
  slim main and a library crate. We rename our existing `main` to run and remove
  the `#[tokio::main]` macro then move it to `src/lib.rs` and write a simple
  `main`:

  ```rs
  //! main.rs
  use zero2prod::run;

  #[tokio::main]
  async fn main() -> Result<(), std::io::Error> {
      run().await
  }
  ```

- As you might recall, the specification for our health check endpoint was:
  "When we receive a `GET` request for `/health_check` we return a `200 OK`
  response with no body. Let's translate that into a test.

  ```rs
  //! tests/health_check.rs

  // `tokio::test` is the testing equivalent of `tokio::main`.
  // See what it expands to with `cargo expand --test health_check` (<- name of the test file)
  #[tokio::test]
  async fn health_check_works() {
      // Arrange
      spawn_app().await.expect("Failed to spawn our app.");
      let client = reqwest::Client::new();

      // Act
      let response = client
          .get("http://127.0.0.1:8000/health_check")
          .send()
          .await
          .expect("Failed to execute request.");

      // Assert
      assert!(response.status().is_success());
      assert_eq!(Some(0), response.content_length());
  }

  // Launch our application in the background somehow
  async fn spawn_app() -> Result<(), std::io::Error> {
      todo!()
  }
  ```

- The test is delightfully implementation agnostic. It could test a Rails app if
  you called a BASH script from `spawn_app`. However, if we currently called
  `zero2prod::run` from `spawn_app`, it would never exit because our `run`
  method listens for requests indefinitely. We are going to refactor our `run`
  method to be no longer `async` and to return a `Server` without awaiting it.

  ```rs
  //! src/lib.rs
  use actix_web::dev::Server;
  use actix_web::{App, HttpResponse, HttpServer, web};

  async fn health_check() -> HttpResponse {
      HttpResponse::Ok().finish()
  }

  pub fn run() -> Result<Server, std::io::Error> {
      let server = HttpServer::new(|| {
          App::new()
              .route("/health_check", web::get().to(health_check))
          })
          .bind("127.0.0.1:8000")?
          .run();
      Ok(server)
  }


  //! main.rs
  use zero2prod::run;

  #[tokio::main]
  async fn main() -> Result<(), std::io::Error> {
      run()?.await
  }

  //! tests/health_check.rs

  // `tokio::test` is the testing equivalent of `tokio::main`.
  // See what it expands to with `cargo expand --test health_check` (<- name of the test file)
  #[tokio::test]
  async fn health_check_works() {
      // Arrange
      spawn_app();
      let client = reqwest::Client::new();

      // Act
      let response = client
          .get("http://127.0.0.1:8000/health_check")
          .send()
          .await
          .expect("Failed to execute request.");

      // Assert
      assert!(response.status().is_success());
      assert_eq!(Some(0), response.content_length());
  }

  // Launch our application in the background
  // Also don't propagate errors in tests; just crash
  fn spawn_app() {
      let server = zero2prod::run().expect("Failed to bind address");
      // Launch the server as a background task
      let _ = tokio::spawn(server);
  }
  ```

- Note here that `spawn_app` is synchronous, as is `tokio::spawn`. If
  `spawn_app` was `async`, we could choose to `await` the `JoinHandle` returned
  by `tokio::spawn` to wait for the server to exit, but that would go back to
  hanging indefinitely. This spawns the server as a "background task" in the
  context of the test runner. When the `#[tokio::test]` function exits, the
  Tokio runtime is dropped, and all tasks running on it are dropped too.
  `spawn_app` would not work if called from a normal `#[test]`.
- We do have a small issue. If we tried to run multiple tests in parallel, they
  would clash over port 8000. This would also be a point of contention if we
  tried to run the test on a box where our server was running. We will Instead
  make our `run` take and `address` to run on and specify the port as `0` so the
  OS will provide an available port.

  ```rs
  //! src/lib.rs
  pub fn run(address: &str) -> Result<Server, std::io::Error> {
      let server = HttpServer::new(|| {
              App::new()
                  .route("/health_check", web::get().to(health_check))
          })
          .bind(address)?
          .run();
      Ok(server)
  }

  //! tests/health_check.rs
  fn spawn_app() {
      let server = zero2prod::run("127.0.0.1:0").expect("Failed to bind address");
      // Launch the server as a background task
      let _ = tokio::spawn(server);
  }
  ```

- But now our test fails, since we're calling port 8000 with our client. Instead
  we will bind the port with a `TcpListener` and the `listen` method, so we can
  bind a random port before calling `run` and pass it into our tests.

  ```rs
  //! src/lib.rs
  use actix_web::dev::Server;
  use actix_web::{App, HttpResponse, HttpServer, web};
  use std::net::TcpListener;
  // [...]
  pub fn run(listener: TcpListener) -> Result<Server, std::io::Error> {
      let server = HttpServer::new(|| {
          App::new()
              .route("/health_check", web::get().to(health_check))
          })
          .listen(listener)?
          .run();
      Ok(server)
  }

  //! tests/health_check.rs
  use std::net::TcpListener;
  // [...]
  #[tokio::test]
  async fn health_check_works() {
      // Arrange
      let address = spawn_app();
      let client = reqwest::Client::new();

      // Act
      let response = client
          .get(&format!("{}/health_check", &address))
          .send()
          .await
          .expect("Failed to execute request.");

      // Assert
      assert!(response.status().is_success());
      assert_eq!(Some(0), response.content_length());
  }

  fn spawn_app() -> String {
      let listener = TcpListener::bind("127.0.0.1:0")
          .expect("Failed to bind random port");
      let port = listener.local_addr().unwrap().port();
      let server = zero2prod::run(listener).expect("Failed to bind address");
      // Launch the server as a background task
      let _ = tokio::spawn(server);
      // Return the application address to the caller
      format!("http://127.0.0.1:{}", port)
  }

  //! main.rs
  use std::net::TcpListener;
  use zero2prod::run;

  #[tokio::main]
  async fn main() -> Result<(), std::io::Error> {
      let listener = TcpListener::bind("127.0.0.1:8000")
          .expect("Failed to bind to port 8000!");
      run(listener)?.await
  }
  ```

- That wasn't a terribly interesting feature, but it got us to learn the basics
  of our web framework. Now, let's move on to a meatier user story.

  > As a blog visitor, I want to subscribe to the newsletter, So that I can
  > receive email updates when new content is published on the blog.

- Here we will need a form to take an email address, and we will need to store
  it. We're going to put it in PostgreSQL rather than start out in memory.
- Our form will be fairly simple. We only need a name and an email address.
  There are several options for encoding, but we will use
  `application/x-www-form-urlencoded`. Quoting MDN web docs, with
  `application/x-www-urlencoded`:

  > the keys and values [in our form] are encoded in key-value tuples separated
  > by `&`, with a `=` between the key and the value. Non-alphanumeric
  > characters in both keys and values are percent encoded.

- For example, `Le Guin` with email address `ursula_le_guin@gmail.com` should be
  `name=le%20guin&email=ursula_le_guin%40gmail.com`.
- We will return a `200 OK` for any valid pair and a `400 BAD REQUEST` if either
  (or both) are missing. We will start by writing the integration tests. For now
  we will just add them to `health_check.rs` then reorder our `tests` folder
  later.

  ```rs
  //! tests/health_check.rs
  // [...] Previous content
  #[tokio::test]
  async fn subscribe_returns_a_200_for_valid_form_data() {
      // Arrange
      let app_address = spawn_app();
      let client = reqwest::Client::new();

      // Act
      let body = "name=le%20guin&email=ursula_le_guin%40gmail.com";
      let response = client
          .post(&format!("{}/subscriptions", &app_address))
          .header("Content-Type", "application/x-www-form-urlencoded")
          .body(body)
          .send()
          .await
          .expect("Failed to execute request.");

      // Assert
      assert_eq!(200, response.status().as_u16());
  }

  #[tokio::test]
  async fn subscribe_returns_a_400_when_data_is_missing() {
      // Arrange
      let app_address = spawn_app();
      let client = reqwest::Client::new();
      let test_cases = vec![
          ("name=le%20guin", "missing the email"),
          ("email=ursula_le_guin%40gmail.com", "missing the name"),
          ("", "missing both name and email"),
      ];

      for (invalid_body, error_message) in test_cases {
          // Act
          let response = client
              .post(&format!("{}/subscriptions", &app_address))
              .header("Content-Type", "application/x-www-form-urlencoded")
              .body(invalid_body)
              .send()
              .await
              .expect("Failed to execute request.");

          // Assert
          assert_eq!(
              400,
              response.status().as_u16(),
              // Additional customized error message on test failure
              "The API did not fail with 400 Bad Request when the payload was {}.",
              error_message
          );
      }
  }
  ```

- With parameterized tests it is important to have good error messages on
  failures. Note that the tests aren't isolated like Go table-driven tests, so
  the first failure stops the test with a failing message. If you use the macro
  driven `rstest` crate, each value becomes its own separate `#[test]`. Note
  that in a web project like this the cost of including `rsttest` is not
  particularly high since you're bringing in the large macro libraries already
  for `tokio`, `serde`, and possibly `sqlx`.
- Unsurprisingly, our tests start out failing since we haven't written the
  feature yet. The request returns `404 NOT FOUND` instead of `200 OK` or
  `400 BAD REQUEST`. We also only get the one failure message for our three
  value table-driven test, as pointed out would happen. To at least make the
  path respond differently is a one-line change.

  ```rs
  //! src/lib.rs
  async fn subscribe() -> HttpResponse {
      HttpResponse::Ok().finish()
  }

  pub fn run(listener: TcpListener) -> Result<Server, std::io::Error> {
      let server = HttpServer::new(|| {
          App::new()
              .route("/health_check", web::get().to(health_check))
              .route("/subscriptions", web::post().to(subscribe))
      })
      .listen(listener)?
      .run();
      Ok(server)
  }
  ```

- Extractors are used to tell the framework to extract certain pieces of
  information from an incoming request. There are extractors for `Path`, to get
  dynamic path segments from a request's path; `Query`, for query parameters;
  `Json`, to parse a JSON-encoded request body; and more. The `Form` extractor
  perfectly fits our use case. From `actix-web`'s documentation:

  > An extractor can be accessed as an argument to a handler function. Actix-web
  > supports up to 10 extractors per handler function. Argument position does
  > not matter.

- Example:

  ```rs
  use actix_web::web;

  #[derive(serde::Deserialize)]
  struct FormData {
      username: String,
  }

  /// Extract form data using serde.
  /// This handler gets called only if content type is *x-www-form-urlencoded*
  /// and content of the request could be deserialized to a `FormData` struct
  fn index(form: web::Form<FormData>) -> String {
      format!("Welcome {}!", form.username)
  }
  ```

- Now working from the example, we can make the minimal changes to our
  `subscribe` function, plus add the `serde` dependency to _Cargo.toml_.

  ```rs
  //! Cargo.toml
  serde = { version = "1", features = ["derive"] }

  #[derive(serde::Deserialize)]
  struct FormData {
      email: String,
      name: String,
  }

  async fn subscribe(_form: web::Form<FormData>) -> HttpResponse {
      HttpResponse::Ok().finish()
  }
  ```

- And surprisingly our tests are already green! This is actually due to invalid
  data elements not passing the transformation to `Form<FormData>`. Let's look
  at `Form` (which isn't very interesting) as well as a simplified version of
  `FromRequest` which all arguments in the signature of a route handler must
  implement. An extractor is a type that implements `FromRequest`.

  ```rs
  #[derive(PartialEq, Eq, PartialOrd, Ord)]
  pub struct Form<T>(pub T);

  /// Trait implemented by types that can be extracted from request.
  ///
  /// Types that implement this trait can be used with `Route` handlers.
  pub trait FromRequest: Sized {
      type Error: Into<actix_web::Error>;

      async fn from_request(
          req: &HttpRequest,
          payload: &mut Payload,
      ) -> Result<Self, Self::Error>;

      /// Omitting some ancillary methods that actix-web implements
      /// out of the box for you and supporting associated types
  }
  ```

- If one of the extractions fails, the corresponding error is returned to the
  caller and the handler is never invoked (`actix_web::Error` can be converted
  to a `HttpResponse`). So our handler doesn't have to deal with a raw incoming
  request and can work with strongly-typed information. Here is the
  implementation (simplified) of `FromRequest` for `Form`.

  ```rs
  impl<T> FromRequest for Form<T>
  where
      T: DeserializeOwned + 'static,
  {
      type Error = actix_web::Error;
      async fn from_request(
          req: &HttpRequest,
          payload: &mut Payload
      ) -> Result<Self, Self::Error> {
          // Omitted stuff around extractor configuration (e.g. payload size limits)

          match UrlEncoded::new(req, payload).await {
              Ok(item) => Ok(Form(item)),
              // The error handler can be customised.
              // The default one will return a 400, which is what we want.
              Err(e) => Err(error_handler(e))
          }
      }
  }
  ```

- `UrlEncoded` handles a lot of the heavy lifting, including parsing the
  payload, but also dealing with compressed and uncompressed payloads and the
  fact that the body arrives a chunk at a time as a stream of bytes. The key
  passage of interest to us is:

  ```rs
  serde_urlencoded::from_bytes::<T>(&body).map_err(|_| UrlencodedError::Parse)
  ```

- Serde knows how to deserialize our `T` because `T` implements
  `DeserializeOwned` trait from `serde`.
- `serde` defines a set of _interfaces_ or a _data model_ for serializing and
  deserializing Rust data structures efficiently and generically. It does not,
  by itself, support any particular format. If you need to (de)serialize from/to
  JSON, Avro, or MessagePack then you also need another crate like `serde_json`
  or `avro-rs`. If you want to support a new format, you need to implement the
  `Serializer` trait. Each method on `Serializer` corresponds to one of the 29
  types that form `serde`'s data model and your implementation specifies how
  each of those types maps to your data format. The `Serialize` trait is the
  other side. Your implementation of `Serialize::serialize` for a Rust type
  specifies how to decompose it according to `serde`'s data model using the
  methods available on the `Serializer` trait.
- We do not pay any runtime cost for using generics due to _monomorphization_;
  every time a generic function is called with a concrete set of types the Rust
  compiler will create a copy of the function body replacing the generic type
  parameters with the concrete types allowing it to optimize each instance of
  the function with respect to the concrete types involved. All the information
  required to (de)serialize a specific type is available at compile-time, so
  there is no runtime overhead. Other languages often use reflection to support
  (de)serialization, but Rust does not provide runtime reflection and everything
  needs to be specified upfront.
- Spelling out manually how (de)serialization will be defined for your project
  is tedious. That's why we used `#[derive(serde::Deserialize)]` on our
  `FormData` struct.
- So basically in our code, `actix-web` invokes `from_request` on our `Form`
  since it is one of `subscribe`'s input arguments. `Form::from_request` tries
  to deserialize the body into `FormData` according to the rules of URL-encoding
  leveraging `serde_urlencoded` and the `Deserialize` implementation of
  `FormData` generated by our `derive` macro. If `Form::from_request` fails, a
  `400 BAD REQUEST` is returned to the caller. If it succeeds, `subscribe` is
  invoked and we return a `200 OK`. So that is why our tests now pass.
- While we can now pass basic tests that the endpoint works and recognizes valid
  data, the data still isn't being stored anywhere. We can't store this data on
  our host-filesystem, because we are a Cloud-native app that must be
  distributed and fault-tolerant. So we need the backing of a database. Fault
  tolerance within the database layer is handled by the database system itself.
- Luca's rule of thumb:

  > If you are uncertain about your persistence requirements, use a relational
  > database. If you have no reason to expect **massive** scale, use PostgreSQL.

- After deciding to use PostgreSQL, you are faced with a choice of which Rust
  library to use to interact with it. `tokio-postgres`, `sqlx`, and `dielsel`
  are three massively popular options. Choosing one comes down to how you feel
  about compile-time safety, SQL-first vs a DSL for query building, and async vs
  sync interface.
- In most programming languages, you realize a mistake made in a database
  interaction at runtime. This is what happens with `tokio-postgres`. `diesel`
  and `sqlx` try to speed up the feedback cycle by detecting most mistakes at
  compile-time. `diesel` uses a CLI to generate a representation of the database
  schema as Rust code, and `sqlx` uses procedural macros that connect to the
  database during development to check if the provided query is sound. This does
  require you to have the database up and running during development, unless you
  use its support for "offline" builds based on cached query metadata.
- `tokio-postgres` and `sqlx` both expect you to use SQL directly to write your
  queries. `diesel` provides its own query builder where queries are represented
  by Rust types and you add filter, perform joins and similar operations by
  calling methods on them. SQL is a more broadly applicable skill, but `diesel`
  does let you split complex queires into small units and leverage them in
  multiple places.
- Async IO support won't make a single query any faster, but it will enable your
  application to do other meaningful work while waiting on the database.
  Generally speaking however, it is enough to run queries on a separate
  threadpool for most usecases. But if your webframework is already
  asynchronous, using asynchronous IO often leads to less headaches.
  `tokio-postgres` and `sqlx` are both asynchronous, while `diesel` is
  synchronous.
- For this book, we will use `sqlx`. Its asynchronous support simplifies
  integration with `actix-web` without forcing us to compromise on compile-time
  guarantees. It also limits the API surface we have to cover and become
  proficient with thanks to its usage of raw SQL for queries.
- Considering our current tests, asserting that response code is `200 OK` is not
  enough. We want to verify a _side-effect_ has taken place and data was
  persisted to the database. We can verify this two ways:
  1. leverage another endpoint of our public API to inspect the application
     state;
  2. query directly the database in our test case.
- Option 1 should be your "go to", so your tests don't need to know your
  implementation details of the API. We could wire up `GET /subscriptions` to
  return a subscriber list, but then we would have to worry about securing it so
  our subscriber list isn't exposed on the public internet without any form of
  authentication. We will probably do that eventually, but we shouldn't write a
  new feature just to test the one we are working on. For now, we will write a
  small query in our test and remove it when better options are available.
- Also note the author does not believe in the "in-memory test database" school
  of thought, and thinks you should strive whenever possible to use the same
  database both for your tests and your production environment. He's been burnt
  one time too many by differences between the in-memory stub and the real
  database engine to believe it provides any kind of benefit over "the real
  thing."
- We write a basic script to start the database using docker:

  ```bash
  #!/usr/bin/env bash
  set -x
  set -eo pipefail

  # Check if a custom user has been set, otherwise default to 'postgres'
  DB_USER="${POSTGRES_USER:=postgres}"
  # Check if a custom password has been set, otherwise defualt to 'password'
  DB_PASSWORD="${POSTGRES_PASSWORD:=password}"
  # Check if a custom database name hs been set, otherwise default to 'newsletter'
  DB_NAME="${POSTGRES_DB:=newsletter}"
  # Check if a custom port has been set, otherwise default to '5432'
  DB_PORT="${POSTGRES_PORT:=5432}"
  # Check if a custom host has been set, otherwise default to 'localhost'
  DB_HOST="${POSTGRES_HOST:=localhost}"
  # Launch postgres using Docker
  docker run \
    -e POSTGRES_USER=${DB_USER} \
    -e POSTGRES_PASSWORD=${DB_PASSWORD} \
    -e POSTGRES_DB=${DB_NAME} \
    -p "${DB_PORT}":5432 \
    -d postgres \
    postgres -N 1000
  # ^ Increased maximum number of connections for testing purposes
  ```

- Then we fire it up by calling the script and begin our first _database
  migration_ to prepare our first table. You can install the `sqlx-cli` to
  manage migrations with:

  ```sh
  cargo install --version="~0.7" sqlx-cli --no-default-features \
      --features rustls,postgres
  ```

- We fleshed out our `init_db.sh` to check for pre-requisites and create the
  database. Then we made our first migration:

  ```sh
  $ export DATABASE_URL=postgres://postgres:password@127.0.0.1:5432/newsletter
  $ sqlx migrate add create_subscriptions_table
  Creating migrations/20261116101207_create_subscriptions_table.sql
  ```

- Migrations are in the `migrations/` folder, but I show the first one here just
  to underscore that they are plain SQL (and we are using uuid as key).

  ```sql
  -- migrations/{timestamp}_create_subscriptions_table.sql
  -- Create Subscriptions table
  CREATE TABLE subscriptions(
    id uuid NOT NULL,
    PRIMARY KEY (id),
    email TEXT NOT NULL UNIQUE,
    name TEXT NOT NULL,
    subscribed_at timestamptz NOT NULL
  );
  ```

- Then we run our migration with `sqlx migrate run` or now that we've made the
  `init_db.sh` aware of `docker`, you can just run it and it applies migrations
  while starting the database if necessary. We also need to add `sqlx` to our
  project dependencies in _Cargo.toml_.

  ```toml
  [dependencies.sqlx]
  version = "0.7"
  default-features = false
  features = [
    "runtime-tokio-rustls",
    "macros",
    "postgres",
    "uuid",
    "chrono",
    "migrate",
  ]
  ```

- A `PgConnection` is a type of `Connection` which is a trait providing the
  `connect` method. `connect` takes a connection string as input and
  asynchronously returns a `Result<PostgresConnection, sqlx::Error>`. This means
  we need a connection string, so we will start using the `config` crate to
  manage our configuration. We are also going to refactor our `lib.rs` into
  submodules. Here is the layout we want:

  ```shell
  src/
    configuration.rs
    lib.rs
    main.rs
    routes/
      mod.rs
      health_check.rs
      subscriptions.rs
    startup.rs
  ```

- To manage configuration with `config` we must represent our application
  settings as a Rust type that implements `serde`'s `Deserialize` trait'

- To manage configuration with `config` we must represent our application
  settings as a Rust type that implements `serde`'s `Deserialize` trait.

  ```rs
  //! src/configuration.rs
  #[derive(serde::Deserialize)]
  pub struct Settings {
      pub database: DatabaseSettings,
      pub application_port: u16,
  }

  #[derive(serde::Deserialize)]
  pub struct DatabaseSettings {
      pub username: String,
      pub password: String,
      pub port: u16,
      pub host: String,
      pub database_name: String,
  }

  pub fn get_configuration() -> Result<Settings, config::ConfigError> {
      // Initialize our configuration reader
      let settings = config::Config::builder()
          // Add configuration values from a file name `configuration.yaml`.
          .add_source(config::File::new(
              "configuration.yaml",
              config::FileFormat::Yaml,
          ))
          .build()?;
      // Try to convert the configuration values it read into our Setting type
      settings.try_deserialize::<Settings>()
  }

  impl DatabaseSettings {
      pub fn connection_string(&self) -> String {
          format!(
              "postgres://{}:{}@{}:{}/{}",
              self.username, self.password, self.host, self.port, self.database_name
          )
      }
  }
  ```

- It is very easy to use our configuration.

  ```rs
  //! main.rs
  use std::net::TcpListener;
  use zero2prod::configuration::get_configuration;
  use zero2prod::startup::run;

  #[tokio::main]
  async fn main() -> Result<(), std::io::Error> {
      let configuration = get_configuration().expect("Failed to read configuration.");
      let address = format!("127.0.0.1:{}", configuration.application_port);
      let listener = TcpListener::bind(address)?;
      run(listener)?.await
  }
  ```

- But after that change our `main` will crash until we write a
  `configuration.yaml`.

  ```yaml
  # configuration.yaml
  application_port: 8000
  database:
    host: "127.0.0.1"
    port: 5432
    username: "postgres"
    password: "password"
    database_name: "newsletter"
  ```

- And now let's connect to the database from `tests/health_check.rs`.

  ```rs
  //! tests/health_check.rs
  use sqlx::{PgConnection, Connection};
  use zero2prod::configuration::get_configuration;
  // [...]

  #[tokio::test]
  async fn subscribe_returns_a_200_for_valid_form_data() {
      // Arrange
      let app_address = spawn_app();
      let configuration = get_configuration().expect("Failed to read configuration");
      let connection_string = configuration.database.connection_string();
      // The `Connection` trait must be in scope for us to invoke
      // `PgConnection::connect` - it is not an inherent method of the struct!
      let connection = PgConnection::connect(&connection_string)
          .await
          .expect("Failed to connect to Postgres.");
      let client = reqwest::Client::new();

      // Act
      let body = "name=le%20guin&email=ursula_le_guin%40gmail.com";
      let response = client
          .post(format!("{}/subscriptions", app_address))
          .header("Content-Type", "application/x-www-form-urlencoded")
          .body(body)
          .send()
          .await
          .expect("Failed to execute request.");

      // Assert
      assert_eq!(200, response.status().as_u16());
  }
  ```

- And our test still passes. We are using our configuration and connecting to
  the database, even if we aren't verifying anything is there yet.

  ```rs
  //! tests/health_check.rs
  // [...]
  #[tokio::test]
  async fn subscribe_returns_a_200_for_valid_form_data() {
    // [...]
    // The connection has to be marked as mutable!
    let mut connection = ...
    // [...]

    // Assert
    assert_eq!(200, response.status().as_u16());

    let saved = sqlx::query!("SELECT email, name FROM subscriptions",)
        .fetch_one(&mut connection)
        .await
        .expect("Failed to fetch saved subscription.");

    assert_eq!(saved.email, "ursula_le_guin@gmail.com");
    assert_eq!(saved.name, "le guin");
  ```

- The `query!` macro returns an anonymous record type: a struct definition is
  generated at compile-time after having verified that the query is valid, with
  a member for each column on the result (ie. `saved.email` for the `email`
  column). Unfortunately, our test won't run now since we need to set the
  `DATABASE_URL`. If we set it manually, we would need to set it everytime we
  begin working on the project after a reboot. Instead we can put the following
  in an `.env` file in the project root.

  ```sh
  DATABASE_URL="postgres://postgres:password@localhost:5432/newsletter"
  ```

- And now our test fails for the reason it should fail! We aren't storing
  anything in the database.
- In `actix-web`, you can attach state to the appliication using the `app_data`
  method on `App`. But if we tried to pass a `PgConnection` this way, the
  compiler would teach us `PgConnection` doesn't implement `Clone`. Each `App`
  passed to `HttpServer` would need its own `PgConnection`, and `actix-web`
  needs a copy of `App` for each core in your machine. But if we pass it to
  `web::Data`, it is wrapped in an `Arc` so each instance of the application
  gets a pointer to the connection. `Arc<T>` is always cloneable. We're also
  going to initialize a `PgPool` instead of a `PgConnection` for concurrent
  queries.
- There was an interesting aside where we tried to do with with a
  `PgConnection`, but as we saw in our test, you need a `mut PgConnection` and
  not just a `PgConnection` to execute a query. An `Arc<T>` only returns a
  read-only reference. What about interior mutability. Well, because we need a
  `mut` reference, it would have to be a `Mutex` instead of a `RwLock`, so even
  our read queries would face lock contention. `PgPool` solves this for us by
  keeping a pool of mutable connections handle to run different queries on
  without us manually having to worry about locking the mutable resource.

  ```rs
  //! src/startup.rs
  use crate::routes::{health_check, subscribe};
  use actix_web::dev::Server;
  use actix_web::{App, HttpServer, web};
  use sqlx::PgPool;
  use std::net::TcpListener;

  pub fn run(
      listener: TcpListener,
      connection_pool: PgPool
  ) -> Result<Server, std::io::Error> {
      // Wrap the connection in a smart pointer
      let db_pool = web::Data::new(connection_pool);
      // Capture `connection` from the surrounding environment
      let server = HttpServer::new(move || {
          App::new()
              .route("/health_check", web::get().to(health_check))
              .route("/subscriptions", web::post().to(subscribe))
              .app_data(db_pool.clone())
      })
      .listen(listener)?
      .run();
      Ok(server)
  }

  //! src/main.rs
  use sqlx::PgPool;
  use std::net::TcpListener;
  use zero2prod::configuration::get_configuration;
  use zero2prod::startup::run;

  #[tokio::main]
  async fn main() -> Result<(), std::io::Error> {
      let configuration = get_configuration().expect("Failed to read configuration.");
      let connection_pool = PgPool::connect(
              &configuration.database.connection_string()
          )
          .await
          .expect("Failed to connect to Postgres.");
      let address = format!("127.0.0.1:{}", configuration.application_port);
      let listener = TcpListener::bind(address)?;
      run(listener, connection_pool)?.await
  }
  ```

- `web::Data` is an extractor, so we can get our `PgConnection` by declaring an
  argument in our request handler. This is a form of dependency injection. Also,
  add `uuid` and `chrono` to _Cargo.toml_.

  ```rs
  //! src/routes/subscriptions.rs
  use actix_web::HttpResponse;
  use actix_web::web;
  use chrono::Utc;
  use sqlx::PgPool;
  use uuid::Uuid;

  #[derive(serde::Deserialize)]
  // Fields are deserialized for validation; persistence is added in a later chapter.
  pub struct FormData {
      email: String,
      name: String,
  }

  pub async fn subscribe(
      form: web::Form<FormData>,
      pool: web::Data<PgPool>)
  -> HttpResponse {
      match sqlx::query!(
          r#"
          INSERT INTO subscriptions (id, email, name, subscribed_at)
          VALUES ($1, $2, $3, $4)
          "#,
          Uuid::new_v4(),
          form.email,
          form.name,
          Utc::now(),
      )
      .execute(pool.get_ref())
      .await;
      {
          Ok(_) => HttpResponse::Ok().finish(),
          Err(e) => {
              println!("Failed to execute query: {}", e);
              HttpResponse::InternalServerError().finish()
          }
      }
  }
  ```

- And this gets `cargo test` passing, but we still have `cargo test` problems.
  We're refactoring `spawn_app` to return a struct `TestApp` that holds both the
  address of our test application instance and a handle to the connection pool,
  simplifying the arrange step in our test cases. It's worth noting that
  `spawn_app` is now asynchronous. We still aren't calling `await` on the
  server, but we need to `await` setup of the `PgPool`.

  ```rs
  //! tests/health_check.rs
  async fn spawn_app() -> TestApp {
      let listener = TcpListener::bind("127.0.0.1:0")
          .expect("Failed to bind random port");
      let port = listener.local_addr().unwrap().port();
      let address = format!("http://127.0.0.1:{}", port);
      let configuration = get_configuration()
          .expect("Failed to read configuration.");
      let connection_pool = PgPool::connect(
              &configuration.database.connection_string()
          )
          .await
          .expect("Failed to connect to Postgres.");

      let server = run(listener, connection_pool.clone())
          .expect("Failed to bind address");
      // Launch the server as a background task
      drop(tokio::spawn(server));
      TestApp {
          address,
          db_pool: connection_pool,
      }
  }

  // And here is one of the updated tests
  #[tokio::test]
  async fn subscribe_returns_a_200_for_valid_form_data() {
      // Arrange
      let app = spawn_app().await;
      let client = reqwest::Client::new();

      // Act
      let body = "name=le%20guin&email=ursula_le_guin%40gmail.com";
      let response = client
          .post(format!("{}/subscriptions", app_address))
          .header("Content-Type", "application/x-www-form-urlencoded")
          .body(body)
          .send()
          .await
          .expect("Failed to execute request.");

      // Assert
      assert_eq!(200, response.status().as_u16());

      let saved = sqlx::query!("SELECT email, name FROM subscriptions",)
          .fetch_one(&app.db_pool)
          .await
          .expect("Failed to fetch saved subscription.");

      assert_eq!(saved.email, "ursula_le_guin@gmail.com");
      assert_eq!(saved.name, "le guin");
  }
  ```

- When we go through an update all of our tests to spawn the app and use the
  `&app.address` to connect, our test suite is green again. Even our new test
  that checks the database is green! Hopefully we use this respite to refactor
  our tests out of a single file.
- First, we have a larger problem to deal with. Our test suite is green, but
  only once. When we run it again, we get
  `duplicate key value violates unique constraint "subscriptions_email_key"`.
  Our tests aren't isolated. There are two techniques available:
  - wrap the whole test in a SQL transaction and rollback at the end of it;
  - spin up a brand-new logical database for each integration test.
- The first option is faster but hard to use outside unit tests. The second
  option is very easy to implement. We can create a new database and run
  migrations for each test when we call `spawn_app`.

  ```rs
  // First we need a way to connect to our Postgres instance without a logical
  // database specified so we can initialize a new one.
  //! src/configuration.rs
  impl DatabaseSettings {
      pub fn connection_string(&self) -> String {
          format!(
              "postgres://{}:{}@{}:{}/{}",
              self.username, self.password, self.host, self.port, self.database_name
          )
      }

      pub fn connection_string_without_db(&self) -> String {
          format!(
              "postgres://{}:{}@{}:{}",
              self.username, self.password, self.host, self.t
          )
      }
  }

  //! tests/health_check.rs
  use sqlx::{Connection, Executor, PgConnection, PgPool};
  use zero2prod::configuration::{DatabaseSettings, get_configuration};

  // Launch our application in the background
  // Also don't propagate errors in tests; just crash
  async fn spawn_app() -> TestApp {
      let listener = TcpListener::bind("127.0.0.1:0")
          .expect("Failed to bind random port");
      let port = listener.local_addr().unwrap().port();
      let address = format!("http://127.0.0.1:{}", port);
      let mut configuration = get_configuration()
          .expect("Failed to read configuration.");
      configuration.database.database_name = Uuid::new_v4().to_string();

      let connection_pool = configure_database(&configuration.database).await;

      let server = run(listener, connection_pool.clone())
          .expect("Failed to bind address");
      // Launch the server as a background task
      drop(tokio::spawn(server));
      TestApp {
          address,
          db_pool: connection_pool,
      }
  }

  pub async fn configure_database(config: &DatabaseSettings) -> PgPool {
      let mut connection = PgConnection::connect(&config.connection_string_without_db())
          .await
          .expect("Failed to connect to Postgres.");
      connection
          .execute(format!(r#"CREATE DATABASE "{}";"#, config.database_name).as_str())
          .await
          .expect("Failed to create datbase.");

      let connection_pool = PgPool::connect(&config.connection_string())
          .await
          .expect("Failed to connect to Postgres.");
      sqlx::migrate!("./migrations")
          .run(&connection_pool)
          .await
          .expect("Failed to migrate the database.");

      connection_pool
  }
  ```

- We don't clean up our test databases, since we're using an ephemeral Docker
  image solely for testing. If we create hundreds of these and performance
  starts to suffer, we will just restart the instance clean.

## Chapter 4 - Telemetry

- We have a working feature. Put it in Prod! But wait. We are vulnerable to
  **unknown unknowns** because we are not collecting any **telemetry data**. The
  only thing we can rely on to understand and debug an unknown unknown is
  **telemetry data**: information about our running applications that is
  collected automatically and can be later inspected to answer questions about
  the state of the system at a certain point in time. Since we don't know in
  advance what data we need to debug an unknown unknown, the goal is to have an
  **observable application**. Quoting Honeycomb's observability guide:

  > Observability is about being able to ask arbitrary questions about your
  > environment withouth - and this is the key part - having to know ahead of
  > time what you wanted to ask.

- "arbitrary" is a strong word, but we will settle for an application that is
  _sufficiently_ observable to enable us to deleiver the level of service we
  promised to our users. To build an observable system we need:
  - to instrument our application to collect high-quality telemetry data;
  - access to tools and systems to efficiently slice, dice and manipulate the
    data to find answers to our questions.

- Logs are the most common type of telemetry data. The go-to crate for logging
  in Rust is `log`. `log` provides five macros: `trace`, `debug`, `info`,
  `warn`, and `error`; to log at different logging levels. The macros use the
  same interpolation syntax we've grown used to from `println!`. We can use
  `log`'s macros to _instrument_ our codebase. Choosing what to log is often a
  local decision that can be made by looking at the function and deciding what
  deserves to be captured in a log record. This allows libraries to be
  instrumented effectively, extending the reach of our telemetry outside the
  boundaries of the code we have written first-hand.
- `actix_web` provides a `Logger` middleware that emits a log record for every
  incoming request.

  ```rs
  //! src/startup.rs
  use crate::routes::{health_check, subscribe};
  use actix_web::dev::Server;
  use actix_web::middleware::Logger;
  use actix_web::{App, HttpServer, web};
  use sqlx::PgPool;
  use std::net::TcpListener;

  pub fn run(listener: TcpListener, connection_pool: PgPool) -> Result<Server, std::io::Error> {
      // Wrap the connection in a smart pointer
      let db_pool = web::Data::new(connection_pool);
      // Capture `connection` from the surrounding environment
      let server = HttpServer::new(move || {
          App::new()
              // Middlweares are added using the `wrap` method on `App`
              .wrap(Logger::default())
              .route("/health_check", web::get().to(health_check))
              .route("/subscriptions", web::post().to(subscribe))
              .app_data(db_pool.clone())
      })
      .listen(listener)?
      .run();
      Ok(server)
  }
  ```

- While instrumentation is a local decision, we now face a global decision for
  the application of what to do with the logs. If we hit our endpoint now, we
  won't see any log output. The `log` crate leverages the facade pattern. It
  does not prescribe precisely how the log record should be processed and
  instead proivdes a `Log` trait which defines `enabled`, `log`, and `flush`
  methods. At the beginning of your `main` function you can call `set_logger`
  and pass an implementation of the `Log` trait, and its `log` method will be
  called every time a log record is emitted. If you do not call `set_logger`,
  log messages are discarded, which is why we don't see any log output. There
  are multiple logger implementations available on crates.io. We will use
  `env_logger` which outputs logs to the terminal. We merely have to add
  `env_logger = "0.9"` to our _Cargo.toml_ then add an import and line to
  _main.rs_:

  ```rs
  //! main.rs
  use env_logger:Env;
  // [...]

  #[tokio::main]
  async fn main() -> Result<(), std::io::Error> {
      // `init` calls `set_logger`, so this is all we need to do.
      // We are falling back to printing all logs at info-level or above
      // if the RUST_LOG environment variable has not been set.
      env_logger::Builder::from_env(Env::default().default_filter_or("info")).init();
      // [...]
  }
  ```

- `env_logger` looks for the `RUST_LOG` environment variable to determine what
  logs should be printed. `RUST_LOG=debug cargo run` would run our application
  with debug or higher logs printed to stdout from both our crate and its
  dependencies. `RUST_LOG=zero2prod` would filter out all records emitted by our
  dependencies and only show log messages from our crate.
- The `RUST_LOG` environment variable handles complicated logging requirements
  painlessly. We could specify
  `RUST_LOG="info,zero2prod=debug,sqlx::query=trace"` to log everything (our
  crate and dependencies) at info by default, our actual crate at debug, and if
  tracing a thorny sql problem, just the `sqlx::query` calls at the trace level.
- And now we have basic logging.

  ```text
  [2026-11-18T11:51:34Z INFO  actix_server::builder] starting 10 workers
  [2026-11-18T11:51:34Z INFO  actix_server::server] Tokio runtime found; starting in existing Tokio runtime
  [2026-11-18T11:51:34Z INFO  actix_server::server] starting service: "actix-web-service-127.0.0.1:8000", workers: 10, listening on: 127.0.0.1:8000
  [2026-11-18T11:51:42Z INFO  actix_web::middleware::logger] 127.0.0.1 "GET /Lewis HTTP/1.1" 404 0 "-" "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/157.0.0.0 Safari/537.36" 0.000191
  [2026-11-18T11:51:45Z INFO  actix_web::middleware::logger] 127.0.0.1 "GET /Lewis HTTP/1.1" 404 0 "-" "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/157.0.0.0 Safari/537.36" 0.000102
  [2026-11-18T11:51:51Z INFO  actix_web::middleware::logger] 127.0.0.1 "GET /health_check HTTP/1.1" 200 0 "-" "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/157.0.0.0 Safari/537.36" 0.000117
  [2026-11-18T11:51:51Z INFO  actix_web::middleware::logger] 127.0.0.1 "GET /favicon.ico HTTP/1.1" 404 0 "http://localhost:8000/health_check" "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/157.0.0.0 Safari/537.36" 0.000064
  ```

- To actually emit our own logs now, we need to add the `log` crate as a
  dependency in _Cargo.toml_. Then we can update `subscribe` to log on success
  and error. Notice below we're putting the debug view ('{:?}') of the error in
  the log. Display format is for end users, but debug gives the operator more
  details.

  ```rs
  pub async fn subscribe(form: web::Form<FormData>, pool: web::Data<PgPool>) ->   HttpResponse {
    log::info!("Saving new subscriber details in the database");
    match sqlx::query!(
        r#"
        INSERT INTO subscriptions (id, email, name, subscribed_at)
        VALUES ($1, $2, $3, $4)
        "#,
        Uuid::new_v4(),
        form.email,
        form.name,
        Utc::now(),
    )
    .execute(pool.get_ref())
    .await
    {
        Ok(_) => {
            log::info!("New subscriber details have been saved");
            HttpResponse::Ok().finish()
        }
        Err(e) => {
            log::error!("Failed to execute query: {:?}", e);
            HttpResponse::InternalServerError().finish()
        }
    }
  ```

- It's a questionable practice putting subscriber's email addresses in logs, but
  we could do that before the insert to help debug errors.

  ```rs
  log::info!(
      "Adding '{}' '{}' as a new subscriber.",
      form.email,
      form.name
  );
  ```

- If we had a single copy of our server handling a single request, this would
  work beautifully. But with multiple servers processing requests
  asynchronously, we need a way to correlate all logs related to the same
  request. This is normally done with a **request id** or **corelation id**,
  some random identifier like a UUID that is associated to all logs concerning a
  specific request.

  ```rs
  pub async fn subscribe(form: web::Form<FormData>, pool: web::Data<PgPool>) -> HttpResponse {
      let request_id = Uuid::new_v4();
      log::info!(
          "request_id {} - Adding '{}' '{}' as a new subscriber.",
          request_id,
          form.email,
          form.name
      );
      log::info!(
          "request_id {} - Saving new subscriber details in the database",
          request_id
      );
      match sqlx::query!(
          r#"
          INSERT INTO subscriptions (id, email, name, subscribed_at)
          VALUES ($1, $2, $3, $4)
          "#,
          Uuid::new_v4(),
          form.email,
          form.name,
          Utc::now(),
      )
      .execute(pool.get_ref())
      .await
      {
          Ok(_) => {
              log::info!(
                  "request_id {} - New subscriber details have been saved",
                  request_id
              );
              HttpResponse::Ok().finish()
          }
          Err(e) => {
              log::error!(
                  "request_id {} - Failed to execute query: {:?}",
                  request_id,
                  e
              );
              HttpResponse::InternalServerError().finish()
          }
      }
  }
  ```

- The problem with our homegrown approach to `request_id` is that it lets us
  correlate all logs for the subscribe handler, but not for the whole app. We
  don't see, for example, the status code of the request. We also miss related
  logs from our dependencies. The `tracing` crate comes to the rescue:

  > `tracing` expands upong logging-style diagnostics by allowing libraries and
  > applications to record structured events with additional information about
  > temporality and causality - unlike a log message, a span in `tracing` has a
  > beginning and end time may be entered and exited by the flow of execution,
  > and may exist within a nest tree of similar spans.

- First thing to do is replace our `log` dependency with `tracing`:

  ```toml
  #! Cargo.toml

  [dependencies]
  tracing = { version = "0.1", features = ["log"] }
  ```

- Now if we replace all our `log` calls with `tracing`, we'll get the same logs
  picked up by `env_logger`. But we can do better by using more features of
  `tracing`. `tracing` allows us to associate key-value pairs with our span to
  establish context. You prefix context values with `%` to use their `Display`
  implementation. Spans, like logs, have a level. You shouldn't `enter` a span
  within an async function. `enter` returns a guard that is dropped at the end
  of its block and the span is exited, with trace level logging on enter and
  exit. This pattern is known as Resource Acquisition Is Initialization (RAII).
  You can enter and exit a span multiple times, but the span is closed when it
  is dropped. `Intrument::instrument` is what we want for asynchronous
  functions. It enters a span every time the future is polled and exits the span
  whenever the future is parked.

  ```rs
  //! src/routes/subscriptions.rs
  use actix_web::HttpResponse;
  use actix_web::web;
  use chrono::Utc;
  use sqlx::PgPool;
  use tracing::Instrument;
  use uuid::Uuid;

  #[derive(serde::Deserialize)]
  // Fields are deserialized for validation; persistence is added in a later chapter.
  pub struct FormData {
      email: String,
      name: String,
  }

  pub async fn subscribe(form: web::Form<FormData>, pool: web::Data<PgPool>) -> HttpResponse {
      let request_id = Uuid::new_v4();
      let request_span = tracing::info_span!(
          "Adding a new subscriber.",
          %request_id,
          subscriber_email = %form.email,
          subscriber_name = %form.name
      );
      let _request_span_guard = request_span.enter();

      let query_span = tracing::info_span!(
          "Saving new subscriber details in the database"
      );
      match sqlx::query!(
          r#"
          INSERT INTO subscriptions (id, email, name, subscribed_at)
          VALUES ($1, $2, $3, $4)
          "#,
          Uuid::new_v4(),
          form.email,
          form.name,
          Utc::now(),
      )
      .execute(pool.get_ref())
      .instrument(query_span)
      .await
      {
          Ok(_) => HttpResponse::Ok().finish(),
          Err(e) => {
              // This error log falls outside the `query_span`
              tracing::error!("request_id {} - Failed to execute query: {:?}", e);
              HttpResponse::InternalServerError().finish()
          }
      }
  }
  ```

- `env_logger` was good to make swapping easy, but using a `tracing`-native
  solution gives us more info. But for an implementation of `tracing`'s
  `Subscriber` trait, we need another crate: `tracing-subscriber`. We'll also
  add `tracing-log` so we can see logs of our dependencies.

  ```toml
  [dependencies]
  tracing-bunyan-formatter = "0.3"
  tracing-log = "0.1"
  tracing-subscriber = { version = "0.3", features = ["registry", "env-filter"] }
  ```

- Along with a few handy subscribers, `tracing-subscriber` introduces the
  `Layer` trait which makes it possible to build a _processing pipeline_ for
  spans data: instead of an all-encompassing subscriber we can combine multiple
  smaller layers to obtain the processing pipeline we need. The cornerstone of
  layering is `Registry`, which implements `Subscriber` and takes care of the
  hard stuff. We want to start with at least as much functionality as
  `env_logger`, so we need to combine three layers.
- `tracing_subscriber::filter::EnvFilter` discards spans based on log levels;
- `tracing_bunyan_formatter::JsonStorageLayer` processes spans data and stores
  the associated metadata in JSON for downstream layers. It propagates context
  from parent spans to their children;
- `tracing_bunyan_formatter::BunyanFormatterLayer` builds on top of
  `JsonStorageLayer` and outputs log records in `bunyan`-compatible JSON format.

```rs
//! main.rs
use sqlx::PgPool;
use std::net::TcpListener;
use tracing::subscriber::set_global_default;
use tracing_bunyan_formatter::{BunyanFormattingLayer, JsonStorageLayer};
use tracing_log::LogTracer;
use tracing_subscriber::{EnvFilter, Registry, layer::SubscriberExt};
use zero2prod::configuration::get_configuration;
use zero2prod::startup::run;

#[tokio::main]
async fn main() -> Result<(), std::io::Error> {
    LogTracer::init().expect("Failed to set logger");

    // Like our previous logger, we default to info if nothing is set.
    let env_filter = EnvFilter::try_from_default_env()
        .unwrap_or_else(|_| EnvFilter::new("info"));
    let formatting_layer = BunyanFormattingLayer::new(
        "zero2prod".into(),
        // Output the formatted spans to stdout.
        std::io::stdout,
    );
    // The `with` method is provided by `SubscriberExt`, and extension
    // trait for `Subscriber` exposed by `tracing_subscriber`
    let subscriber = Registry::default()
        .with(env_filter)
        .with(JsonStorageLayer)
        .with(formatting_layer);
    // `set_global_default` can be used by applications to specify
    // what subscriber should be used to process spans
    set_global_default(subscriber).expect("Failed to set subscriber");

    let configuration = get_configuration()
        .expect("Failed to read configuration.");
    let connection = PgPool::connect(&configuration.database.connection_string())
      .await
      .expect("Failed to connect to Postgres.");
    let address = format!("127.0.0.1:{}", configuration.application_port);
    let listener = TcpListener::bind(address)?;
    run(listener, connection)?.await
}
```

- If we run our code now, we see output like (pretty printed here):

  ```json
  {
    "msg": "[ADDING A NEW SUBSCRIBER - START]",
    "subscriber_name": "le guin",
    "request_id": "30f8cce1-f587-4104-92f2-5448e1cc21f6",
    "subscriber_email": "ursula_le_guin@gmail.com"
    ...
  }
  {
    "msg": "[SAVING NEW SUBSCRIBER DETAILS IN THE DATABASE - START]",
    "subscriber_name": "le guin",
    "request_id": "30f8cce1-f587-4104-92f2-5448e1cc21f6",
    "subscriber_email": "ursula_le_guin@gmail.com"
    ...
  }
  {
    "msg": "[SAVING NEW SUBSCRIBER DETAILS IN THE DATABASE - END]",
    "elapsed_milliseconds": 4,
    "subscriber_name": "le guin",
    "request_id": "30f8cce1-f587-4104-92f2-5448e1cc21f6",
    "subscriber_email": "ursula_le_guin@gmail.com"
    ...
  }
  {
    "msg": "[ADDING A NEW SUBSCRIBER - END]",
    "elapsed_milliseconds": 5
    "subscriber_name": "le guin",
    "request_id": "30f8cce1-f587-4104-92f2-5448e1cc21f6",
    "subscriber_email": "ursula_le_guin@gmail.com",
    ...
  }
  ```

- After running `cargo install cargo-udeps`, you can run `cargo +nightly udeps`
  to list unused dependencies.
- Our `main` function is doing a little too much now, so we're going to
  refactor.

  ```rs
  //! src/lib.rs
  pub mod configuration;
  pub mod routes;
  pub mod telemetry;
  pub mod startup;


  //! src/telemetry.rs
  use tracing::subscriber::set_global_default;
  use tracing::Subscriber;
  use tracing_bunyan_formatter::{BunyanFormattingLayer, JsonStorageLayer};
  use tracing_log::LogTracer;
  use tracing_subscriber::{EnvFilter, Registry, layer::SubscriberExt};

  /// Compose multiple layers into a `tracing`'s subscriber.
  ///
  /// # Implementation Notes
  ///
  /// We are using `impl Subscriber` as return type to avoid having to
  /// spell out the actual type of the returned subscriber, which is
  /// indeed quite complex.
  /// We need to explicitly call out that the returned subscriber is
  /// `Send` and `Sync` to make it possible to pass it to `init_subscriber`
  /// later on.
  pub fn get_subscriber(
      name: String,
      env_filter: String
  ) -> impl Subscriber + Send + Sync {
      let env_filter =
          EnvFilter::try_from_default_env()
              .unwrap_or_else(|_| EnvFilter::new(env_filter));
      let formatting_layer = BunyanFormattingLayer::new(name, std::io::stdout);
      Registry::default()
          .with(env_filter)
          .with(JsonStorageLayer)
          .with(formatting_layer)
  }

  /// Register a subscriber as global default to process span data.
  ///
  /// It should only be called once!
  pub fn init_subscriber(subscriber: impl Subscriber + Send + Sync) {
      LogTracer::init().expect("Failed to set logger");
      set_global_default(subscriber).expect("Failed to set subscriber");
  }

  //! main.rs
  use sqlx::PgPool;
  use std::net::TcpListener;
  use zero2prod::configuration::get_configuration;
  use zero2prod::startup::run;
  use zero2prod::telemetry::{get_subscriber, init_subscriber};

  #[tokio::main]
  async fn main() -> Result<(), std::io::Error> {
      let subscriber = get_subscriber("zero2prod".into(), "info".into());
      init_subscriber(subscriber);

      let configuration = get_configuration()
          .expect("Failed to read configuration.");
      let connection = PgPool::connect(&configuration.database.connection_string())
        .await
        .expect("Failed to connect to Postgres.");
      let address = format!("127.0.0.1:{}", configuration.application_port);
      let listener = TcpListener::bind(address)?;
      run(listener, connection)?.await
  }
  ```

- We have logging in our app now but not our tests. Let's wire it up there as
  well. We'll make it toggle-able though, so we don't get all that output on a
  normal passing test run. But first we have a dependency to add. `once-cell`.
  If we wire up our `subscriber` in `spawn_app`, it gets set every time we run a
  test. But we need it to be initialized only once. Because all of our tests run
  in the same OS process on different threads, the process is calling
  `set_global_default` multiple times. We also need to modify our `telemetry`
  library so we can set where output goes to make it toggle-able. It's worth
  pointing out that tests have already solved this problem for `println!` and
  `eprintln!`. Their output is captured and you explicitly opt in to see it by
  running `cargo test -- --nocapture`.

  ```toml
  #! Cargo.toml
  [dependencies]
  once_cell = "1"
  ```

  ```rs
  //! src/telemetry.rs
  use tracing::subscriber::set_global_default;
  use tracing::Subscriber;
  use tracing_bunyan_formatter::{BunyanFormattingLayer, JsonStorageLayer};
  use tracing_log::LogTracer;
  use tracing_subscriber::{EnvFilter, Registry, layer::SubscriberExt};
  use tracing_subscriber::fmt::MakeWriter;

  /// Compose multiple layers into a `tracing`'s subscriber.
  ///
  /// # Implementation Notes
  ///
  /// We are using `impl Subscriber` as return type to avoid having to
  /// spell out the actual type of the returned subscriber, which is
  /// indeed quite complex.
  /// We need to explicitly call out that the returned subscriber is
  /// `Send` and `Sync` to make it possible to pass it to `init_subscriber`
  /// later on.
  pub fn get_subscriber<Sink>(
      name: String,
      env_filter: String,
      sink: Sink,
  ) -> impl Subscriber + Send + Sync
      where
          // This "weird" syntax is a higher-ranked trait bound (HRTB)
          // It basically means that `Sink` impleemnts the `MakeWriter`
          // trait for all choices of the lifetime parameter `'a`
          // Check out <https://doc.rust-lang.org/nomicon/hrtb.html>
          // for more details.
          Sink: for<'a> MakeWriter<'a> + Send + Sync + 'static,
  {
      let env_filter =
          EnvFilter::try_from_default_env()
              .unwrap_or_else(|_| EnvFilter::new(env_filter));
      let formatting_layer = BunyanFormattingLayer::new(name, sink);
      Registry::default()
          .with(env_filter)
          .with(JsonStorageLayer)
          .with(formatting_layer)
  }

  /// Register a subscriber as global default to process span data.
  ///
  /// It should only be called once!
  pub fn init_subscriber(subscriber: impl Subscriber + Send + Sync) {
      LogTracer::init().expect("Failed to set logger");
      set_global_default(subscriber).expect("Failed to set subscriber");
  }
  ```

  ```rs
  //! src/main.rs
  #[tokio::main]
  async fn main() -> Result<(), std::io::Error> {
      let subscriber = get_subscriber(
          "zero2prod".into(), "info".into(), std::io::stdout
      );
      init_subscriber(subscriber);
      // [...]
  }
  ```

  ```rs
  //! tests/health_check.rs
  use once_cell::sync::Lazy;
  use sqlx::{Connection, Executor, PgConnection, PgPool};
  use std::net::TcpListener;
  use uuid::Uuid;
  use zero2prod::configuration::{DatabaseSettings, get_configuration};
  use zero2prod::startup::run;
  use zero2prod::telemetry::{get_subscriber, init_subscriber};

  // Ensure that the `tracing` stack is only initialized once using `once_cell`
  static TRACING: Lazy<()> = Lazy::new(|| {
      let default_filter_level = "info".to_string();
      let subscriber_name = "test".to_string();
      // We cannot assign the output of `get_subscriber` to a variable based on
      // the value `TEST_LOG` because the sink is part of the type returned by
      // `get_subscriber`, therefor they are not the same type. We could work
      // around it, but this is the most straight-forward way of moving forward.
      if std::env::var("TEST_LOG").is_ok() {
          let subscriber = get_subscriber(
              subscriber_name,
              default_filter_level,
              std::io::stdout
          );
          init_subscriber(subscriber);
      } else {
          let subscriber = get_subscriber(
              subscriber_name,
              default_filter_level,
              std::io::sink
          );
          init_subscriber(subscriber);
      };
  });

  pub struct TestApp {
      pub address: String,
      pub db_pool: PgPool,
  }

  // Launch our application in the background
  // Also don't propagate errors in tests; just crash
  async fn spawn_app() -> TestApp {
      Lazy::force(&TRACING);

      let listener = TcpListener::bind("127.0.0.1:0")
          .expect("Failed to bind random port");
      let port = listener.local_addr().unwrap().port();
      let address = format!("http://127.0.0.1:{}", port);

      let mut configuration = get_configuration()
          .expect("Failed to read configuration.");
      configuration.database.database_name = Uuid::new_v4().to_string();
      let connection_pool = configure_database(&configuration.database).await;

      let server = run(listener, connection_pool.clone())
          .expect("Failed to bind address");
      // Launch the server as a background task
      drop(tokio::spawn(server));
      TestApp {
          address,
          db_pool: connection_pool,
      }
  }
  ```

- Now when we run `cargo test`, there is no `tracing` output. But we have the
  option to run `TEST_LOG=true cargo test test_name | bunyan` for any of our
  tests when debugging. The best of both worlds!
- Looking back now that tests are green, logging has definitely added some noise
  to our `subscribe` function. We still want to declare a span for the entire
  operation. But we can make this cleaner using `tracing::instrument` procedural
  macro to wrap the `subscribe` function in a span instead of calling `enter`
  manually. We are also finally going to make good on not using `enter` in an
  asynchronous function. The way we have been doing it so far looks good when
  you're making one request at a time, but suffers a chance of attaching the
  `request_id` for thread A to thread B requests in Production.

  ```rs
  //! src/routes/subscriptions.rs
  use actix_web::HttpResponse;
  use actix_web::web;
  use chrono::Utc;
  use sqlx::PgPool;
  use uuid::Uuid;

  #[derive(serde::Deserialize)]
  // Fields are deserialized for validation; persistence is added in a later chapter.
  pub struct FormData {
      email: String,
      name: String,
  }

  #[tracing::instrument(
      name = "Adding a new subscriber",
      skip(form, pool),
      fields(
          request_id = %Uuid::new_v4(),
          subscriber_email = %form.email,
          subscriber_name = %form.name,
      )
  )]
  pub async fn subscribe(
      form: web::Form<FormData>,
      pool: web::Data<PgPool>
  ) -> HttpResponse {
      match insert_subscriber(&pool, &form).await {
          Ok(_) => HttpResponse::Ok().finish(),
          Err(_) => HttpResponse::InternalServerError().finish(),
      }
  }

  #[tracing::instrument(
      name = "Saving new subscriber details in the database",
      skip(form, pool)
  )]
  pub async fn insert_subscriber(
      pool: &PgPool,
      form: &FormData
  ) -> Result<(), sqlx::Error> {
      sqlx::query!(
          r#"
          INSERT INTO subscriptions (id, email, name, subscribed_at)
          VALUES ($1, $2, $3, $4)
          "#,
          Uuid::new_v4(),
          form.email,
          form.name,
          Utc::now(),
      )
      .execute(pool)
      .await
      .map_err(|e| {
          tracing::error!("Failed to execute query: {:?}", e);
          e
      })?;
      Ok(())
  }
  ```

- `#[tracing::instrument]` creates a span at the beginning of the function
  invocation and automatically attaches all arguments passed to the unction to
  the context of the span. We use `skip` to ignore those arguments so we can use
  individual form fields and ignore `pool` which is not printable. If you omit
  `name`, it defaults to the function name. We have also moved our `INSERT`
  statement out to its own `instrument` decorated function.
- One drawback of `#[tracing::instrument]` is that it automatically attaches all
  function arguments to the context of the span - you have to opt-out of logging
  function inputs (via `skip`) rather than opt-in. This is clearly undesirable
  for secrets. But we have the `secrecy` crate which let's us wrap our sensitive
  information in an un-`Display`-able wrapper. Access to a secret's inner value
  occurs through the `expose_secret` method. Debug printing of a secret instead
  displays `[REDACTED String]`. The only secret we need to worry about now is
  the database password.

  ```toml
  #! Cargo.toml
  [dependencies]
  secrecy = { version = "0.8", features = ["serde"] }
  ```

  ```rs
  //! src/configuration.rs
  use secrecy::ExposeSecret;
  use secrecy::Secret;
  // [...]

  #[derive(serde::Deserialize)]
  pub struct DatabaseSettings {
      pub username: String,
      pub password: Secret<String>,
      pub port: u16,
      pub host: String,
      pub database_name: String,
  }

  impl DatabaseSettings {
      pub fn connection_string(&self) -> Secret<String> {
          Secret::new(format!(
              "postgres://{}:{}@{}:{}/{}",
              self.username,
              self.password.expose_secret(),
              self.host,
              self.port,
              self.database_name,
          ))
      }

      pub fn connection_string_without_db(&self) -> Secret<String> {
          Secret::new(format!(
              "postgres://{}:{}@{}:{}",
              self.username,
              self.password.expose_secret(),
              self.host,
              self.port,
          ))
      }
  }

  //! src/main.rs
  use secrecy::ExposeSecret;
  // [...]

  #[tokio::main]
  async fn main() -> Result<(), std::io::Error> {
      // [...]
      let connection_pool = PgPool::connect(
          &configuration.database.connection_string().expose_secret()
          )
          .await
          .expect("Failed to connect to Postgres.");
      // [...]
  }

  //! tests/health_check.rs
  use secrecy::ExposeSecret;
  // [...]

  pub async fn configure_database(config: &DatabaseSettings) -> PgPool {
      let mut connection = PgConnection::connect(
          &config.connection_string_without_db().expose_secret()
          )
          .await
          .expect("Failed to connect to Postgres.");
      connection
          .execute(
              format!(r#"CREATE DATABASE "{}";"#, config.database_name).as_str()
          )
          .await
          .expect("Failed to create datbase.");

      let connection_pool = PgPool::connect(
              &config.connection_string().expose_secret()
          )
          .await
          .expect("Failed to connect to Postgres.");
      sqlx::migrate!("./migrations")
          .run(&connection_pool)
          .await
          .expect("Failed to migrate the database.");

      connection_pool
  }
  ```

- We also want to make sure all logs for a particular request have the
  `request_id` property. Particulary, the result code at the end falls outside
  of our span. The easiest way to wrap everything is more middleware, so we
  could use `RequestIdMiddleware`. Unfortunately, it doesn't output JSON. So
  instead we use `tracing-actix-web`.

  ```toml
  #! Cargo.toml
  [dependencies]
  tracing-actix-web = "0.7"
  ```

  ```rs
  //! src/startup.rs
  use crate::routes::{health_check, subscribe};
  use actix_web::dev::Server;
  use actix_web::web::Data;
  use actix_web::middleware::Logger;
  use actix_web::{App, HttpServer, web};
  use sqlx::PgPool;
  use std::net::TcpListener;
  use tracing_actix_web::TracingLogger;

  pub fn run(
      listener: TcpListener,
      connection_pool: PgPool)
  -> Result<Server, std::io::Error> {
      // Wrap the connection in a smart pointer
      let db_pool = Data::new(connection_pool);
      // Capture `connection` from the surrounding environment
      let server = HttpServer::new(move || {
          App::new()
              // Middlweares are added using the `wrap` method on `App`
              .wrap(TracingLogger::default())
              .route("/health_check", web::get().to(health_check))
              .route("/subscriptions", web::post().to(subscribe))
              .app_data(db_pool.clone())
      })
      .listen(listener)?
      .run();
      Ok(server)
  }

  // Then we have to remove our manually added `request_id`.
  //! src/routes/subscriptions.rs
  #[tracing::instrument(
      name = "Adding a new subscriber",
      skip(form, pool),
      fields(
          subscriber_email = %form.email,
          subscriber_name = %form.name,
      )
  )]
  pub async fn subscribe(
      form: web::Form<FormData>,
      pool: web::Data<PgPool>)
  -> HttpResponse {
      match insert_subscriber(&pool, &form).await {
          Ok(_) => HttpResponse::Ok().finish(),
          Err(_) => HttpResponse::InternalServerError().finish(),
      }
  }
  ```

- We have barely scratched the surface of what's available with `tracing`.
  - `tracing-actix-web` is OpenTelemetry-compatible. If you plug-in
    `tracing-opentelemetry` you can ship spans to an OpenTelemetry-compatible
    service (e.g. Jaegar or Honeycomb.io) for further analysis.
  - `tracing-error` enriches our error types with a `SpanTrace` for easy
    troubleshooting.

## Chapter 5 - Going Live
