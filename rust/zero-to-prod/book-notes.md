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
