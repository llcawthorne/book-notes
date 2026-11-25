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

  > As a blog visitor,  
  > I want to subscribe to the newsletter,  
  > So that I can receive email updates when new content is published on the
  > blog.

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
  library to use to interact with it. `tokio-postgres`, `sqlx`, and `diesel` are
  three massively popular options. Choosing one comes down to how you feel about
  compile-time safety, SQL-first vs a DSL for query building, and async vs sync
  interface.
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
  does let you split complex queries into small units and leverage them in
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
              self.username, self.password, self.host, self.port
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
  > environment without - and this is the key part - having to know ahead of
  > time what you wanted to ask.

- "arbitrary" is a strong word, but we will settle for an application that is
  _sufficiently_ observable to enable us to deliver the level of service we
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
  use env_logger::Env;
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

  > `tracing` expands upon logging-style diagnostics by allowing libraries and
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
  is dropped. `Instrument::instrument` is what we want for asynchronous
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
              tracing::error!("request_id {} - Failed to execute query: {:?}", request_id, e);
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
- `tracing_bunyan_formatter::BunyanFormattingLayer` builds on top of
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
          // It basically means that `Sink` implements the `MakeWriter`
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
  invocation and automatically attaches all arguments passed to the function to
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

- The first step in deploying to production is writing a Dockerfile to build and
  execute our application as a Docker container. We'll start with the simplest
  possible Dockerfile for a Rust project.

  ```dockerfile
  # We use the latest Rust stable release as base image
  FROM rust:1.72.0

  # Let's switch our working directory to `app` (equivalent to 'cd app')
  # The `app` folder will be created for us by Docker in case it does not
  # exist already.
  WORKDIR /app
  # Install the rquired system dependencies for our linking configuration
  RUN apt update && apt install lld clang -y
  # Copy all files from our working environment to our Docker image
  COPY . .
  # Let's build our binary!
  # We'll use the release profile to make it fast
  RUN cargo build --release
  # When `docker run` is executed, launch the binary!
  ENTRYPOINT ["./target/release/zero2prod"]
  ```

- Pro tip. Add `target/` to `.dockerignore` as well.
- Then we can build an image: `docker build --tag zero2prod --file Dockerfile .`
- If we try to build now, we get an error when `sqlx` cannot contact its
  database. To fix this, we will use **offline mode** by running
  `cargo sqlx prepare --workspace`. Then we add an `ENV` command to our
  Dockerfile.

  ```dockerfile
  FROM rust:1.72.0
  WORKDIR /app
  RUN apt update && apt install lld clang -y
  COPY . .
  ENV SQLX_OFFLINE=true
  RUN cargo build --release
  ENTRYPOINT ["./target/release/zero2prod"]
  ```

- If we try to run it with `docker run zero2prod`, we can't connect to our
  database. We'll go ahead and change our `connect` to `connect_lazy` in our
  `main.rs`. We also remove the `await` since we aren't waiting for it.

  ```rs
  //! src/main.rs
  // [...]

  #[tokio::main]
  async fn main() -> Result<(), std::io::Error> {
      // [...]
      // No longer async, given that we don't actually try to connect.
      let connection_pool =
          PgPool::connect_lazy(
                  configuration.database.connection_string().expose_secret()
              )
              .expect("Failed to connect to Postgres.");
      // [...]
  }
  ```

- Now it runs, but we can't hit our server. We actually need to map the port by
  running `docker run -p 8000:8000 zero2prod`. But we still cannot connect
  because our application only listens on 127.0.0.1. That's fine for local
  development, but we need it to bind to 0.0.0.0 for docker images. We need to
  expand our application settings.

  ```rs
  //! src/configuration.rs
  use secrecy::ExposeSecret;
  use secrecy::Secret;

  #[derive(serde::Deserialize)]
  pub struct Settings {
      pub database: DatabaseSettings,
      pub application: ApplicationSettings,
  }

  #[derive(serde::Deserialize)]
  pub struct ApplicationSettings {
      pub port: u16,
      pub host: String,
  }
  ```

  ```yaml
  # configuration.yaml
  application:
    port: 8000
    host: 127.0.0.1
  database:
    # [...]
  ```

  ```rs
  //! src/main.rs
  // [...]

  #[tokio::main]
  async fn main() -> Result<(), std::io::Error> {
      // [...]
      let address = format!(
          "{}:{}",
          configuration.application.host, configuration.application.port
      );
      // [...]
  }
  ```

- Now we need to make our configuration _hierarchical_ so we can use different
  values for development and production. We will have a base configuration file
  for values that are the same and a collection of environment-specific
  configuration files, and an environment variable, `APP_ENVIRONMENT`, to
  determine the running environment. We will put all our files in the same
  top-level directory: `configuration`.

  ```rs
  //! src/configuration.rs
  pub fn get_configuration() -> Result<Settings, config::ConfigError> {
      let base_path = std::env::current_dir()
          .expect("Failed to determine the current directory");
      let configuration_directory = base_path.join("configuration");

      let environment: Environment = std::env::var("APP_ENVIRONMENT")
          .unwrap_or_else(|_| "local".into())
          .try_into()
          .expect("Failed to parse APP_ENVIRONMENT");
      let environment_filename = format!("{}.yaml", environment.as_str());
      let settings = config::Config::builder()
          .add_source(config::File::from(
              configuration_directory.join("base.yaml"),
          ))
          .add_source(config::File::from(
              configuration_directory.join(environment_filename),
          ))
          .build()?;

      settings.try_deserialize::<Settings>()
  }

  pub enum Environment {
      Local,
      Production,
  }

  impl Environment {
      pub fn as_str(&self) -> &'static str {
          match self {
              Environment::Local => "local",
              Environment::Production => "production",
          }
      }
  }

  impl TryFrom<String> for Environment {
      type Error = String;

      fn try_from(s: String) -> Result<Self, Self::Error> {
          match s.to_lowercase().as_str() {
              "local" => Ok(Self::Local),
              "production" => Ok(Self::Production),
              other => Err(format!(
                  "{} is not a supported environment. \
                      Use either `local` or `production`.",
                  other
              )),
          }
      }
  }
  ```

  ```yaml
  #! configuration/base.yaml
  application:
    port: 8000
  database:
    host: "127.0.0.1"
    port: 5432
    username: "postgres"
    password: "password"
    database_name: "newsletter"

  #! configuration/local.yaml
  application:
    host: 127.0.0.1

  #! configuration/production.yaml
  application:
    host: 0.0.0.0
  ```

  ```dockerfile
  # [...]
  ENV APP_ENVIRONMENT=production
  ENTRYPOINT ["./target/release/zero2prod"]
  ```

- So now we can do a `GET` to `health_check`, but we get a `500` from a `POST`
  to `subscriptions`. We will deal with this later.
- Right now, we want to optimize our Docker image in two ways:
  1. smaller image size for faster usage;
  2. Docker layer caching for faster builds.
- Right now our base Rust image is about 2 GB, but our app is 4.8 GB. We can see
  this with `docker images zero2prod` and `docker images rust:1.99.0`. We are
  going to start by putting more in `.dockerignore`.

  ```text
  .env
  target/
  tests/
  Dockerfile
  scripts/
  migrations/
  ```

- We also don't need our source or intermediate files since we're running a
  statically linked binary. We can do this with a multistage build.

  ```dockerfile
  FROM rust:1.99.0 AS builder

  WORKDIR /app
  RUN apt update && apt install lld clang -y
  COPY . .
  ENV SQLX_OFFLINE=true
  RUN cargo build --release

  FROM rust:1.99.0-slim AS runtime

  WORKDIR /app
  COPY --from=builder /app/target/release/zero2prod zero2prod
  COPY configuration configuration
  ENV APP_ENVIRONMENT=production
  ENTRYPOINT ["./zero2prod"]
  ```

- Now our image is 1.15 GB. We can make it even smaller by removing the rust
  compiler since that is unnecessary to run our app.

  ```dockerfile
  FROM rust:1.99.0 AS builder

  WORKDIR /app
  RUN apt update && apt install lld clang -y
  COPY . .
  ENV SQLX_OFFLINE=true
  RUN cargo build --release

  FROM debian:bookworm-slim AS runtime

  WORKDIR /app
  # Install OpenSSL - it is dynamically linked by some of our dependencies
  # Install ca-certificates - it is needed to verify TLS certificates
  # when establishing HTTPS connections
  RUN apt-get update -y \
    && apt-get install -y --no-install-recommends openssl ca-certificates \
    && apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*
  COPY --from=builder /app/target/release/zero2prod zero2prod
  COPY configuration configuration
  ENV APP_ENVIRONMENT=production
  ENTRYPOINT ["./zero2prod"]
  ```

- Now when we build, our image is only 167 MB. We could go even smaller with the
  `rust:1.99.0-alpine` image but we would have to cross-compile to `linux-musl`
  target. Check out `rust-musl-builder` if you are interested in generating tiny
  Docker images. You could also add these lines to your _Cargo.toml_ to make
  release builds slightly smaller:

  ```toml
  [profile.release]
  strip = true  # Automatically strip symbols from the binary.
  ```

- You can speed-up docker builds through layer caching. Each `RUN`, `COPY`, and
  `ADD` instruction creates a layer, and if a layer is unchanged between builds,
  Docker can start from that step. Since dependencies change less often than
  your application code, you can build your dependencies separate and have that
  step cached. To do this with `cargo`, we need `cargo-chef`.

  ```dockerfile
  FROM lukemathwalker/cargo-chef:latest-rust-1.99.0 AS chef

  WORKDIR /app
  RUN apt update && apt install lld clang -y

  FROM chef AS planner
  COPY . .
  RUN cargo chef prepare --recipe-path recipe.json

  FROM chef AS builder
  COPY --from=planner /app/recipe.json recipe.json
  # Build our project dependencies, not our application!
  RUN cargo chef cook --release --recipe-path recipe.json

  # Everything before this should be cached if dependencies didn't change
  COPY . .
  ENV SQLX_OFFLINE=true
  RUN cargo build --release --bin zero2prod

  FROM debian:bookworm-slim AS runtime

  WORKDIR /app
  # Install OpenSSL - it is dynamically linked by some of our dependencies
  # Install ca-certificates - it is needed to verify TLS certificates
  # when establishing HTTPS connections
  RUN apt-get update -y \
    && apt-get install -y --no-install-recommends openssl ca-certificates \
    && apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*
  COPY --from=builder /app/target/release/zero2prod zero2prod
  COPY configuration configuration
  ENV APP_ENVIRONMENT=production
  ENTRYPOINT ["./zero2prod"]
  ```

- You may not notice since we `COPY . .` to the `planner` stage, but files in
  this directory changing don't prevent the `builder` stage from being cached
  since it only copies `recipe.json` before `cargo chef cook`. So source files
  changing don't invalidate the dependency cache—only a dependency change that
  alters `recipe.json`.
- We also wrote a `spec.yaml` file for deployment to DigitalOcean, and modified
  our `configuration.rs` to load values from environment variables as well.

  ```rs
  //! src/configuration.rs
  // [...]

  pub fn get_configuration() -> Result<Settings, config::ConfigError> {
      // [...]
          // Add in settings from environment variables (with a prefix of APP and
          // '__' as separator)
          // E.g. `APP_APPLICATION__PORT=5001` would set `Settings.application.port`
          .add_source(
              config::Environment::with_prefix("APP")
                  .prefix_separator("_")
                  .separator("__"),
          )
          .build()?;

      settings.try_deserialize::<Settings>()
  }
  ```

- We also need the ability to deserialize a number from a String to accept a
  port from an environment variable, and this is provided by `serde-aux`.

  ```toml
  #! Cargo.toml
  # [...]
  [dependencies]
  serde-aux = "4"
  ```

  ```rs
  //! src/configuration.rs
  // [...]
  use serde_aux::field_attributes::deserialize_number_from_string;
  // [...]

  #[derive(serde::Deserialize)]
  pub struct ApplicationSettings {
      #[serde(deserialize_with = "deserialize_number_from_string")]
      pub port: u16,
      pub host: String,
  }

  #[derive(serde::Deserialize)]
  pub struct DatabaseSettings {
      pub username: String,
      pub password: Secret<String>,
      #[serde(deserialize_with = "deserialize_number_from_string")]
      pub port: u16,
      pub host: String,
      pub database_name: String,
  }
  ```

- With the move to Digital Ocean, our database connection string becomes more
  complicated as well. For one, it requires SSL mode. So we are going to
  refactor our `DatabaseSettings` to return a `PgConnectOptions`.

  ```rs
  //! src/configuration.rs
  use sqlx::postgres::PgConnectOptions;
  // [...]

  impl DatabaseSettings {
      pub fn without_db(&self) -> PgConnectOptions {
          PgConnectOptions::new()
              .host(&self.host)
              .username(&self.username)
              .password(&self.password.expose_secret())
              .port(self.port)
      }

      pub fn with_db(&self) -> PgConnectOptions {
          self.without_db().database(&self.database_name)
      }
  }

  //! src/main.rs
  // [...]

      // `connect_lazy_with` instead of `connect_lazy` and no more `expect`
      let connection_pool =
          PgPool::connect_lazy_with(configuration.database.with_db());
  // [...]

  //! tests/health_check.rs
  pub async fn configure_database(config: &DatabaseSettings) -> PgPool {
      let mut connection = PgConnection::connect_with(&config.without_db())
          .await
          .expect("Failed to connect to Postgres.");
      connection
          .execute(format!(
              r#"CREATE DATABASE "{}";"#, config.database_name).as_str())
          .await
          .expect("Failed to create datbase.");

      let connection_pool = PgPool::connect_with(config.with_db())
          .await
          .expect("Failed to connect to Postgres.");
      sqlx::migrate!("./migrations")
          .run(&connection_pool)
          .await
          .expect("Failed to migrate the database.");

      connection_pool
  }
  ```

- Then we can easily add support for SSL mode.

  ```rs
  //! src/configuration.rs
  use sqlx::postgres::{PgConnectOptions, PgSslMode};

  #[derive(serde::Deserialize)]
  pub struct DatabaseSettings {
      // [...]
      pub require_ssl: bool,
  }

  impl DatabaseSettings {
      pub fn without_db(&self) -> PgConnectOptions {
          let ssl_mode = if self.require_ssl {
              PgSslMode::Require
          } else {
              // Try an encrypted connection, fallback to an unencrypted if it fails
              PgSslMode::Prefer
          };

          PgConnectOptions::new()
              .host(&self.host)
              .username(&self.username)
              .password(&self.password.expose_secret())
              .port(self.port)
              .ssl_mode(ssl_mode)
      }
      // [...]
  }
  ```

  ```yaml
  #! configuration/local.yaml
  application:
    host: 127.0.0.1
  database:
    require_ssl: false

  #! configuration/production.yaml
  application:
    host: 0.0.0.0
  database:
    require_ssl: true
  ```

- We're also going to take this opportunity to lower the chatter from `sqlx` by
  changing the logging level of its messages from `INFO` to `TRACE`. That way
  the queries are available by running with `RUST_LOG="info,sqlx::query=trace"`,
  but every query isn't logged at `INFO` level.

  ```rs
  //! src/configuration.rs
  use sqlx::ConnectOptions;
  // [...]

  impl DatabaseSettings {
      // [...]
      pub fn with_db(&self) -> PgConnectOptions {
          self.without_db()
              .database(&self.database_name)
              .log_statements(tracing_log::log::LevelFilter::Trace)
      }
  }
  ```

- I left out the notes on the Digital Ocean `spec.yaml` and command-line
  interactions, but the `spec` is in the repo, and the `doctl` commands in the
  book should we really want to go back and spin this up.

## Reject Invalid Subscribers #1

- Our service doesn't do much validation other than making sure we have both
  name and email. Let's start with a test to probe how we handle some
  troublesome inputs.

  ```rs
  #[tokio::test]
  async fn subscribe_returns_a_200_when_fields_are_present_but_empty() {
      // Arrange
      let app = spawn_app().await;
      let client = reqwest::Client::new();
      let test_cases = vec![
          ("name=&email=ursula_le_guin%40gmail.com", "empty name"),
          ("name=Ursula&email=", "empty email"),
          ("name=Ursula&email=definitely-not-an-email", "invalid email"),
      ];

      for (body, description) in test_cases {
          // Act
          let response = client
              .post(&format!("{}/subscriptions", &app.address))
              .header("Content-Type", "application/x-www-form-urlencoded")
              .body(body)
              .send()
              .await
              .expect("Failed to execute request.");

          // Assert
          assert_eq!(
              200,
              response.status().as_u16(),
              "The API did not return a 200 OK when the payload was {}.",
              description,
          );
      }
  }
  ```

- It's a fool's errand to try to make sure names are valid, but we will
  institute some basic sanity checks. We want to enforce a maximum length of 256
  characters and reject troublesome characters such as `/()"<>\{}`.
- Rather than calling an `is_valid` function before passing to `insert`, we are
  going to encode that our input has been tested for validity in a type so we
  don't need to check at every boundary. When you work with a `SubscriberName`,
  you can trust it is less than 256 characters and doesn't contain forbidden
  characters. We are going to put our new types in a `domain` module. A
  `SubscriberName` is just a tuple-struct that holds a `String`, but its
  `String` field is private, so it's impossible to construct outside of `domain`
  without using helper functions defined within `domain`. That is why we will
  define a `parse` function. It is **impossible** for an instance of
  `SubscriberName` to violate our constraints. We made an incorrect usage
  pattern unrepresentable, by construction - it will not compile. This is known
  as _type-driven development_. This particular pattern is commonly referred to
  as the _new-type pattern_ in the Rust community.

  ```rs
  //! src/domain.rs
  use unicode_segmentation::UnicodeSegmentation;

  pub struct NewSubscriber {
      pub email: String,
      pub name: SubscriberName,
  }

  pub struct SubscriberName(String);

  impl SubscriberName {
      /// Returns an instance of `SubscriberName` is the input satisfies all
      /// our validation constraints on subscriber names.
      /// It panics otherwise.
      pub fn parse(s: String) -> SubscriberName {
          // `.trim()` returns a view over the input `s` without trailing
          // whitespace-like characters.
          // `.is_empty()` checks if the view contains any character.
          let is_empty_or_whitespace = s.trim().is_empty();

          // A grapheme is defined by the Unicode standard as a "user-perceived"
          // character: `å` is a single grapheme, but it is composed of two characters
          // (`a` and `̊`).
          //
          // `graphemes` returns an iterator over the graphemes in the input `s`.
          // `true` specifies that we want to use the extended grapheme definition set,
          // the recommended one.
          let is_too_long = s.graphemes(true).count() > 256;

          // Iterate over all characters in the input `s` to check if any of them
          // matches one of the characters in the forbidden array.
          let forbidden_characters = ['/', '(', ')', '"', '<', '>', '\\', '{', '}'];
          let contains_forbidden_characters = s
              .chars()
              .any(|g| forbidden_characters.contains(&g));

          if is_empty_or_whitespace || is_too_long || contains_forbidden_characters {
              panic!("{} is not a valid subscriber name.", s)
          } else {
              Self(s)
          }
      }

      pub fn inner_ref(&self) -> &str {
          // The caller gets a shared reference to the inner string.
          // This gives the caller **read-only** access,
          // they have no way to compromise our invariants!
          &self.0
      }
  }

  //! src/routes/subscriptions.rs
  use crate::domain::{NewSubscriber, SubscriberName};
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
          subscriber_email = %form.email,
          subscriber_name = %form.name,
      )
  )]
  pub async fn subscribe(
      form: web::Form<FormData>,
      pool: web::Data<PgPool>)
  -> HttpResponse {
      // `web::Form` is a wrapper around `FormData`
      // `form.0` gives us access to the underlying `FormData`
      let new_subscriber = NewSubscriber {
          email: form.0.email,
          name: SubscriberName::parse(form.0.name),
      };
      match insert_subscriber(&pool, &new_subscriber).await {
          Ok(_) => HttpResponse::Ok().finish(),
          Err(_) => HttpResponse::InternalServerError().finish(),
      }
  }

  #[tracing::instrument(
      name = "Saving new subscriber details in the database",
      skip(new_subscriber, pool)
  )]
  pub async fn insert_subscriber(
      pool: &PgPool,
      new_subscriber: &NewSubscriber,
  ) -> Result<(), sqlx::Error> {
      sqlx::query!(
          r#"
          INSERT INTO subscriptions (id, email, name, subscribed_at)
          VALUES ($1, $2, $3, $4)
          "#,
          Uuid::new_v4(),
          new_subscriber.email,
          new_subscriber.name,
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

- We used an `inner_ref` method, but the standard library exposes a trait
  exactly for this type of usage - `AsRef`. You should implement `AsRef<T>` for
  a type when the type is _similar enough_ to `T` that we can use `&self` to get
  a reference to `T` itself. For `SubscriberName`, that would be `AsRef<str>`.
  Using this would improve ergonomics.

  ```rs
  //! src/domain.rs
  // [...] (remove `inner_ref`)

  impl AsRef<str> for SubscriberName {
      fn as_ref(&self) -> &str {
          &self.0
      }
  }

  //! src/subscriptions.rs
  // [...]

  #[tracing::instrument(
      name = "Saving new subscriber details in the database",
      skip(new_subscriber, pool)
  )]
  pub async fn insert_subscriber(
      pool: &PgPool,
      new_subscriber: &NewSubscriber,
  ) -> Result<(), sqlx::Error> {
      sqlx::query!(
          r#"
          INSERT INTO subscriptions (id, email, name, subscribed_at)
          VALUES ($1, $2, $3, $4)
          "#,
          Uuid::new_v4(),
          new_subscriber.email,
          new_subscriber.name.as_ref(),
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

- Our new exploratory test fails now, but we are just crashing the request with
  an `IncompleteMessage` error on bad data. Let's first modify the test so it
  passes when we return `400 Bad Request` for incorrect input, and then modify
  our code to handle bad data more gracefully than a `panic!`.

  ```rs
  //! src/health_check.rs
  // [...]

  #[tokio::test]
  async fn subscribe_returns_a_400_when_fields_are_present_but_invalid() {
      // [...]

          // Assert
          assert_eq!(
              400,
              response.status().as_u16(),
              "The API did not return a 400 Bad Request when the payload was {}.",
              description,
          );
      }
  }
  ```

- Panics in Rust are used to deal with unrecoverable errors. A panic in actix
  doesn't crash the whole application, it just kills a worker that gets
  respawned, but it still isn't the right way to handle bad input. To quote
  burntsushi:

  > If your Rust application panics in response to any user input, then the
  > following should be true: your application has a bug, whether it be in a
  > library or in the primary application code.

- We will refactor `parse` to return a `Result`. To keep things simple for now,
  we'll just return a `String` for our error message. We will also use the
  `claims` crate to get better error messages when we assert `is_ok` or `is_err`
  on a `Result`. Instead of calling `assert!(result.is_ok());` we instead call
  `claims::assert_ok!(result);`.

  ```toml
  #! Cargo.toml
  [dev-dependencies]
  claims = "0.7"
  ```

  ```rs
  //! src/routes/subscriptions.rs
  // For now, we're still just crashing on bad data. We'll deal with it
  // properly later.
  #[tracing::instrument(
      name = "Adding a new subscriber",
      skip(form, pool),
      fields(
          subscriber_email = %form.email,
          subscriber_name = %form.name,
      )
  )]
  pub async fn subscribe(form: web::Form<FormData>, pool: web::Data<PgPool>) -> HttpResponse {
      // `web::Form` is a wrapper around `FormData`
      // `form.0` gives us access to the underlying `FormData`
      let new_subscriber = NewSubscriber {
          email: form.0.email,
          name: SubscriberName::parse(form.0.name).expect("Name validation failed."),
      };
      match insert_subscriber(&pool, &new_subscriber).await {
          Ok(_) => HttpResponse::Ok().finish(),
          Err(_) => HttpResponse::InternalServerError().finish(),
      }
  }

  //! src/domain.rs
  // We need Debug to use it with our new macros.
  #[derive(Debug)]
  pub struct SubscriberName(String);

  impl SubscriberName {
      /// Returns an instance of `SubscriberName` is the input satisfies all
      /// our validation constraints on subscriber names.
      /// It panics otherwise.
      pub fn parse(s: String) -> Result<SubscriberName, String> {
          // `.trim()` returns a view over the input `s` without trailing
          // whitespace-like characters.
          // `.is_empty()` checks if the view contains any character.
          let is_empty_or_whitespace = s.trim().is_empty();

          // A grapheme is defined by the Unicode standard as a "user-perceived"
          // character: `å` is a single grapheme, but it is composed of two characters
          // (`a` and `̊`).
          //
          // `graphemes` returns an iterator over the graphemes in the input `s`.
          // `true` specifies that we want to use the extended grapheme definition set,
          // the recommended one.
          let is_too_long = s.graphemes(true).count() > 256;

          // Iterate over all characters in the input `s` to check if any of them
          // matches one of the characters in the forbidden array.
          let forbidden_characters = ['/', '(', ')', '"', '<', '>', '\\', '{', '}'];
          let contains_forbidden_characters = s.chars().any(|g| forbidden_characters.contains(&g));

          if is_empty_or_whitespace || is_too_long || contains_forbidden_characters {
              Err(format!("{} is not a valid subscriber name", s))
          } else {
              Ok(Self(s))
          }
      }
  }
  ```

- With this, all our new unit tests pass, and our integration test is still
  failing. Let's do something about that panic from `expect`.

  ```rs
  //! src/routes/subscription.rs
  pub async fn subscribe(
      form: web::Form<FormData>,
      pool: web::Data<PgPool>)
  -> HttpResponse {
      let name = match SubscriberName::parse(form.0.name) {
          Ok(name) => name,
          // Return early if the name is invalid, with a 400
          Err(_) => return HttpResponse::BadRequest().finish(),
      };
      let new_subscriber = NewSubscriber {
          email: form.0.email,
          name,
      };
      match insert_subscriber(&pool, &new_subscriber).await {
          Ok(_) => HttpResponse::Ok().finish(),
          Err(_) => HttpResponse::InternalServerError().finish(),
      }
  }
  ```

- Now our integration tests pass for invalid subscriber names, but still doesn't
  do anything about validating email. Validating email is even harder than
  validating names. So rather than just make sure there's an `@` in it and call
  it a day, we are going to use the `validator` crate. Other than using a
  dependency, we will follow the same strategy we used for name validation -
  encode our invariant in a new `SubscriberEmail` type.
- But first we're going to split up our domain module. Instead of declaring all
  our types and logic in one `domain.rs`, we will have
  `domain/subscriber_name.rs`, `domain/subscriber_email.rs`, and
  `domain/new_subscriber.rs`.

  ```rs
  //! src/domain/mod.rs

  mod subscriber_name;
  mod subscriber_email;
  mod new_subscriber;

  pub use subscriber_name::SubscriberName;
  pub use new_subscriber::NewSubscriber;

  //! src/domain/new_subscriber.rs

  use crate::domain::subscriber_name::SubscriberName;

  pub struct NewSubscriber {
      pub email: String,
      pub name: SubscriberName,
  }


  //! src/domain/subscriber_name.rs

  use unicode_segmentation::UnicodeSegmentation;

  #[derive(Debug)]
  pub struct SubscriberName(String);

  impl SubscriberName {
      /// Returns an instance of `SubscriberName` is the input satisfies all
      /// our validation constraints on subscriber names.
      /// It panics otherwise.
      pub fn parse(s: String) -> Result<SubscriberName, String> {
          // `.trim()` returns a view over the input `s` without trailing
          // whitespace-like characters.
          // `.is_empty()` checks if the view contains any character.
          let is_empty_or_whitespace = s.trim().is_empty();

          // A grapheme is defined by the Unicode standard as a "user-perceived"
          // character: `å` is a single grapheme, but it is composed of two
          // character (`a` and `̊`).
          //
          // `graphemes` returns an iterator over the graphemes in the input `s`.
          // `true` specifies that we want to use the extended grapheme definition
          // set, the recommended one.
          let is_too_long = s.graphemes(true).count() > 256;

          // Iterate over all characters in the input `s` to check if any of them
          // matches one of the characters in the forbidden array.
          let forbidden_characters = ['/', '(', ')', '"', '<', '>', '\\', '{', '}'];
          let contains_forbidden_characters = s
              .chars()
              .any(|g| forbidden_characters.contains(&g));

          if is_empty_or_whitespace || is_too_long || contains_forbidden_characters {
              Err(format!("{} is not a valid subscriber name", s))
          } else {
              Ok(Self(s))
          }
      }
  }

  impl AsRef<str> for SubscriberName {
      fn as_ref(&self) -> &str {
          &self.0
      }
  }

  #[cfg(test)]
  mod tests {
      use super::*;
      use claims::{assert_err, assert_ok};

      #[test]
      fn a_256_grapheme_long_name_is_valid() {
          let name = "ё".repeat(256);
          assert_ok!(SubscriberName::parse(name));
      }

      #[test]
      fn a_name_longer_than_256_graphemes_is_rejected() {
          let name = "a".repeat(257);
          assert_err!(SubscriberName::parse(name));
      }

      #[test]
      fn whitespace_only_names_are_rejected() {
          let name = " ".to_string();
          assert_err!(SubscriberName::parse(name));
      }

      #[test]
      fn empty_string_is_rejected() {
          let name = "".to_string();
          assert_err!(SubscriberName::parse(name));
      }

      #[test]
      fn names_containing_an_invalid_character_are_rejected() {
          for name in &['/', '(', ')', '"', '<', '>', '\\', '{', '}'] {
              let name = name.to_string();
              assert_err!(SubscriberName::parse(name));
          }
      }

      #[test]
      fn a_valid_name_parsed_successfully() {
          let name = "Ursula Le Guin".to_string();
          assert_ok!(SubscriberName::parse(name));
      }
  }
  ```

- That restructure is enough to get us back to properly failing for returning
  200 instead of 400 for a bad email. Now for our `SubscriberEmail` type.

  ```toml
  #! Cargo.toml
  [dependencies]
  validator = "0.16"
  ```

  ```rs
  //! src/domain/subscriber_email.rs

  use validator::validate_email;

  #[derive(Debug)]
  pub struct SubscriberEmail(String);

  impl SubscriberEmail {
      pub fn parse(s: String) -> Result<SubscriberEmail, String> {
          if validate_email(&s) {
              Ok(Self(s))
          } else {
              Err(format!("{} is not a valid subscriber email.", s))
          }
      }
  }

  impl AsRef<str> for SubscriberEmail {
      fn as_ref(&self) -> &str {
          &self.0
      }
  }

  #[cfg(test)]
  mod test {
      use super::*;
      use claims::{assert_err, assert_ok};

      #[test]
      fn empty_string_is_rejected() {
          let email = "".to_string();
          assert_err!(SubscriberEmail::parse(email));
      }

      #[test]
      fn email_missing_at_symbol_is_rejected() {
          let email = "ursuladomain.com".to_string();
          assert_err!(SubscriberEmail::parse(email));
      }

      #[test]
      fn email_missing_subject_is_rejected() {
          let email = "@domain.com".to_string();
          assert_err!(SubscriberEmail::parse(email));
      }
  }
  ```

- That's good enough to pass our unit tests, and we'll integrate it with the
  rest of the code here in a minute. But we currently don't have any tests for
  good email addresses. Instead of just testing one good email address, we are
  going to use property-based testing to generate random valid values. We'll
  explore two different crates for this: `fake` then `quickcheck`.

  ```toml
  #! Cargo.toml
  [dev-dependencies]
  fake = "~2.3"
  ```

  ```rs
  #! src/domain/subscriber_email.rs
  #[cfg(test)]
  mod test {
      use super::*;
      use claims::{assert_err, assert_ok};
      use fake::Fake;
      use fake::faker::internet::en::SafeEmail;

      // [..]

      #[test]
      fn valid_emails_are_parsed_successfully() {
          let email = SafeEmail().fake();
          assert_ok!(SubscriberEmail::parse(email));
      }
  }
  ```

- `faker` does a good job testing a valid email address, but `quickcheck` is for
  when we want to test 100.

  ```toml
  #! Cargo.toml
  [dev-dependencies]
  quickcheck = "0.9.2"
  quickcheck_macros = "0.9.1"
  ```

  ```rs
  //! src/domain/subscriber_email.rs
  // [...]
  #[cfg(test)]
  mod test {
      // [...]

      // Both `Clone` and `Debug` are required by `quickcheck`
      #[derive(Debug, Clone)]
      struct ValidEmailFixture(pub String);

      impl quickcheck::Arbitrary for ValidEmailFixture {
          fn arbitrary<G: quickcheck::Gen>(g: &mut G) -> Self {
              let email = SafeEmail().fake_with_rng(g);
              Self(email)
          }
      }

      #[quickcheck_macros::quickcheck]
      fn prop_valid_emails_are_parsed_successfully(
          valid_email: ValidEmailFixture)
      -> bool {
          SubscriberEmail::parse(valid_email.0).is_ok()
      }
  }
  ```

- We could see some of the random inputs being generated by adding a
  `dbg!(&valid_email.0);` statement to the new test and running
  `cargo test valid_emails -- --nocapture`.
- Now that our `SubscriberEmail` is thoroughly tested, let's integrate it into
  the rest of the application.

  ```rs
  //! src/domain/new_subscriber.rs

  use crate::domain::subscriber_email::SubscriberEmail;
  use crate::domain::subscriber_name::SubscriberName;

  pub struct NewSubscriber {
      pub email: SubscriberEmail,
      pub name: SubscriberName,
  }

  //! src/routes/subscriptions.rs
  use crate::domain::{NewSubscriber, SubscriberEmail, SubscriberName};
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
          subscriber_email = %form.email,
          subscriber_name = %form.name,
      )
  )]
  pub async fn subscribe(
      form: web::Form<FormData>,
      pool: web::Data<PgPool>)
  -> HttpResponse {
      let name = match SubscriberName::parse(form.0.name) {
          Ok(name) => name,
          // Return early if the name is invalid, with a 400
          Err(_) => return HttpResponse::BadRequest().finish(),
      };
      let email = match SubscriberEmail::parse(form.0.email) {
          Ok(email) => email,
          Err(_) => return HttpResponse::BadRequest().finish(),
      };
      let new_subscriber = NewSubscriber { email, name };
      match insert_subscriber(&pool, &new_subscriber).await {
          Ok(_) => HttpResponse::Ok().finish(),
          Err(_) => HttpResponse::InternalServerError().finish(),
      }
  }

  #[tracing::instrument(
      name = "Saving new subscriber details in the database",
      skip(new_subscriber, pool)
  )]
  pub async fn insert_subscriber(
      pool: &PgPool,
      new_subscriber: &NewSubscriber,
  ) -> Result<(), sqlx::Error> {
      sqlx::query!(
          r#"
          INSERT INTO subscriptions (id, email, name, subscribed_at)
          VALUES ($1, $2, $3, $4)
          "#,
          Uuid::new_v4(),
          new_subscriber.email.as_ref(),
          new_subscriber.name.as_ref(),
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

- And all our tests pass! So its time to do some refactoring. Our `subscribe`
  function has a bit of repetition now. We can factor out `parse_subscriber`.

  ```rs
  //! src/routes/subscriptions.rs
  // [...]

  pub fn parse_subscriber(form: FormData) -> Result<NewSubscriber, String> {
      let name = SubscriberName::parse(form.name)?;
      let email = SubscriberEmail::parse(form.email)?;
      Ok(NewSubscriber { email, name })
  }

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
      let new_subscriber = match parse_subscriber(form.0) {
          Ok(subscriber) => subscriber,
          Err(_) => return HttpResponse::BadRequest().finish(),
      };
      match insert_subscriber(&pool, &new_subscriber).await {
          Ok(_) => HttpResponse::Ok().finish(),
          Err(_) => HttpResponse::InternalServerError().finish(),
      }
  }
  ```

- The Rust standard library provides several traits related to conversions in
  the `std::convert` sub-module. This is where `AsRef` comes from! We are doing
  a fallible conversion between two types here which is what `TryFrom` is for.

  ```rs
  // For reference, the definition of `TryFrom`
  pub trait TryFrom<T>: Sized {
      type Error;

      fn try_from(value: T) -> Result<Self, Self::Error>;
  }

  // And `TryInto`, the blanket implementation you get for free!
  pub trait TryInto<T> {
      type Error;
      fn try_into(self) -> Result<T, Self::Error>;
  }

  //! src/routes/subscriptions.rs
  // No need to import the `TryFrom` trait, it is included
  // in Rust's prelude since edition 2021!
  // [...]

  impl TryFrom<FormData> for NewSubscriber {
      type Error = String;

      fn try_from(value: FormData) -> Result<Self, Self::Error> {
          let name = SubscriberName::parse(value.name)?;
          let email = SubscriberEmail::parse(value.email)?;
          Ok(Self { email, name })
      }
  }

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
      let new_subscriber = match form.0.try_into() {
          Ok(subscriber) => subscriber,
          Err(_) => return HttpResponse::BadRequest().finish(),
      };
      match insert_subscriber(&pool, &new_subscriber).await {
          Ok(_) => HttpResponse::Ok().finish(),
          Err(_) => HttpResponse::InternalServerError().finish(),
      }
  }
  ```

- By using `try_into`, we can do `form.0.try_into()` instead of
  `NewSubscriber::try_from(form.0)`. Using `TryFrom` and `TryInto` instead of
  our `parse_subscriber` function doesn't add any functionality. It just spells
  out our intent more clearly that "This is a type conversion!".

## Chapter 7 - Reject Invalid Subscribers #2

- We now check that emails are syntactically valid but we are still uncertain
  about their existence. So we will send out a confirmation email.
- I replaced the recommended email sender service (Postmark) with
  [Resend](https://resend.com/onboarding) which lets you sign up with a Github
  account since I didn't want to give out my work email address.
- So we will make our `EmailClient` take a `sender` address on construction and
  have an asynchronous `send_email` method that takes `recipient`, `subject`,
  `html_content`, and `text_content`. Something like this:

  ```rs
  //! src/email_client.rs

  use crate::domain::SubscriberEmail;

  pub struct EmailClient {
      sender: SubscriberEmail
  }

  impl EmailClient {
      pub async fn send_email(
          &self,
          recipient: SubscriberEmail,
          subject: &str,
          html_content: &str,
          text_content: &str,
      ) -> Result<(), String> {
          todo!()
      }
  }

  //! src/lib.rs
  pub mod configuration;
  pub mod domain;
  pub mod email_client;
  pub mod routes;
  pub mod startup;
  pub mod telemetry;
  ```

- We need to call a REST API. We already have `reqwest` in our
  `dev-dependencies`, so we'll just promote it.

  ```toml
  #! Cargo.toml
  [dependencies.reqwest]
  version = "0.11"
  default-features = false

  # Remove `reqwest` from dev-dependencies
  ```

- Creating a connection is somewhat expensive, so behind the scenes the client
  uses a connection pool. We want to reuse the same client to take advantage of
  this across multiple requests. `Client::clone` does not create a new
  connection pool - it just clones a pointer to the underlying pool. To re-use
  the same client across multiple requests in `actix-web`, we need to store a
  copy of it in the application context so we can retrieve a reference to it in
  our request handlers using an extractor (e.g. `actix_web::web::Data`).
- We could either derive the `Clone` trait for our `EmailClient` and pass a
  clone to `app_data` when we build our `App` instances, or we could wrap
  `EmailClient` in `actix_web::web::Data` (an `Arc` pointer) and pass a pointer
  to `app_data` like we are doing with `PgPool`. Since our `EmailClient` has
  several `String` / `Secret<String>` fields that would need to be allocated, we
  use option 2 to only need a pointer to the single `EmailClient`, but the
  difference in this case is negligible.

  ```rs
  //! src/startup.rs
  use crate::email_client::EmailClient;
  use crate::routes::{health_check, subscribe};
  use actix_web::dev::Server;
  use actix_web::web::Data;
  use actix_web::{App, HttpServer, web};
  use sqlx::PgPool;
  use std::net::TcpListener;
  use tracing_actix_web::TracingLogger;

  pub fn run(
      listener: TcpListener,
      connection_pool: PgPool,
      email_client: EmailClient,
  ) -> Result<Server, std::io::Error> {
      // Wrap the connection in a smart pointer
      let db_pool = Data::new(connection_pool);
      let email_client = Data::new(email_client);
      // Capture `connection` from the surrounding environment
      let server = HttpServer::new(move || {
          App::new()
              // Middlweares are added using the `wrap` method on `App`
              .wrap(TracingLogger::default())
              .route("/health_check", web::get().to(health_check))
              .route("/subscriptions", web::post().to(subscribe))
              .app_data(db_pool.clone())
              .app_data(email_client.clone())
      })
      .listen(listener)?
      .run();
      Ok(server)
  }

  //! src/configuration.rs
  use crate::domain::SubscriberEmail;
  // [...]

  #[derive(serde::Deserialize)]
  pub struct Settings {
      pub database: DatabaseSettings,
      pub application: ApplicationSettings,
      pub email_client: EmailClientSettings,
  }

  #[derive(serde::Deserialize)]
  pub struct EmailClientSettings {
      pub base_url: String,
      pub sender_email: String,
  }

  impl EmailClientSettings {
      pub fn sender(&self) -> Result<SubscriberEmail, String> {
          SubscriberEmail::parse(self.sender_email.clone())
      }
  }

  // [...]

  //! main.rs
  use sqlx::PgPool;
  use std::net::TcpListener;
  use zero2prod::configuration::get_configuration;
  use zero2prod::email_client::EmailClient;
  use zero2prod::startup::run;
  use zero2prod::telemetry::{get_subscriber, init_subscriber};

  #[tokio::main]
  async fn main() -> Result<(), std::io::Error> {
      let subscriber =
          get_subscriber("zero2prod".into(), "info".into(), std::io::stdout);
      init_subscriber(subscriber);

      let configuration = get_configuration()
          .expect("Failed to read configuration.");
      let connection_pool =
          PgPool::connect_lazy_with(configuration.database.with_db());

      let sender_email = configuration.email_client.sender()
          .expect("Invalid sender email address.");
      let email_client = EmailClient::new(
          configuration.email_client.base_url,
          sender_email,
      );

      let address = format!(
          "{}:{}",
          configuration.application.host, configuration.application.port
      );
      let listener = TcpListener::bind(address)?;
      run(listener, connection_pool, email_client)?.await
  }

  //! tests/health_check.rs
  // [...]
  use zero2prod::configuration::{DatabaseSettings, get_configuration};
  // [...]

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

      let sender_email = configuration
          .email_client
          .sender()
          .expect("Invalid sender email address.");
      let email_client = EmailClient::new(
          configuration.email_client.base_url, sender_email);

      let server =
          run(listener, connection_pool.clone(), email_client)
              .expect("Failed to bind address");
      // Launch the server as a background task
      drop(tokio::spawn(server));
      TestApp {
          address,
          db_pool: connection_pool,
      }
  }
  ```

- There's still a lot to do before we send confirmation emails, so we'll wait to
  write full integration tests until later. But we're going to introduce some
  unit tests for our `EmailClient`. We want to know the HTTP call happened and
  the headers were populated as we expected, so we will use `wiremock`.

  ```toml
  #! Cargo.toml
  # [...]

  [dev-dependencies]
  wiremock = "0.5"
  ```

  ```rs
  // src/email_client.rs
  // [...]

  #[cfg(test)]
  mod tests {
      use super::*;
      use crate::domain::SubscriberEmail;
      use fake::faker::internet::en::SafeEmail;
      use fake::faker::lorem::en::{Paragraph, Sentence};
      use fake::{Fake, Faker};
      use wiremock::matchers::any;
      use wiremock::{Mock, MockServer, ResponseTemplate};

      #[tokio::test]
      async fn send_email_fires_a_request_to_base_url() {
          // Arrange
          let mock_server = MockServer::start().await;
          let sender = SubscriberEmail::parse(SafeEmail().fake()).unwrap();
          let email_client = EmailClient::new(mock_server.uri(), sender);

          Mock::given(any())
              .respond_with(ResponseTemplate::new(200))
              .expect(1)
              .mount(&mock_server)
              .await;

          let subscriber_email = SubscriberEmail::parse(SafeEmail().fake()).unwrap();
          let subject: String = Sentence(1..2).fake();
          let content: String = Paragraph(1..10).fake();

          // Act
          let _ = email_client
              .send_email(subscriber_email, &subject, &content, &content)
              .await;

          // Assert
      }
  }
  ```

- So `MockServer::start().await` fires up an HTTP server that runs in the
  background and listens on a random port. We call `mock_server.uri` to get the
  URL to set as our `EmailClient` `base_url` value. Out of the box,
  `wiremock::MockServer` returns `404 Not Found` to all incoming requests. We
  can define mocks which it will iterate over until it finds a request matching
  a condition in `Mock::given`. `given(any())` matches all incoming requests. It
  returns a response following what was specified with `respond_with`, in this
  case a `200 OK` status with no body. A `wiremock::Mock` is only effective if
  mounted on a `wiremock::MockServer` with `mount`.
- We could have used hardcoded values here rather than calling `fake`, but
  random data conveys a specific message here: do not pay attention to these
  inputs, their values do not influence the outcome of the test.
- We don't actually assert anything. Here the `expect(1)` statement on our mock
  is doing the job of verifying that the mock server gets at least one request.
  They are verified when the `MockServer` goes out of scope, and if the
  expectation is not met, it will trigger a panic and fail the test.
- Before we build out our full email client, let's add support for the
  `authorization_token` to our `EmailClient`.

  ```rs
  //! src/email_client.rs
  use secrecy::Secret;
  // [...]

  pub struct EmailClient {
      // [...]
      // We don't want to log this by accident
      authorization_token: Secret<String>
  }

  impl EmailClient {
      pub fn new(
          // [...]
          authorization_token: Secret<String>
      ) -> Self {
          Self {
              // [...]
              authorization_token
          }
      }
      // [...]
  }

  //! src/configuration.rs
  // [...]

  #[derive(serde::Deserialize)]
  pub struct EmailClientSettings {
      // [...]
      // New (secret) configuration value!
      pub authorization_token: Secret<String>
  }

  // [...]

  //! src/email_client.rs
  // [...]

  #[cfg(test)]
  mod tests {
      use secrecy::Secret;
      // [...]

      #[tokio::test]
      async fn send_email_fires_a_request_to_base_url() {
          let mock_server = MockServer::start().await;
          let sender = SubscriberEmail::parse(SafeEmail().fake()).unwrap();
          // New argument!
          let email_client = EmailClient::new(
              mock_server.uri(),
              sender,
              Secret::new(Faker.fake())
          );
          // [...]
      }
  }

  //! src/main.rs
  // [...]

  #[tokio::main]
  async fn main() -> Result<(), std::io::Error> {
      // [...]
      let email_client = EmailClient::new(
          configuration.email_client.base_url,
          sender_email,
          // Pass argument from configuration
          configuration.email_client.authorization_token,
      );
      // [...]
  }

  //! tests/health_check.rs
  // [...]
  async fn spawn_app() -> TestApp {
      // [...]
      let email_client = EmailClient::new(
          configuration.email_client.base_url,
          sender_email,
          // Pass argument from configuration
          configuration.email_client.authorization_token,
      );
      // [...]
  }
  // [...]

  #! configuration/base.yml
  # [...]
  email_client:
    base_url: "localhost"
    sender_email: "test@gmail.com"
    # New value!
    # We are only setting the development value,
    # we'll deal with the production token outside of version control
    # (given that it's a sensitive secret!)
    authorization_token: "my-secret-token"

  //! src/email_client.rs
  use secrecy::{ExposeSecret, Secret};
  // [...]

  impl EmailClient {
  // [...]
      pub async fn send_email(
          // [...]
      ) -> Result<(), String> {
          // [...]
          let builder = self
              .http_client
              .post(&url)
              .header(
                  "X-Postmark-Server-Token",
                  self.authorization_token.expose_secret()
              )
              .json(&request_body);
          Ok(())
      }
  }
  ```

- We're also going to tighten up our mock. The first was simple to display the
  basics, but you see below we have heightened our expectations. You use `and`
  to chain together matches and test multiple values. We also used our own
  `SendEmailBodyMatcher` struct that implement `wiremock::Match` so we can match
  elements of the request body to make sure they conform to our email API
  required fields.

  ```toml
  #! Cargo.toml
  # [...]

  [dev-dependencies]
  # We need to deserialize the request body as JSON
  serde_json = "1"
  ```

  ```rs
  //! src/email_client.rs

  use crate::domain::SubscriberEmail;
  use reqwest::Client;
  use secrecy::{ExposeSecret, Secret};

  pub struct EmailClient {
      http_client: Client,
      base_url: String,
      sender: SubscriberEmail,
      authorization_token: Secret<String>,
  }

  impl EmailClient {
      pub fn new(
          base_url: String,
          sender: SubscriberEmail,
          authorization_token: Secret<String>,
      ) -> Self {
          Self {
              http_client: Client::new(),
              base_url,
              sender,
              authorization_token,
          }
      }

      pub async fn send_email(
          &self,
          recipient: SubscriberEmail,
          subject: &str,
          html_content: &str,
          text_content: &str,
      ) -> Result<(), reqwest::Error> {
          // You can do better using `reqwest::Url::join` if you change
          // `base_url`'s type from `String` to `reqwest::Url`.
          let url = format!("{}/email", self.base_url);
          let request_body = SendEmailRequest {
              from: self.sender.as_ref().to_owned(),
              to: recipient.as_ref().to_owned(),
              subject: subject.to_owned(),
              html_body: html_content.to_owned(),
              text_body: text_content.to_owned(),
          };
          self.http_client
              .post(&url)
              .header(
                  "X-Postmark-Server-Token",
                  self.authorization_token.expose_secret(),
              )
              .json(&request_body)
              .send()
              .await?;
          Ok(())
      }
  }

  #[derive(serde::Serialize)]
  #[serde(rename_all = "PascalCase")]
  struct SendEmailRequest {
      from: String,
      to: String,
      subject: String,
      html_body: String,
      text_body: String,
  }

  #[cfg(test)]
  mod tests {
      use super::*;
      use crate::domain::SubscriberEmail;
      use fake::faker::internet::en::SafeEmail;
      use fake::faker::lorem::en::{Paragraph, Sentence};
      use fake::{Fake, Faker};
      use wiremock::matchers::{header, header_exists, method, path};
      use wiremock::{Mock, MockServer, Request, ResponseTemplate};

      struct SendEmailBodyMatcher;

      impl wiremock::Match for SendEmailBodyMatcher {
          fn matches(&self, request: &Request) -> bool {
              let result: Result<serde_json::Value, _> =
                  serde_json::from_slice(&request.body);
              if let Ok(body) = result {
                  // Check that all mandatory fields are populated
                  // without inspecting the field Value
                  body.get("From").is_some()
                      && body.get("To").is_some()
                      && body.get("Subject").is_some()
                      && body.get("HtmlBody").is_some()
                      && body.get("TextBody").is_some()
              } else {
                  // If parsing failed, do not match the request
                  false
              }
          }
      }

      #[tokio::test]
      async fn send_email_fires_a_request_to_base_url() {
          // Arrange
          let mock_server = MockServer::start().await;
          let sender = SubscriberEmail::parse(SafeEmail().fake()).unwrap();
          let email_client = EmailClient::new(
              mock_server.uri(),
              sender,
              Secret::new(Faker.fake())
          );

          Mock::given(header_exists("X-Postmark-Server-Token"))
              .and(header("Content-Type", "application/json"))
              .and(path("/email"))
              .and(method("POST"))
              .and(SendEmailBodyMatcher)
              .respond_with(ResponseTemplate::new(200))
              .expect(1)
              .mount(&mock_server)
              .await;

          let subscriber_email = SubscriberEmail::parse(SafeEmail().fake()).unwrap();
          let subject: String = Sentence(1..2).fake();
          let content: String = Paragraph(1..10).fake();

          // Act
          let _ = email_client
              .send_email(subscriber_email, &subject, &content, &content)
              .await;

          // Assert
      }
  }
  ```

- Now that our test suite is green is a good time for a refactoring. Right now
  we are doing needless memory allocations for our `SendEmailRequest`. Instead
  of using owned `String` values we could use `&str` to refer to the existing
  memory buffer, but we will need lifetimes.

  ```rs
  //! src/email_client.rs
  // [...]

  impl EmailClient {
  // [...]

      pub async fn send_email(
          // [...]
      ) -> Result<(), reqwest::Error> {
          // [...]
          let request_body = SendEmailRequest {
              from: self.sender.as_ref(),
              to: recipient.as_ref(),
              subject: subject.as_ref(),
              html_body: html_content.as_ref(),
              text_body: text_content.as_ref(),
          };
          // [...]
      }
  }

  #[derive(serde::Serialize)]
  #[serde(rename_all = "PascalCase")]
  struct SendEmailRequest<'a> {
      from: &'a str,
      to: &'a str,
      subject: &'a str,
      html_body: &'a str,
      text_body: &'a str,
  }
  ```

- Now there's more things we can test than the `EmailClient` calling the URL
  with a proper JSON body.

  ```rs
  //! src/email_client.rs
  // [...]

  #[cfg(test)]
  mod tests {
      // [...]
      use claims::{assert_err, assert_ok};
      use wiremock::matchers::{any, header, header_exists, method, path};
      // [...]

      #[tokio::test]
      async fn send_email_succeeds_if_the_server_returns_200() {
          // Arrange
          let mock_server = MockServer::start().await;
          let sender = SubscriberEmail::parse(SafeEmail().fake()).unwrap();
          let email_client = EmailClient::new(
              mock_server.uri(),
              sender,
              Secret::new(Faker.fake())
          );

          let subscriber_email = SubscriberEmail::parse(SafeEmail().fake()).unwrap();
          let subject: String = Sentence(1..2).fake();
          let content: String = Paragraph(1..10).fake();

          // We do not copy in all the matchers we have in the other test.
          // The purpose of this test is not to assert on the request we
          // are sending out!
          // We add the bare minimum needed to trigger the path we want
          // to test in `send_email`.
          Mock::given(any())
              .respond_with(ResponseTemplate::new(200))
              .expect(1)
              .mount(&mock_server)
              .await;

          // Act
          let outcome = email_client
              .send_email(subscriber_email, &subject, &content, &content)
              .await;

          // Assert
          assert_ok!(outcome);
      }

      #[tokio::test]
      async fn send_email_fails_if_the_server_returns_500() {
          // Arrange
          let mock_server = MockServer::start().await;
          let sender = SubscriberEmail::parse(SafeEmail().fake()).unwrap();
          let email_client = EmailClient::new(
              mock_server.uri(),
              sender,
              Secret::new(Faker.fake())
          );

          let subscriber_email = SubscriberEmail::parse(SafeEmail().fake()).unwrap();
          let subject: String = Sentence(1..2).fake();
          let content: String = Paragraph(1..10).fake();

          Mock::given(any())
              .respond_with(ResponseTemplate::new(500))
              .expect(1)
              .mount(&mock_server)
              .await;

          // Act
          let outcome = email_client
              .send_email(subscriber_email, &subject, &content, &content)
              .await;

          // Assert
          assert_err!(outcome);
      }
  }
  ```

- The first new test passes fine, but for the second we are still returning `Ok`
  when the server returns a `500`. Our `reqwest` method returns `Ok` no matter
  what status code it receives as long as the request was sent.

  ```rs
  //! src/email_client.rs
  // [...]

  impl EmailClient {
      // [...]
      pub async fn send_email(
          // [...]
      ) -> Result<(), reqwest::Error> {
          // [...]
          self.http_client
              .post(&url)
              .header(
                  "X-Postmark-Server-Token",
                  self.authorization_token.expose_secret(),
              )
              .json(&request_body)
              .send()
              .await?
              .error_for_status()?;
          Ok(())
      }
  }
  ```

- We need to be prepared for slow server responses. We currently don't specify
  any timeout. Our mock server is configurable to respond with a delay. As a
  rule of thumb: every time you are performing an IO operation, _always_ set a
  timeout! With `reqwest` we can set a default timeout for the client or apply a
  per-request timeout. We will opt for the default timeout.

  ```rs
  //! src/email_client.rs

  impl EmailClient {
      pub fn new(
          // [...]
      ) -> Self {
          let http_client = Client::builder()
              .timeout(std::time::Duration::from_secs(10))
              .build()
              .unwrap();
          Self {
              http_client,
              base_url,
              sender,
              authorization_token,
          }
      }
  }
  // [...]
  ```

- It's rather questionable having a test that takes 10 seconds in our unit
  tests. We're going to refactor that to pass quicker momentarily. But first we
  will introduce some test helpers to reduce duplication.

  ```rs
  //! src/email_client.rs
  // [...]

  #[cfg(test)]
  mod tests {
      // [...]

      /// Generate a random email subject
      fn subject() -> String {
          Sentence(1..2).fake()
      }

      /// Generate a random email content
      fn content() -> String {
          Paragraph(1..10).fake()
      }

      /// Generate a random subscriber email
      fn email() -> SubscriberEmail {
          SubscriberEmail::parse(SafeEmail().fake()).unwrap()
      }

      /// Get a test instance of `EmailClient`.
      fn email_client(base_url: String) -> EmailClient {
          EmailClient::new(base_url, email(), Secret::new(Faker.fake()))
      }

      // And here is one of other tests cleaned up to use the new methods
      #[tokio::test]
      async fn send_email_fires_a_request_to_base_url() {
          // Arrange
          let mock_server = MockServer::start().await;
          let email_client = email_client(mock_server.uri());

          Mock::given(header_exists("X-Postmark-Server-Token"))
              .and(header("Content-Type", "application/json"))
              .and(path("/email"))
              .and(method("POST"))
              .and(SendEmailBodyMatcher)
              .respond_with(ResponseTemplate::new(200))
              .expect(1)
              .mount(&mock_server)
              .await;

          // Act
          let _ = email_client
              .send_email(email(), &subject(), &content(), &content())
              .await;

          // Assert
      }

      // [...]
  }
  ```

- Now 10 seconds is way too long for a test to fail. We're going to make the
  timeout configurable, so we can set it low for our test.

  ```rs
  //! src/email_client.rs
  impl EmailClient {
      pub fn new(
          base_url: String,
          sender: SubscriberEmail,
          authorization_token: Secret<String>,
          timeout: std::time::Duration,
      ) -> Self {
          let http_client = Client::builder()
              .timeout(timeout)
              .build()
              .unwrap();
          Self {
              http_client,
              base_url,
              sender,
              authorization_token,
          }
      }
      // [...]
  }

  //! src/configuration.rs
  // [...]

  #[derive(serde::Deserialize)]
  pub struct EmailClientSettings {
      pub base_url: String,
      pub sender_email: String,
      pub authorization_token: Secret<String>,
      pub timeout_milliseconds: u64,
  }

  impl EmailClientSettings {
      pub fn sender(&self) -> Result<SubscriberEmail, String> {
          SubscriberEmail::parse(self.sender_email.clone())
      }

      pub fn timeout(&self) -> std::time::Duration {
          std::time::Duration::from_millis(self.timeout_milliseconds)
      }
  }

  //! src/main.rs
  // [...]

  #[tokio::main]
  async fn main() -> Result<(), std::io::Error> {
      // [...]
      let timeout = configuration.email_client.timeout();
      let email_client = EmailClient::new(
          configuration.email_client.base_url,
          sender_email,
          configuration.email_client.authorization_token,
          timeout,
      );
      // [...]
  }

  //! src/email_client.rs
  #[cfg(test)]
  mod tests {
      // [...]
      /// Get a test instance of `EmailClient`.
      fn email_client(base_url: String) -> EmailClient {
          EmailClient::new(
              base_url,
              email(),
              Secret::new(Faker.fake()),
              std::time::Duration::from_millis(200),
          )
      }
  }

  //! tests/health_check.rs
  // [...]

  async fn spawn_app() -> TestApp {
      // [...]
      let timeout = configuration.email_client.timeout();
      let email_client = EmailClient::new(
          configuration.email_client.base_url,
          sender_email,
          configuration.email_client.authorization_token,
          timeout,
      );
  }
  ```

  ```yaml
  #! configuration/base.yaml
  # [...]
  email_client:
    base_url: "localhost"
    sender_email: "test@gmail.com"
    authorization_token: "my-secret-token"
    timeout_milliseconds: 10000
  ```

- And because we factored out that helper, we only needed to set the timeout in
  one place instead of four. Since all the calls are to a mock, 200 milliseconds
  is more than enough.
- And we are finally going to refactor all the tests in `health_check.rs`!
  Integration tests are found in the `tests` folder, and each file within it is
  compiled as its own crate. If we have five top-level files in `tests`, they
  are compiled to five executables in `target/debug/deps`. There are several
  ways to share test helper functions. One is to define `tests/helpers/mod.rs`.
  This works well to start with but leads to annoying `function is never used`
  warnings down the line. The second option is to create sub-modules scoped to a
  single test executable. We create an `api` folder under `tests` with a
  `main.rs` inside. Then we declare sub-modules in `main.rs` and create files
  for each submodule. Your test suite will be compiled as a single executable.
  So we add one `main.rs` that declares modules, put all the helper code in
  `helpers.rs` (be sure to make `spawn_app` public), put the one `health_check`
  test in `tests/api/health_check.rs` after a `use crate::helpers::spawn_app`,
  and put the three `subscriptions` tests in `tests/api/subscriptions.rs` after
  a `use crate::helpers::spawn_app`.

  ```rs
  //! tests/api/main.rs

  mod helpers;
  mod health_check;
  mod subscriptions;
  ```

- Next we want to extract our startup logic. Right now we have to duplicate
  mostly the same steps in both `spawn_app` helper and our app's `main.rs`.
  That's two places to modify when we add a dependency or modify the server
  constructor. More importantly, our app startup logic is never tested.
  Factoring it out lets us fix both. From a structural perspective, our startup
  logic is a function taking `Settings` as input and returning an instance of
  our application as output. We want our main.rs to look like this:

  ```rs
  //! main.rs
  use zero2prod::configuration::get_configuration;
  use zero2prod::startup::build;
  use zero2prod::telemetry::{get_subscriber, init_subscriber};

  #[tokio::main]
  async fn main() -> Result<(), std::io::Error> {
      let subscriber = get_subscriber(
          "zero2prod".into(), "info".into(), std::io::stdout
      );
      init_subscriber(subscriber);

      let configuration = get_configuration()
          .expect("Failed to read configuration.");
      let server = build(configuration).await?;
      server.await?;
      Ok(())
  }
  ```

- And for that we need a `build` function:

  ```rs
  //! src/startup.rs
  // [...]
  use crate::configuration::Settings;
  use sqlx::postgres::PgPoolOptions;

  pub async fn build(configuration: Settings) -> Result<Server, std::io::Error> {
      let connection_pool = PgPoolOptions::new()
          .connect_lazy_with(configuration.database.with_db());

      let sender_email = configuration
          .email_client
          .sender()
          .expect("Invalid sender email address.");
      let timeout = configuration.email_client.timeout();
      let email_client = EmailClient::new(
          configuration.email_client.base_url,
          sender_email,
          configuration.email_client.authorization_token,
          timeout,
      );
      let address = format!(
          "{}:{}",
          configuration.application.host, configuration.application.port,
      );
      let listener = TcpListener::bind(address)?;
      run(listener, connection_pool, email_client)
  }
  ```

- Unfortunately, it isn't that simple with `spawn_app`. It needs to both set and
  return a random port for testing and return the `connection_pool` within
  `TestApp` for verifying side effects to the database. First we can split off
  returning the `connection_pool`:

  ```rs
  //! src/startup.rs
  use crate::configuration::{DatabaseSettings, Settings};

  pub async fn build(configuration: Settings) -> Result<Server, std::io::Error> {
      let connection_pool = get_connection_pool(&configuration.database);

      // [...]
  }

  pub fn get_connection_pool(configuration: &DatabaseSettings) -> PgPool {
      PgPoolOptions::new().connect_lazy_with(configuration.with_db())
  }
  ```

- For this to work, you need to add `#[derive(Clone)]` to all the structs in
  `src/configuration.rs`. It's a bit harder to get the application port, but we
  can wrap `actix_web::dev::Server` in a new type that holds the information.

  ```rs
  //! src/startup.rs
  // A new type to hold the newly built server and its port
  pub struct Application {
      port: u16,
      server: Server,
  }

  impl Application {
      // We have converted the `build` function into a constructor for `Application`
      pub async fn build(
          configuration: Settings,
      ) -> Result<Self, std::io::Error> {
          let connection_pool = get_connection_pool(&configuration.database);

          let sender_email = configuration
              .email_client
              .sender()
              .expect("Invalid sender email address.");
          let timeout = configuration.email_client.timeout();
          let email_client = EmailClient::new(
              configuration.email_client.base_url,
              sender_email,
              configuration.email_client.authorization_token,
              timeout,
          );

          let address = format!(
              "{}:{}",
              configuration.application.host, configuration.application.port,
          );
          let listener = TcpListener::bind(address)?;
          let port = listener.local_addr().unwrap().port();
          let server = run(listener, connection_pool, email_client)?;

          // We "save" the bound port in one of the `Application`'s fields
          Ok(Self { port, server })
      }

      pub fn port(&self) -> u16 {
          self.port
      }

      // A more expressive name that makes it clear that this function only
      // returns when the application is stopped.
      pub async fn run_until_stopped(self) -> Result<(), std::io::Error> {
          self.server.await
      }
  }

  //! tests/api/helpers.rs
  // [...]
  use zero2prod::startup::Application;

  pub async fn spawn_app() -> TestApp {
      Lazy::force(&TRACING);

      // Randomize configuration to ensure test isolation
      let configuration = {
          let mut c = get_configuration().expect("Failed to read configuration.");
          // Use a different database for each test case
          c.database.database_name = Uuid::new_v4().to_string();
          // Use a random OS port
          c.application.port = 0;
          c
      };

      // Create and migrate the database
      configure_database(&configuration.database).await;

      // Launch application as a background task
      let application = Application::build(configuration.clone())
          .await
          .expect("Failed to build application.");
      // Get the port before spawning the application
      let address = format!("http://127.0.0.1:{}", application.port());
      drop(tokio::spawn(application.run_until_stopped()));

      TestApp {
          address: address,
          db_pool: get_connection_pool(&configuration.database),
      }
  }

  //! src/main.rs
  use zero2prod::configuration::get_configuration;
  use zero2prod::startup::Application;
  use zero2prod::telemetry::{get_subscriber, init_subscriber};

  #[tokio::main]
  async fn main() -> Result<(), std::io::Error> {
      let subscriber =
          get_subscriber("zero2prod".into(), "info".into(), std::io::stdout);
      init_subscriber(subscriber);

      let configuration =
          get_configuration().expect("Failed to read configuration.");
      let application = Application::build(configuration).await?;
      application.run_until_stopped().await?;
      Ok(())
  }
  ```

- Note above that the two connection pools aren't the same, but they point to
  the same database so can still test for side effects.
- Our tests are a client for our API, but we want to be sure to not spread the
  routing logic all over the tests. We currently send a `POST` to
  `/subscriptions` in three places. So we will factor that logic out into a
  `post_subscriptions` method on our `TestApp`.

  ```rs
  //! tests/api/helpers.rs
  // [...]

  pub struct TestApp {
      pub address: String,
      pub db_pool: PgPool,
  }

  impl TestApp {
      pub async fn post_subscriptions(&self, body: String) -> reqwest::Response {
          reqwest::Client::new()
              .post(&format!("{}/subscriptions", &self.address))
              .header("Content-Type", "application/x-www-form-urlencoded")
              .body(body)
              .send()
              .await
              .expect("Failed to execute request.")
      }
  }

  //! tests/api/subscriptions.rs
  use crate::helpers::spawn_app;

  #[tokio::test]
  async fn subscribe_returns_a_200_for_valid_form_data() {
      // [...]
      // Act
      let body = "name=le%20guin&email=ursula_le_guin%40gmail.com";
      let response = app.post_subscriptions(body.into()).await;
      // [...]
  }

  #[tokio::test]
  async fn subscribe_returns_a_400_when_fields_are_present_but_invalid() {
      // [...]
      for (body, description) in test_cases {
          // Act
          let response = app.post_subscriptions(body.into()).await;
          // [...]
      }
  }

  #[tokio::test]
  async fn subscribe_returns_a_400_when_data_is_missing() {
      // [...]
      for (invalid_body, error_message) in test_cases {
          // Act
          let response = app.post_subscriptions(invalid_body.into()).await;
          // [...]
      }
  }
  ```

- We could add a method for `get_health_check` as well, but we only use it in
  one place.

### A Bit of Background on Deployments

- If you want to operate a highly available service, you should master **zero
  downtime deployments** - users should be able to use the service before,
  during and after the rollout of a new version of the application to
  production. This is even more important if you practice continuous deployment:
  you cannot release multiple times a day if every release triggers a small
  outage.
- When deploying our app, we deploy one or more app replicas behind a load
  balancer. This enables horizontal scaling - we can add more capacity when
  experiencing a traffic spike by spinning up more replicas of our application.
  It also enables health checks - either passive, where the load balancer looks
  at the distribution of status codes/latency for each backend to determine if
  they are healthy or not, or active, where the load balancer is configured to
  send a health check request to each backend on a schedule and if a backend
  fails to respond with a success status code for a long enough time period it
  is marked as unhealthy and removed/replaced. Health checks are critical for
  self-healing in a cloud-native environment: the platform can detect if an
  application is not behaving as expected and automatically remove it from the
  list of available backends to mitigate or nullify the impact on users as long
  as it is capable of automatically provisioning a new replica of the
  application when the number of healthy instances falls below a pre-determined
  threshold.
- Back to the topic of zero downtime deployments though, we can leverage our
  load balancer to perform zero downtime deployments! Assume we have three
  replicas of our application. When we want to deploy, we spin up another
  replica running the new version. When it is ready to serve requests, we have
  four replicas, so we can shutdown one running the old version and still have
  three. Repeat this until all three replicas are the new version. This
  deployment strategy is called **rolling update**: we run the old version and
  the new version of the application side by side, serving live traffic with
  both. Throughout the process we have at least three healthy backends as long
  as the new version is not buggy. Blue green and canary deployments are other
  popular strategies for rolling updates.
- Load balancing relies on a strong assumption: no matter what backend is used
  to serve an incoming request, the outcome will be the same. To ensure high
  availability in a fault-prone environment, cloud-native applications are
  **stateless** - they delegate all persistence to external systems. This is why
  load balancing works: all backends are talking to the same database to query
  and manipulate the same **state**. The database is like one big global
  variable that is continuously accessed and mutated by all replications of our
  application.
- During a rolling update, both the old version and new version using the same
  database at the same time. This doesn't matter for most updates, but is a
  serious constraint when we need to evolve the schema. We currently need to add
  a table and add a mandatory column to an existing table. If we do the
  migration before deploying the new version, we break all the old replicas that
  don't do inserts with the mandatory column. If we deploy the new version, it
  is broken because it is trying to insert a column that doesn't exist until we
  run our migration. So we cannot rolling update in this way without downtime.
- Instead of doing everything at once, we need multiple, smaller steps; or
  multi-step migrations. If we want to evolve the database schema, we cannot
  change the application behaviour at the same time. Consider adding the
  mandatory `status` column.
  1. Add as optional. Keep the application code stable and on the database side
     add the `status` column as a NULL-able field. The current application will
     work against this.

     ```sh
     $ sqlx migrate add add_status_to_subscriptions
     Creating migrations/20261122130950_add_status_to_subscriptions.sql
     ```

     ```sql
     ALTER TABLE subscriptions ADD COLUMN status TEXT NULL;
     ```

  2. Start using the new column. We modify our application so insert to always
     set the new field as `confirmed`. This can be deployed at the same time as
     the version of our application that doesn't fill in the field, so we can
     rolling update the application change.

     ```rs
     //! src/routes/subscriptions.rs
       sqlx::query!(
           r#"
           INSERT INTO subscriptions (id, email, name, subscribed_at, status)
           VALUES ($1, $2, $3, $4, 'confirmed')
           "#,
           Uuid::new_v4(),
           new_subscriber.email.as_ref(),
           new_subscriber.name.as_ref(),
           Utc::now(),
       )
     ```

  3. Backfill and mark as `NOT NULL`. Now that the latest version of the
     application is deployed and always filling in `status`, we can backfill the
     historical records and mark `status` as `NOT NULL`. Now we have added
     `status` as a mandatory column and can use it in code as we see fit.

     ```sh
     $ sqlx migrate add make_status_not_null_in_subscriptions
     Creating migrations/20261122131330_make_status_not_null_in_subscriptions.sql
     ```

     ```sql
     -- We wrap the whole migration in a transaction to make sure
     -- it succeeds or fails atomically. We will discuss SQL transactions
     -- in more details towards the end of this chapter!
     -- `sqlx` does not do it automatically for us.
     BEGIN;
         -- Backfill `status` for historical entries
         UPDATE subscriptions
             SET status = 'confirmed'
             WHERE status IS NULL;
         -- Make `status` mandatory
         ALTER TABLE subscriptions ALTER COLUMN status SET NOT NULL;
     COMMIT;
     ```

- What about adding the `subscription_tokens` table. That is much simpler. We
  add the table in a migration while the application ignores it. Then we can
  deploy a new version that uses it to enable confirmation emails.

  ```sh
  $ sqlx migrate add create_subscription_tokens_table
  Creating migrations/20261122131630_create_subscription_tokens_table.sql
  ```

  ```sql
  -- Create Subscription Tokens Table
  CREATE TABLE subscription_tokens(
      subscription_token TEXT NOT NULL,
      subscriber_id uuid NOT NULL
          REFERENCES subscriptions (id),
      PRIMARY KEY (subscription_token)
  );
  ```

- Remember, it's just `SKIP_DOCKER=true ./scripts/init_db.sh` to run those
  migrations locally!

### Back to Sending A Confirmation Email

- To test email, we need to spin up a mock server to stand in for Postmark's API
  and intercept outgoing requests. We are going to store this in an
  `email_server` field of `TestApp` so we don't have to spin up a custom mock
  per email test.

  ```rs
  //! tests/api/helpers.rs
  use wiremock::MockServer;

  pub struct TestApp {
      pub address: String,
      pub db_pool: PgPool,
      pub email_server: MockServer,
  }

  // Launch our application in the background
  // Also don't propagate errors in tests; just crash
  pub async fn spawn_app() -> TestApp {
      Lazy::force(&TRACING);
      // Launch a mock server to stand in for Postmark's API
      let email_server = MockServer::start().await;

      // Randomize configuration to ensure test isolation
      let configuration = {
          let mut c = get_configuration().expect("Failed to read configuration.");
          // Use a different database for each test case
          c.database.database_name = Uuid::new_v4().to_string();
          // Use a random OS port
          c.application.port = 0;
          // Use the mock server as email API
          c.email_client.base_url = email_server.uri();
          c
      };
      // [...]

      TestApp {
          address: address,
          db_pool: get_connection_pool(&configuration.database),
          email_server,
      }
  }
  ```

- So now we can write our first test of the new feature. We are starting simple.
  We will test that `POST /subscriptions` is sending out an email. At this stage
  we will make no assertions on the body of the email.

  ```rs
  //! tests/api/subscriptions.rs
  use crate::helpers::spawn_app;
  use wiremock::matchers::{method, path};
  use wiremock::{Mock, ResponseTemplate};
  // [...]

  #[tokio::test]
  async fn subscribe_sends_a_confirmation_email_for_valid_data() {
      // Arrange
      let app = spawn_app().await;
      let body = "name=le%20guin&email=ursula_le_guin%40gmail.com";

      Mock::given(path("/email"))
          .and(method("POST"))
          .respond_with(ResponseTemplate::new(200))
          .expect(1)
          .mount(&app.email_server)
          .await;

      // Act
      app.post_subscriptions(body.into()).await;

      // Assert
      // Mock asserts on drop
  }
  ```

- Step one complete! We have a failing test. Let's fix it. We will need an
  instance of `EmailClient`, but as you might recall, we registered it as part
  of the `App` context in an earlier refactor.

  ```rs
  //! src/routes/subscriptions.rs
  use crate::email_client::EmailClient;
  // [...]

  #[tracing::instrument(
      name = "Adding a new subscriber",
      skip(form, pool, email_client),
      fields(
          subscriber_email = %form.email,
          subscriber_name = %form.name,
      )
  )]
  pub async fn subscribe(
      form: web::Form<FormData>,
      pool: web::Data<PgPool>,
      email_client: web::Data<EmailClient>,
  ) -> HttpResponse {
      let new_subscriber = match form.0.try_into() {
          Ok(subscriber) => subscriber,
          Err(_) => return HttpResponse::BadRequest().finish(),
      };
      if insert_subscriber(&pool, &new_subscriber).await.is_err() {
          return HttpResponse::InternalServerError().finish();
      }
      // Send a (useless) email to the new subscriber.
      // We are ignoring email delivery errors for now.
      if email_client
          .send_email(
              new_subscriber.email,
              "Welcome!",
              "Welcome to our newsletter!",
              "Welcome to our newsletter!",
          )
          .await
          .is_err()
      {
          return HttpResponse::InternalServerError().finish();
      }
      HttpResponse::Ok().finish()
  }
  ```

- Now our new test passes because `subscribe` sends an email. But our old test,
  `subscribe_returns_a_200_for_valid_form_data` fails because it doesn't setup a
  mock so the email fails.

  ```rs
  //! tests/api/subscriptions.rs

  #[tokio::test]
  async fn subscribe_returns_a_200_for_valid_form_data() {
      // Arrange
      let app = spawn_app().await;
      let body = "name=le%20guin&email=ursula_le_guin%40gmail.com";
      Mock::given(path("/email"))
          .and(method("POST"))
          .respond_with(ResponseTemplate::new(200))
          .mount(&app.email_server)
          .await;

      // Act
      let response = app.post_subscriptions(body.into()).await;

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

- And we're back to green with nothing that requires refactoring, so it's a good
  time to add tests. This time, we will assert that the body of the email has a
  confirmation link. A `wiremock::MockServer` has a `received_requests` method
  that returns a vector of all the requests intercepted by the server as long as
  request recording was enabled (the default). We are also going to add a
  dependency to save us from some messy regular expressions to find links.

  ```toml
  #! Cargo.toml
  [dev-dependencies]
  linkify = "0.9"
  ```

  ```rs
  //! tests/api/subscriptions.rs

  #[tokio::test]
  async fn subscribe_sends_a_confirmation_email_with_a_link() {
      // Arrange
      let app = spawn_app().await;
      let body = "name=le%20guin&email=ursula_le_guin%40gmail.com";

      Mock::given(path("/email"))
          .and(method("POST"))
          .respond_with(ResponseTemplate::new(200))
          // We are no longer setting an expectation since this test is focused
          // on another aspect of the app behaviour.
          .mount(&app.email_server)
          .await;

      // Act
      app.post_subscriptions(body.into()).await;

      // Assert
      // Get the first intercepted request
      let email_request = &app.email_server.received_requests().await.unwrap()[0];
      // Parse the body as JSON, starting from raw bytes
      let body: serde_json::Value =
          serde_json::from_slice(&email_request.body).unwrap();

      // Extract the link from one of the request fields.
      let get_link = |s: &str| {
          let links: Vec<_> = linkify::LinkFinder::new()
              .links(s)
              .filter(|l| *l.kind() == linkify::LinkKind::Url)
              .collect();
          assert_eq!(links.len(), 1);
          links[0].as_str().to_owned()
      };

      let html_link = get_link(&body["HtmlBody"].as_str().unwrap());
      let text_link = get_link(&body["TextBody"].as_str().unwrap());
      // The two links should be identical
      assert_eq!(html_link, text_link);
  }
  ```

- And we can pass this with a bogus link.

  ```rs
  //! src/routes/subscriptions.rs
  // [...]

  #[tracing::instrument(
      name = "Adding a new subscriber",
      skip(form, pool, email_client),
      fields(
          subscriber_email = %form.email,
          subscriber_name = %form.name,
      )
  )]
  pub async fn subscribe(
      form: web::Form<FormData>,
      pool: web::Data<PgPool>,
      email_client: web::Data<EmailClient>,
  ) -> HttpResponse {
      let new_subscriber = match form.0.try_into() {
          Ok(subscriber) => subscriber,
          Err(_) => return HttpResponse::BadRequest().finish(),
      };
      if insert_subscriber(&pool, &new_subscriber).await.is_err() {
          return HttpResponse::InternalServerError().finish();
      }
      let confirmation_link =
          "https://there-is-no-such-domain.com/subscriptions/confirm";
      if email_client
          .send_email(
              new_subscriber.email,
              "Welcome!",
              &format!(
                  "Welcome to our newsletter!<br />\
                  Click <a href=\"{}\">here</a> to confirm your subscription.",
                  confirmation_link
              ),
              &format!(
                  "Welcome to our newsletter!\nVisit {} to confirm your subscription.",
                  confirmation_link
              ),
          )
          .await
          .is_err()
      {
          return HttpResponse::InternalServerError().finish();
      }
      HttpResponse::Ok().finish()
  }
  ```

- Now that we're green again, there is an obvious refactoring. Our `subscribe`
  handler is becoming cluttered with specifics of the confirmation email. We can
  factor that out to its own method.

  ```rs
  //! src/routes/subscriptions.rs
  // [...]

  #[tracing::instrument(
      name = "Adding a new subscriber",
      skip(form, pool, email_client),
      fields(
          subscriber_email = %form.email,
          subscriber_name = %form.name,
      )
  )]
  pub async fn subscribe(
      form: web::Form<FormData>,
      pool: web::Data<PgPool>,
      email_client: web::Data<EmailClient>,
  ) -> HttpResponse {
      let new_subscriber = match form.0.try_into() {
          Ok(subscriber) => subscriber,
          Err(_) => return HttpResponse::BadRequest().finish(),
      };
      if insert_subscriber(&pool, &new_subscriber).await.is_err() {
          return HttpResponse::InternalServerError().finish();
      }
      if send_confirmation_email(&email_client, new_subscriber)
          .await
          .is_err()
      {
          return HttpResponse::InternalServerError().finish();
      }
      HttpResponse::Ok().finish()
  }

  #[tracing::instrument(
      name = "Send a confirmation email to a new subscriber",
      skip(email_client, new_subscriber)
  )]
  pub async fn send_confirmation_email(
      email_client: &EmailClient,
      new_subscriber: NewSubscriber,
  ) -> Result<(), reqwest::Error> {
      let confirmation_link =
          "https://there-is-no-such-domain.com/subscriptions/confirm";
      let plain_body = format!(
          "Welcome to our newsletter!\nVisit {} to confirm your subscription.",
          confirmation_link
      );
      let html_body = format!(
          "Welcome to our newsletter!<br />\
          Click <a href=\"{}\">here</a> to confirm your subscription.",
          confirmation_link
      );
      email_client
          .send_email(new_subscriber.email, "Welcome!", &html_body, &plain_body)
          .await
  }
  ```

- We'll focus on the body of our confirmation email here shortly, but now is a
  good time to worry about our `status`. We're currently inserting `confirmed`
  for everybody, and now we have most of the scaffolding to send the
  confirmation email, we want to go ahead and make that start out pending. First
  we'll refactor our initial test:
  `subscribe_returns_a_200_for_valid_form_data`. It currently both checks the
  status of the request and performs some assertions against the `saved` values.

  ```rs
  //! tests/api/subscriptions.rs
  // BEFORE - doing two things
  #[tokio::test]
  async fn subscribe_returns_a_200_for_valid_form_data() {
      // Arrange
      let app = spawn_app().await;
      let body = "name=le%20guin&email=ursula_le_guin%40gmail.com";

      Mock::given(path("/email"))
          .and(method("POST"))
          .respond_with(ResponseTemplate::new(200))
          .mount(&app.email_server)
          .await;

      // Act
      let response = app.post_subscriptions(body.into()).await;

      // Assert
      assert_eq!(200, response.status().as_u16());

      let saved = sqlx::query!("SELECT email, name FROM subscriptions",)
          .fetch_one(&app.db_pool)
          .await
          .expect("Failed to fetch saved subscription.");

      assert_eq!(saved.email, "ursula_le_guin@gmail.com");
      assert_eq!(saved.name, "le guin");
  }

  // AFTER - two tests for separate concerns
  #[tokio::test]
  async fn subscribe_returns_a_200_for_valid_form_data() {
      // Arrange
      let app = spawn_app().await;
      let body = "name=le%20guin&email=ursula_le_guin%40gmail.com";

      Mock::given(path("/email"))
          .and(method("POST"))
          .respond_with(ResponseTemplate::new(200))
          .mount(&app.email_server)
          .await;

      // Act
      let response = app.post_subscriptions(body.into()).await;

      // Assert
      assert_eq!(200, response.status().as_u16());
  }

  #[tokio::test]
  async fn subscribe_persists_the_new_subscriber() {
      // Arrange
      let app = spawn_app().await;
      let body = "name=le%20guin&email=ursula_le_guin%40gmail.com";

      Mock::given(path("/email"))
          .and(method("POST"))
          .respond_with(ResponseTemplate::new(200))
          .mount(&app.email_server)
          .await;

      // Act
      app.post_subscriptions(body.into()).await;

      // Assert
      let saved = sqlx::query!("SELECT email, name FROM subscriptions",)
          .fetch_one(&app.db_pool)
          .await
          .expect("Failed to fetch saved subscription.");

      assert_eq!(saved.email, "ursula_le_guin@gmail.com");
      assert_eq!(saved.name, "le guin");
  }
  ```

- Now we can modify `subscribe_persists_the_new_subscriber` to actually check
  status.

  ```rs
  //! tests/api/subscriptions.rs
  // [...]

  #[tokio::test]
  async fn subscribe_persists_the_new_subscriber() {
      // [...]
      // Assert
      let saved = sqlx::query!("SELECT email, name, status FROM subscriptions",)
          .fetch_one(&app.db_pool)
          .await
          .expect("Failed to fetch saved subscription.");

      assert_eq!(saved.email, "ursula_le_guin@gmail.com");
      assert_eq!(saved.name, "le guin");
      assert_eq!(saved.status, "pending");
  }
  ```

  ```rs
  //! src/routes/subscriptions.rs
  // [...]
  #[tracing::instrument([...])]
  pub async fn insert_subscriber([...]) -> Result<(), sqlx::Error> {
      sqlx::query!(
          r#"
          INSERT INTO subscriptions (id, email, name, subscribed_at, status)
          VALUES ($1, $2, $3, $4, 'pending')
          "#,
          // [...]
      )
    // [...]
  }
  ```

- Now we're ready to start on our `GET /subscriptions/confirm` endpoint. We want
  a dedicated home for its tests.

  ```rs
  //! tests/api/main.rs

  mod health_check;
  mod helpers;
  mod subscriptions;
  mod subscriptions_confirm;

  //! tests/api/subscriptions_confirm.rs
  use crate::helpers::spawn_app;

  #[tokio::test]
  async fn confirmations_without_token_are_rejected_with_a_400() {
      // Arrange
      let app = spawn_app().await;

      // Act
      let response = reqwest::get(&format!("{}/subscriptions/confirm", app.address))
          .await
          .unwrap();

      // Assert
      assert_eq!(response.status().as_u16(), 400);
  }

  // At this point, our test is failing with a 404 instead of a 400.

  //! src/routes/mod.rs
  mod health_check;
  mod subscriptions;
  mod subscriptions_confirm;

  pub use health_check::*;
  pub use subscriptions::*;
  pub use subscriptions_confirm::*;

  //! src/routes/subscriptions_confirm.rs
  use actix_web::HttpResponse;

  #[tracing::instrument(
      name = "Confirm a pending subscriber",
  )]
  pub async fn confirm() -> HttpResponse {
      HttpResponse::Ok().finish()
  }

  //! src/startup.rs
  use crate::routes::{confirm, health_check, subscribe};

  pub fn run([...]) -> Result<Server, std::io::Error> {
      // [...]
      let server = HttpServer::new(move || {
          App::new()
              // Middlweares are added using the `wrap` method on `App`
              .wrap(TracingLogger::default())
              .route("/health_check", web::get().to(health_check))
              .route("/subscriptions", web::post().to(subscribe))
              .route("/subscriptions/confirm", web::get().to(confirm))
              .app_data(db_pool.clone())
              .app_data(email_client.clone())
      })
      .listen(listener)?
      .run();
      Ok(server)
  }

  // At this point, our test is failing with a 200 instead of a 400.

  //! src/routes/subscriptions_confirm.rs
  use actix_web::{HttpResponse, web};

  #[derive(serde::Deserialize)]
  pub struct Parameters {
      subscription_token: String,
  }

  #[tracing::instrument(
      name = "Confirm a pending subscriber",
      skip(_parameters),
  )]
  pub async fn confirm(_parameters: web::Query<Parameters>) -> HttpResponse {
      HttpResponse::Ok().finish()
  }

  // Now our test passes! We are returning a 400, because the extractor is
  // failing to extract the `subscription_token`.
  ```

- Now we can send an email and we have a link to accept the parameter, so we can
  wire up the full journey.

  ```rs
  //! tests/api/subscriptions_confirm.rs
  use crate::helpers::spawn_app;
  use reqwest::Url;
  use wiremock::{ResponseTemplate, Mock};
  use wiremock::matchers::{path, method};

  #[tokio::test]
  async fn the_link_returned_by_subscribe_returns_a_200_if_called() {
      // Arrange
      let app = spawn_app().await;
      let body = "name=le%20guin&email=ursula_le_guin%40gmail.com";

      Mock::given(path("/email"))
          .and(method("POST"))
          .respond_with(ResponseTemplate::new(200))
          .mount(&app.email_server)
          .await;

      app.post_subscriptions(body.into()).await;
      let email_request = &app.email_server.received_requests().await.unwrap()[0];
      let body: serde_json::Value = serde_json::from_slice(&email_request.body)
          .unwrap();

      // Extract the link from one of the request fields.
      let get_link = |s: &str| {
          let links: Vec<_> = linkify::LinkFinder::new()
              .links(s)
              .filter(|l| *l.kind() == linkify::LinkKind::Url)
              .collect();
          assert_eq!(links.len(), 1);
          links[0].as_str().to_owned()
      };
      let raw_confirmation_link = &get_link(&body["HtmlBody"].as_str().unwrap());
      let confirmation_link = Url::parse(raw_confirmation_link).unwrap();
      // Let's make sure we don't call random APIs on the web
      assert_eq!(confirmation_link.host_str().unwrap(), "127.0.0.1");

      // Act
      let response = reqwest::get(confirmation_link)
          .await
          .unwrap();

      // Assert
      assert_eq!(response.status().as_u16(), 200);
  }
  ```

- Feel the pain of code duplication! We'll go back and refactor later after the
  test is green. Right now we have a fairly simple failure.
  `"there-is-no-such-domain.com"` does not match `"127.0.0.1"`. We knew that
  hardcoded value wasn't meant to last. Really, the host for the confirmation
  link is going to vary by environment, so we should pass the domain as a
  configuration value.

  ```yaml
  #! configuration/local.yaml
  application:
    host: 127.0.0.1
    base_url: "http://127.0.0.1"
  database:
    require_ssl: false
  ```

  ```rs
  //! src/configuration.rs
  // [...]

  #[derive(serde::Deserialize, Clone)]
  pub struct ApplicationSettings {
      #[serde(deserialize_with = "deserialize_number_from_string")]
      pub port: u16,
      pub host: String,
      pub base_url: String,
  }

  //! src/startup.rs
  // [...]

  impl Application {
      pub async fn build(configuration: Settings) -> Result<Self, std::io::Error> {
          // [...]
          let server = run(
              listener,
              connection_pool,
              email_client,
              configuration.application.base_url,
          )?;

          Ok(Self { port, server })
      }
      // [...]
  }

  // We need to define a wrapper type in order to retrieve the URL
  // in the `subscribe` handler.
  // Retrieval from the context, in actix-web, is type-based so using a raw
  // `String` would expose us to conflicts.
  pub struct ApplicationBaseUrl(pub String);

  pub fn run(
      listener: TcpListener,
      connection_pool: PgPool,
      email_client: EmailClient,
      base_url: String,
  ) -> Result<Server, std::io::Error> {
      // Wrap the connection in a smart pointer
      let db_pool = Data::new(connection_pool);
      let email_client = Data::new(email_client);
      let base_url = Data::new(ApplicationBaseUrl(base_url));
      // Capture `connection` from the surrounding environment
      let server = HttpServer::new(move || {
          App::new()
              // Middlweares are added using the `wrap` method on `App`
              .wrap(TracingLogger::default())
              .route("/health_check", web::get().to(health_check))
              .route("/subscriptions", web::post().to(subscribe))
              .route("/subscriptions/confirm", web::get().to(confirm))
              .app_data(db_pool.clone())
              .app_data(email_client.clone())
              .app_data(base_url.clone())
      })
      .listen(listener)?
      .run();
      Ok(server)
  }

  //! src/routes/subscriptions.rs
  use crate::startup::ApplicationBaseUrl;
  // [...]
  #[tracing::instrument(
      name = "Adding a new subscriber",
      skip(form, pool, email_client, base_url),
      fields(
          subscriber_email = %form.email,
          subscriber_name = %form.name,
      )
  )]
  pub async fn subscribe(
      form: web::Form<FormData>,
      pool: web::Data<PgPool>,
      email_client: web::Data<EmailClient>,
      base_url: web::Data<ApplicationBaseUrl>,
  ) -> HttpResponse {
      // [...]
      if send_confirmation_email(&email_client, new_subscriber, &base_url.0)
          .await
          .is_err()
      {
          return HttpResponse::InternalServerError().finish();
      }
      HttpResponse::Ok().finish()
  }

  #[tracing::instrument(
      name = "Send a confirmation email to a new subscriber",
      skip(email_client, new_subscriber, base_url)
  )]
  pub async fn send_confirmation_email(
      email_client: &EmailClient,
      new_subscriber: NewSubscriber,
      base_url: &str,
  ) -> Result<(), reqwest::Error> {
      let confirmation_link = format!("{}/subscriptions/confirm", base_url);
      // [...]
  }
  ```

- After all that effort, our test fails because it is making the request to
  port 80. We don't actually know the port in the test environment since it is
  random. The easiest way to have that when we need it is to attach it to
  `TestApp`. It's a bit of a hack, but we are going to fix the tests to use the
  correct random port rather than fix the link to point to the right port in
  tests. It works around the fact that we couldn't hardcode a random port into
  the URL.

  ```rs
  //! tests/api/helpers.rs
  // [...]
  pub struct TestApp {
      pub address: String,
      pub port: u16,
      pub db_pool: PgPool,
      pub email_server: MockServer,
  }

  pub async fn spawn_app() -> TestApp {
      // [...]

      let application = Application::build(configuration.clone())
          .await
          .expect("Failed to build application.");
      let application_port = application.port();
      // Get the port before spawning the application
      let address = format!("http://localhost:{}", application.port());
      drop(tokio::spawn(application.run_until_stopped()));

      TestApp {
          address,
          port: application_port,
          db_pool: get_connection_pool(&configuration.database),
          email_server,
      }
  }

  //! tests/api/subscriptions_confirm.rs
  // [...]

  async fn the_link_returned_by_subscribe_returns_a_200_if_called() {
      // [...]
      let mut confirmation_link = Url::parse(raw_confirmation_link).unwrap();
      // Let's make sure we don't call random APIs on the web
      assert_eq!(confirmation_link.host_str().unwrap(), "127.0.0.1");
      // Now we rewrite the URL to include the correct port
      confirmation_link.set_port(Some(app.port)).unwrap();
      // [...]
  }
  ```

- We're getting a 400 because we don't include a token, so for now we'll
  hardcode it in and do some refactoring with green tests.

  ```rs
  //! src/routes/subscriptions.rs
  // [...]

  pub async fn send_confirmation_email([...]) -> Result<(), reqwest::Error> {
      let confirmation_link = format!(
          "{}/subscriptions/confirm?subscription_token=mytoken",
          base_url
      );
      // [...]
  ```

- Alright, we clearly duplicated the logic to extract links and will likely need
  that logic other places as well, so let's extract it to its own helper
  function.

  ```rs
  //! tests/api/helpers.rs
  // [...]

  /// Confirmation links embedded in the request to the email API.
  pub struct ConfirmationLinks {
      pub html: reqwest::Url,
      pub plain_text: reqwest::Url,
  }

  impl TestApp {
      // [...]

      /// Extract the confirmation links embedded in the request to the email API.
      pub fn get_confirmation_links(
          &self,
          email_request: &wiremock::Request,
      ) -> ConfirmationLinks {
          let body: serde_json::Value = serde_json::from_slice(
              &email_request.body
          ).unwrap();

          // Extract the link from one of the request fields.
          let get_link = |s: &str| {
              let links: Vec<_> = linkify::LinkFinder::new()
                  .links(s)
                  .filter(|l| *l.kind() == linkify::LinkKind::Url)
                  .collect();
              assert_eq!(links.len(), 1);
              let raw_link = links[0].as_str().to_owned();
              let mut confirmation_link = reqwest::Url::parse(&raw_link).unwrap();
              assert_eq!(confirmation_link.host_str().unwrap(), "127.0.0.1");
              confirmation_link.set_port(Some(self.port)).unwrap();
              confirmation_link
          };

          let html = get_link(body["HtmlBody"].as_str().unwrap());
          let plain_text = get_link(body["TextBody"].as_str().unwrap());

          ConfirmationLinks {
              html,
              plain_text,
          }
      }
  }

  //! tests/api/subscriptions.rs
  // [...]

  #[tokio::test]
  async fn subscribe_sends_a_confirmation_email_with_a_link() {
      // Arrange
      let app = spawn_app().await;
      let body = "name=le%20guin&email=ursula_le_guin%40gmail.com";

      Mock::given(path("/email"))
          .and(method("POST"))
          .respond_with(ResponseTemplate::new(200))
          // We are no longer setting an expectation since this test is focused
          // on another aspect of the app behaviour.
          .mount(&app.email_server)
          .await;

      // Act
      app.post_subscriptions(body.into()).await;

      // Assert
      let email_request = &app.email_server.received_requests().await.unwrap()[0];
      let confirmation_links = app.get_confirmation_links(email_request);

      assert_eq!(confirmation_links.html, confirmation_links.plain_text);
  }

  //! tests/api/subscriptions_confirm.rs
  // [...]

  #[tokio::test]
  async fn the_link_returned_by_subscribe_returns_a_200_if_called() {
      // Arrange
      let app = spawn_app().await;
      let body = "name=le%20guin&email=ursula_le_guin%40gmail.com";

      Mock::given(path("/email"))
          .and(method("POST"))
          .respond_with(ResponseTemplate::new(200))
          .mount(&app.email_server)
          .await;

      app.post_subscriptions(body.into()).await;
      let email_request = &app.email_server.received_requests().await.unwrap()[0];
      let confirmation_links = app.get_confirmation_links(email_request);

      let response = reqwest::get(confirmation_links.html).await.unwrap();

      // Assert
      assert_eq!(response.status().as_u16(), 200);
  }
  ```

- The intent of those two tests is much clearer now. Next we can generate actual
  subscription tokens.

  ```rs
  //! tests/api/subscriptions_confirm.rs
  // [...]

  #[tokio::test]
  async fn clicking_on_the_confirmation_link_confirms_a_subscriber() {
      // Arrange
      let app = spawn_app().await;
      let body = "name=le%20guin&email=ursula_le_guin%40gmail.com";

      Mock::given(path("/email"))
          .and(method("POST"))
          .respond_with(ResponseTemplate::new(200))
          .mount(&app.email_server)
          .await;

      app.post_subscriptions(body.into()).await;
      let email_request = &app.email_server.received_requests().await.unwrap()[0];
      let confirmation_links = app.get_confirmation_links(email_request);

      // Act
      reqwest::get(confirmation_links.html)
          .await
          .unwrap()
          .error_for_status()
          .unwrap();

      // Assert
      let saved = sqlx::query!("SELECT email, name, status FROM subscriptions",)
          .fetch_one(&app.db_pool)
          .await
          .expect("Failed to fetch saved subscription.");

      assert_eq!(saved.email, "ursula_le_guin@gmail.com");
      assert_eq!(saved.name, "le guin");
      assert_eq!(saved.status, "confirmed");
  }

  // Failing with status "pending" not "confirmed".

  //! src/routes/subscriptions.rs
  // [...]

  #[tracing::instrument([...])]
  pub async fn subscribe([...]) -> HttpResponse {
      // [...]
      if send_confirmation_email(
          &email_client,
          new_subscriber,
          &base_url.0,
          "mytoken",
      )
      .await
      .is_err()
      {
          return HttpResponse::InternalServerError().finish();
      }
      HttpResponse::Ok().finish()
  }

  #[tracing::instrument(
      name = "Send a confirmation email to a new subscriber",
      skip(email_client, new_subscriber, base_url, subscription_token)
  )]
  pub async fn send_confirmation_email(
      email_client: &EmailClient,
      new_subscriber: NewSubscriber,
      base_url: &str,
      subscription_token: &str,
  ) -> Result<(), reqwest::Error> {
      let confirmation_link = format!(
          "{}/subscriptions/confirm?subscription_token={}",
          base_url, subscription_token,
      );
      let plain_body = format!(
          "Welcome to our newsletter!\nVisit {} to confirm your subscription.",
          confirmation_link
      );
      let html_body = format!(
          "Welcome to our newsletter!<br />\
          Click <a href=\"{}\">here</a> to confirm your subscription.",
          confirmation_link
      );
      email_client
          .send_email(new_subscriber.email, "Welcome!", &html_body, &plain_body)
          .await
  }
  ```

- So we can pass a token, we need to generate a token. For our token, we will
  use a cryptographically secure pseudo-random number generator (CSPRNG). For
  this, we need to wire in `rand` as a dependency.

  ```toml
  #! Cargo.toml
  [dependencies]
  rand = { version = "0.8", features=["std_rng"] }
  ```

  ```rs
  //! src/routes/subscriptions.rs
  use rand::distributions::Alphanumeric;
  use rand::{thread_rng, Rng};

  /// Generate a random 25-characters-long case-sensitive subscription token.
  fn generate_subscription_token() -> String {
      let mut rng = thread_rng();
      std::iter::repeat_with(|| rng.sample(Alphanumeric))
          .map(char::from)
          .take(25)
          .collect()
  }
  ```

- Now we added a `subscription_tokens` table, but it takes the token and the
  `subscriber_id`, so we need to return `subscriber_id` from
  `insert_subscriber`.

  ```rs
  //! src/routes/subscriptions.rs
  // [...]

  #[tracing::instrument(
      name = "Saving new subscriber details in the database",
      skip(new_subscriber, pool)
  )]
  pub async fn insert_subscriber(
      pool: &PgPool,
      new_subscriber: &NewSubscriber,
  ) -> Result<Uuid, sqlx::Error> {
      let subscriber_id = Uuid::new_v4();
      sqlx::query!(
          r#"
          INSERT INTO subscriptions (id, email, name, subscribed_at, status)
          VALUES ($1, $2, $3, $4, 'pending')
          "#,
          subscriber_id,
          new_subscriber.email.as_ref(),
          new_subscriber.name.as_ref(),
          Utc::now(),
      )
      .execute(pool)
      .await
      .map_err(|e| {
          tracing::error!("Failed to execute query: {:?}", e);
          e
      })?;
      Ok(subscriber_id)
  }

  // Then we wire it all up

  //! src/routes/subscriptions.rs
  // [...]
  #[tracing::instrument(
      name = "Adding a new subscriber",
      skip(form, pool, email_client, base_url),
      fields(
          subscriber_email = %form.email,
          subscriber_name = %form.name,
      )
  )]
  pub async fn subscribe(
      form: web::Form<FormData>,
      pool: web::Data<PgPool>,
      email_client: web::Data<EmailClient>,
      base_url: web::Data<ApplicationBaseUrl>,
  ) -> HttpResponse {
      let new_subscriber = match form.0.try_into() {
          Ok(subscriber) => subscriber,
          Err(_) => return HttpResponse::BadRequest().finish(),
      };
      let subscriber_id = match insert_subscriber(&pool, &new_subscriber).await {
          Ok(subscriber_id) => subscriber_id,
          Err(_) => return HttpResponse::InternalServerError().finish(),
      };
      let subscription_token = generate_subscription_token();
      if store_token(&pool, subscriber_id, &subscription_token)
          .await
          .is_err()
      {
          return HttpResponse::InternalServerError().finish();
      }
      if send_confirmation_email(
          &email_client,
          new_subscriber,
          &base_url.0,
          &subscription_token,
      )
      .await
      .is_err()
      {
          return HttpResponse::InternalServerError().finish();
      }
      HttpResponse::Ok().finish()
  }

  #[tracing::instrument(
      name = "Store subscription token in the database",
      skip(subscription_token, pool)
  )]
  pub async fn store_token(
      pool: &PgPool,
      subscriber_id: Uuid,
      subscription_token: &str,
  ) -> Result<(), sqlx::Error> {
      sqlx::query!(
          r#"INSERT INTO subscription_tokens (subscription_token, subscriber_id)
          VALUES ($1, $2)"#,
          subscription_token,
          subscriber_id
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

- And with that our tests are green! But we have a rather big problem to take
  into account. Our `POST /subscriptions` handler is performing two `INSERT`
  queries. What if the application crashes between the two operations. Even as
  simple as our app is now, after running `POST /subscriptions` we could be in
  one of three possible states:
  - a new subscriber and its token have been persisted;
  - a new subscriber has been persisted, without a token;
  - nothing has been persisted.
- The more queries you have, the worse it gets to reason about the possible
  states of the database. We can solve this with **transactions**. If we wrap
  our two inserts in a single transaction, we have two possible end states:
  - a new subscriber and its token have been persisted;
  - nothing has been persisted.
- You don't need to manually send `BEGIN` and `COMMIT` to start and end
  transactions with `sqlx`. You call `begin` on your connection pool and it
  returns an `Ok(transaction)` or an `Err`:

  ```rs
  //! src/routes/subscriptions.rs
  // [...]

  pub async fn subscribe([...]) -> HttpResponse {
      let new_subscriber = // [...]
      let mut transaction = match pool.begin().await {
          Ok(transaction) => transaction,
          Err(_) => return HttpResponse::InternalServerError().finish(),
      };
      // [...]
  }
  ```

- A mutable reference to `Transaction` dereferences to `sqlx`'s `Connection` so
  it can be used to run queries. All queries run using a `Transaction` as
  executor become part of the transaction.

  ```rs
  //! src/routes/subscriptions.rs
  use sqlx::{Executor, PgPool, Postgres, Transaction};
  // [...]

  #[tracing::instrument([...])]
  pub async fn subscribe([...]) -> HttpResponse {
      let new_subscriber = // [...]
      let mut transaction = match pool.begin().await {
          Ok(transaction) => transaction,
          Err(_) => return HttpResponse::InternalServerError().finish(),
      };
      let subscriber_id =
          match insert_subscriber(&mut transaction, &new_subscriber).await {
              Ok(subscriber_id) => subscriber_id,
              Err(_) => return HttpResponse::InternalServerError().finish(),
          };
      let subscription_token = generate_subscription_token();
      if store_token(&mut transaction, subscriber_id, &subscription_token)
          .await
          .is_err()
      {
          return HttpResponse::InternalServerError().finish();
      }
  }

  #[tracing::instrument(
      name = "Saving new subscriber details in the database",
      skip(new_subscriber, transaction)
  )]
  pub async fn insert_subscriber(
      transaction: &mut Transaction<'_, Postgres>,
      new_subscriber: &NewSubscriber,
  ) -> Result<Uuid, sqlx::Error> {
      let subscriber_id = Uuid::new_v4();
      let query = sqlx::query!(
          r#"INSERT INTO subscriptions (id, email, name, subscribed_at, status)
          VALUES ($1, $2, $3, $4, 'pending')"#,
          subscriber_id,
          new_subscriber.email.as_ref(),
          new_subscriber.name.as_ref(),
          Utc::now(),
      );
      transaction.execute(query).await.map_err(|e| {
          tracing::error!("Failed to execute query: {:?}", e);
          e
      })?;
      Ok(subscriber_id)
  }

  #[tracing::instrument(
      name = "Store subscription token in the database",
      skip(subscription_token, transaction)
  )]
  pub async fn store_token(
      transaction: &mut Transaction<'_, Postgres>,
      subscriber_id: Uuid,
      subscription_token: &str,
  ) -> Result<(), sqlx::Error> {
      let query = sqlx::query!(
          r#"INSERT INTO subscription_tokens (subscription_token, subscriber_id)
          VALUES ($1, $2)"#,
          subscription_token,
          subscriber_id
      );
      transaction.execute(query).await.map_err(|e| {
          tracing::error!("Failed to execute query: {:?}", e);
          e
      })?;
      Ok(())
  }
  ```

- But some of our tests are failing now because we never called
  `Transaction::commit`. The transaction exposes `Transaction::commit` and
  `Transaction::rollback`. Since we call neither, the `Transaction` is rolled
  back by its `Drop` implementation when neither is called.

  ```rs
  //! src/routes/subscriptions.rs
  // [...]

  #[tracing::instrument([...])]
  pub async fn subscribe([...]) -> HttpResponse {
      let new_subscriber = // [...]
      let mut transaction = match pool.begin().await {
          Ok(transaction) => transaction,
          Err(_) => return HttpResponse::InternalServerError().finish(),
      };
      let subscriber_id =
          match insert_subscriber(&mut transaction, &new_subscriber).await {
              Ok(subscriber_id) => subscriber_id,
              Err(_) => return HttpResponse::InternalServerError().finish(),
          };
      let subscription_token = generate_subscription_token();
      if store_token(&mut transaction, subscriber_id, &subscription_token)
          .await
          .is_err()
      {
          return HttpResponse::InternalServerError().finish();
      }
      if transaction.commit().await.is_err() {
          return HttpResponse::InternalServerError().finish();
      }
      // [...]
  }
  ```

- As the chapter closes, the book recommends several ways you could improve what
  we built so far:
  - What happens if a user tries to subscribe twice? Make sure that they receive
    two confirmation emails;
  - What happens if a user clicks on a confirmation link twice?
  - What happens if the subscription token is well-formatted but non-existent?
  - Add validation on the incoming token, we are currently passing the raw user
    input straight into a query (thanks sqlx for protecting us from SQL
    injections <3);
  - Use a proper templating solution for our emails (e.g. tera);

## Chapter 8 - Error Handling

- Let's write an exploratory test to see how we're currently handling database
  errors in practice.

  ```rs
  //! tests/api/subscriptions.rs
  // [...]

  #[tokio::test]
  async fn subscribe_fails_if_there_is_a_fatal_database_error() {
      // Arrange
      let app = spawn_app().await;
      let body = "name=le%20guin&email=ursula_le_guin%40gmail.com";
      // Sabotage the database
      sqlx::query!(
          "ALTER TABLE subscription_tokens DROP COLUMN subscription_token;",
      )
      .execute(&app.db_pool)
      .await
      .unwrap();

      // Act
      let response = app.post_subscriptions(body.into()).await;

      // Assert
      assert_eq!(response.status().as_u16(), 500);
  }
  ```

- The test passes right away, but let's run it with logging enabled to see what
  we would have to trace this even if it really happened.

  ```sh
  # sqlx logs are a bit spammy, cutting them out to reduce noise
  $ export RUST_LOG="sqlx=error,info"
  $ export TEST_LOG=true
  $ cargo t subscribe_fails_if_there_is_a_fatal_database_error | bunyan

  # Output trimmed of extra information...
  INFO: [HTTP REQUEST - START]
  INFO: [ADDING A NEW SUBSCRIBER - START]
  INFO: [SAVING NEW SUBSCRIBER DETAILS IN THE DATABASE - START]
  INFO: [SAVING NEW SUBSCRIBER DETAILS IN THE DATABASE - END]
  INFO: [STORE SUBSCRIPTION TOKEN IN THE DATABASE - START]
  ERROR: [STORE SUBSCRIPTION TOKEN IN THE DATABASE - EVENT] Failed to execute query:
      Database(PgDatabaseError {
        severity: Error,
        code: "42703",
        message:
          "column 'subscription_token' of relation
          'subscription_tokens' does not exist",
        ...
      })
    target=zero2prod::routes::subscriptions
  INFO: [STORE SUBSCRIPTION TOKEN IN THE DATABASE - END]
  INFO: [ADDING A NEW SUBSCRIBER - END]
  INFO: [HTTP REQUEST - END]
    exception.details="",
    exception.message="",
    target=tracing_actix_web::root_span_builder,
    http.status_code=500
  ```

- As it stands, we are left to infer that the 500 is related to the database
  column error. Sure they happened in the same request as you can tell from the
  request*id (not provided here), but the 500 doesn't directly report its root
  cause. This is actually currently one of our better instances of handling
  errors since it is actually using `tracing::error` to log a message. Most of
  our processes map `Err(*)`to`400`or`500`without extra logging. The breakdown
  is actually here where we check`is_err`and discard the context mapping
  the`Err`to an`InternalServerError`.

  ```rs
  //! src/routes/subscriptions.rs
  // [...]
  pub async fn subscribe(/* */) -> HttpResponse {
      // [...]
      if store_token(&mut transaction, subscriber_id, &subscription_token)
          .await
          .is_err()
      {
          return HttpResponse::InternalServerError().finish();
      }
      // [...]
  }

  pub async fn store_token(/* */) -> Result<(), sqlx::Error> {
      let query = sqlx::query!(/* */);
      transaction.execute(query)
          .await
          .map_err(|e| {
              tracing::error!("Failed to execute query: {:?}", e);
              e
          })?;
      // [...]
  }
  ```

- We currently aren't properly leveraging `actix_web::Error` to carry errors
  through the system. `From<T>` is implemented for `actix_web::Error` for any
  `T: ResponseError`. `ResponseError` has two methods, `status_code(&self)` and
  `error_response(&self)`, both with default implementations to return an
  internal server error. So we really just need to import
  `actix_web::ResponseError` and implement it for our types. We cannot simply
  implement `ResponseError` for `sqlx::Error` due to the orphan rule, and we
  aren't sure we want to handle every `sqlx::Error` the same way anyway, so the
  answer is to wrap `sqlx::Error` in a type and implement `ResponseError` for
  that type. `ResponseError` requires that types implementing it implement both
  `fmt::Debug` and `fmt::Display`.

  ```rs
  //! src/routes/subscriptions.rs
  use actix_web::{HttpResponse, ResponseError, web};

  pub async fn store_token(/* */) -> Result<(), StoreTokenError> {
      let query = sqlx::query!(/* */);
      transaction.execute(query)
          .await
          .map_err(|e| {
              // [...]
              // Wrapping the underlying error
              StoreTokenError(e)
          })?;
      // [...]
  }

  // A new error type, wrapping a sqlx::Error
  #[derive(Debug)]
  pub struct StoreTokenError(sqlx::Error);

  impl ResponseError for StoreTokenError {}

  impl std::fmt::Display for StoreTokenError {
      fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
          write!(
              f,
              "A database error was encountered while \
              trying to store a subscription token."
          )
      }
  }

  //! src/routes/subscriptions.rs
  // [...]

  pub async fn subscribe(/* */) -> Result<HttpResponse, actix_web::Error> {
      // You will have to wrap (early) returns in `Ok(...)` as well!
      // [...]
      // The `?` operator transparently invokes the `Into` trait
      // on our behalf - we don't need an explicit `map_err` anymore.
      store_token(/* */).await?;
      // [...]
  }
  ```

- Now if we run the tests again, the final 500 error contains the context.

  ```sh
  # Some irrelevant details removed.
  [2026-11-23T11:55:03.071Z]
  INFO: test/48935 on Lambda-Air: [HTTP REQUEST - END]
    http.client_ip=127.0.0.1
    http.host=localhost:58240
    http.method=POST
    http.route=/subscriptions
    http.scheme=http
    http.status_code=500
    http.target=/subscriptions
    http.user_agent=""
    otel.kind=server
    otel.name="POST /subscriptions"
    otel.status_code=ERROR
    request_id=8776785a-f70e-437c-801b-d21a72e5f9ec
    target=tracing_actix_web::root_span_builder)
    exception.details: StoreTokenError(
        Database(
            PgDatabaseError {
                severity: Error,
                code: "42703",
                message:
                    "column \"subscription_token\" of relation
                    \"subscription_tokens\" does not exist",
                ...
    --
    exception.message:
        A database error was encountered while trying to store a subscription token.
  ```

- But the goal is accomplished. The underlying exception is attached to our 500
  and appears in the same logging message. However, the fact we had to wrap no
  less than 5 calls to `HttpResponse::InternalServerError()` shows we have a lot
  of work left to do.
- Aside from the specifics of `actix_web::Error`, Rust has an `Error` trait in
  the standard library. It specifies that an error should provide `Debug` and
  `Display` implementations and that it should be possible to look at the
  underlying cause with `source`. More importantly, it semantically marks our
  type as being an error. We can implement `Error` for `StoreTokenError`. We can
  also use this opportunity to make the `Debug` implementation specifically call
  out the cause rather than rely on the `derive`.

  ```rs
  pub trait Error: Debug + Display {
      /// The lower-level source of this error, if any.
      fn source(&self) -> Option<&(dyn Error + 'static)> {
          None
      }
  }

  //! src/routes/subscriptions.rs
  // [...]

  // Remove the #[derive(Debug)]
  pub struct StoreTokenError(sqlx::Error)

  impl std::error::Error for StoreTokenError {
      fn source(&self) -> Option<&(dyn std::error::Error + 'static)> {
          // The compiler transparently casts `&sqlx::Error` into `&dyn Error`
          Some(&self.0)
      }
  }
  ```

- The new `Debug` output improves our logging message and leaves nothing to the
  imagination.

  ```sh
  ...
  INFO: [HTTP REQUEST - END]
  exception.details=
      "A database failure was encountered
      while trying to store a subscription token.

      Caused by:
      error returned from database: column 'subscription_token'
      of relation 'subscription_tokens' does not exist"
  exception.message=
      "A database failure was encountered while
      trying to store a subscription token.",
  target=tracing_actix_web::root_span_builder,
  http.status_code=500
  ```

- As we are likely doing this again, let's write a helper function,
  `error_chain_fmt`, that uses the `Error` methods to walk the chain and provide
  a `Debug` output like this.

  ```rs
  fn error_chain_fmt(
      e: &impl std::error::Error,
      f: &mut std::fmt::Formatter<'_>,
  ) -> std::fmt::Result {
      writeln!(f, "{}\n", e)?;
      let mut current = e.source();
      while let Some(cause) = current {
          writeln!(f, "Caused by:\n\t{}", cause)?;
          current = cause.source();
      }
      Ok(())
  }

  impl std::fmt::Debug for StoreTokenError {
      fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
          error_chain_fmt(self, f)
      }
  }
  ```

- Although this works, we've introduced an unnecessary coupling. We implemented
  a trait of our web framework for a low level error that could otherwise be
  used from a different entrypoint such as the CLI. So we are going to delete
  the `ResponseError` implementation for `store_token` and introduce a
  `SubscribeError` higher up, since `subscribe` is an actual HTTP handler that
  should be concerned with HTTP-related logic.

  ```rs
  //! src/routes/subscriptions.rs
  // [...]

  pub async fn subscribe(/* */) -> Result<HttpResponse, SubscribeError> {
      // [...]
  }

  #[derive(Debug)]
  struct SubscribeError {}

  impl std::fmt::Display for SubscribeError {
      fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
          write!(f, "Failed to create a new subscriber.")
      }
  }

  impl std::error::Error for SubscribeError {}

  impl ResponseError for SubscribeError {}
  ```

- This doesn't quite compile yet. We need to implement conversions between our
  error types. But first we'll refactor our `SubscribeError` to an `enum` to
  represent different error conditions.

  ```rs
  #[derive(Debug)]
  pub enum SubscribeError {
      ValidationError(String),
      DatabaseError(sqlx::Error),
      StoreTokenError(StoreTokenError),
      SendEmailError(reqwest::Error),
  }

  impl From<reqwest::Error> for SubscribeError {
      fn from(e: reqwest::Error) -> Self {
          Self::SendEmailError(e)
      }
  }

  impl From<sqlx::Error> for SubscribeError {
      fn from(e: sqlx::Error) -> Self {
          Self::DatabaseError(e)
      }
  }

  impl From<StoreTokenError> for SubscribeError {
      fn from(e: StoreTokenError) -> Self {
          Self::StoreTokenError(e)
      }
  }

  impl From<String> for SubscribeError {
      fn from(e: String) -> Self {
          Self::ValidationError(e)
      }
  }

  // With this, we can cleanup our original function at all error sites!
  // We have significantly simplified our `subscribe` function and made
  // its intent clear.
  #[tracing::instrument(/* */)]
  pub async fn subscribe(
      form: web::Form<FormData>,
      pool: web::Data<PgPool>,
      email_client: web::Data<EmailClient>,
      base_url: web::Data<ApplicationBaseUrl>,
  ) -> Result<HttpResponse, SubscribeError> {
      let new_subscriber = form.0.try_into()?;
      let mut transaction = pool.begin().await?;
      let subscriber_id =
          insert_subscriber(&mut transaction, &new_subscriber).await?;
      let subscription_token = generate_subscription_token();
      store_token(&mut transaction, subscriber_id, &subscription_token).await?;
      transaction.commit().await?;
      send_confirmation_email(
          &email_client,
          new_subscriber,
          &base_url.0,
          &subscription_token,
      )
      .await?;
      Ok(HttpResponse::Ok().finish())
  }
  ```

- But our test suite catches us. We are currently returning 500 across the
  board, when previously we returned a 400 for empty name. We can customize
  `status_code` for our enum.

  ```rs
  //! src/routes/subscriptions.rs
  use actix_web::{HttpResponse, ResponseError, web, http::StatusCode};

  impl ResponseError for SubscribeError {
      fn status_code(&self) -> StatusCode {
          match self {
              SubscribeError::ValidationError(_) => StatusCode::BAD_REQUEST,
              SubscribeError::DatabaseError(_)
              | SubscribeError::StoreTokenError(_)
              | SubscribeError::SendEmailError(_) => {
                  StatusCode::INTERNAL_SERVER_ERROR
              }
          }
      }
  }
  ```

- We didn't use our cool new chain walking helper. We also have a pretty generic
  exception.message for all cases. Here's what it looks like now:

  ```rs
  ...
  INFO: [HTTP REQUEST - END]
    exception.details="StoreTokenError(
      A database failure was encountered while trying to
      store a subscription token.
    Caused by:
      error returned from database: column 'subscription_token'
      of relation 'subscription_tokens' does not exist)"
  exception.message="Failed to create a new subscriber.",
  target=tracing_actix_web::root_span_builder,
  http.status_code=500
  ```

- We can clean it up by refining the `Debug` and `Display` implementations.

  ```rs
  //! src/routes/subscriptions.rs
  // [...]

  impl std::fmt::Debug for SubscribeError {
      fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
          error_chain_fmt(self, f)
      }
  }

  impl std::fmt::Display for SubscribeError {
      fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
          match self {
              SubscribeError::ValidationError(e) => write!(f, "{}", e),
              // What should we do here!
              SubscribeError::DatabaseError(_) => write!(f, "???"),
              SubscribeError::StoreTokenError(_) => write!(
                  f,
                  "Failed to store the confirmation token for a new subscriber."
              ),
              SubscribeError::SendEmailError(_) => {
                  write!(f, "Failed to send a confirmation email.")
              }
          }
      }
  }

  impl std::error::Error for SubscribeError {
      fn source(&self) -> Option<&(dyn std::error::Error + 'static)> {
          match self {
              // &str does not implement `Error` - we consider it the root cause
              SubscribeError::ValidationError(_) => None,
              SubscribeError::DatabaseError(e) => Some(e),
              SubscribeError::StoreTokenError(e) => Some(e),
              SubscribeError::SendEmailError(e) => Some(e),
          }
      }
  }
  ```

- We didn't actually know what to put for `DatabaseError` because it could occur
  for three situations:
  - acquiring a new Postgres connection from the pool;
  - inserting a subscriber in the `subscribers` table;
  - committing the SQL transaction.
- When you need to disambiguate, use an enum! We'll add more specific variants
  to our existing `SubscribeError`, and the compiler will even remind us to add
  them to all our `match` arms.

  ```rs
  //! src/routes/subscriptions.rs
  // [...]

  pub enum SubscribeError {
      ValidationError(String),
      StoreTokenError(StoreTokenError),
      SendEmailError(reqwest::Error),
      PoolError(sqlx::Error),
      InsertSubscriberError(sqlx::Error),
      TransactionCommitError(sqlx::Error),
  }

  impl std::fmt::Display for SubscribeError {
      fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
          match self {
              SubscribeError::ValidationError(e) => write!(f, "{}", e),
              // What should we do here!
              SubscribeError::StoreTokenError(_) => write!(
                  f,
                  "Failed to store the confirmation token for a new subscriber."
              ),
              SubscribeError::SendEmailError(_) => {
                  write!(f, "Failed to send a confirmation email.")
              }
              SubscribeError::PoolError(_) => {
                  write!(
                      f,
                      "Failed to acquire a Postgres connection from the pool."
                  )
              }
              SubscribeError::InsertSubscriberError(_) => {
                  write!(f, "Failed to insert new subscriber in the database.")
              }
              SubscribeError::TransactionCommitError(_) => {
                  write!(
                      f,
                      "Failed to commit SQL transaction to store a new subscriber."
                  )
              }
          }
      }
  }

  impl std::error::Error for SubscribeError {
      fn source(&self) -> Option<&(dyn std::error::Error + 'static)> {
          match self {
              // &str does not implement `Error` - we consider it the root cause
              SubscribeError::ValidationError(_) => None,
              SubscribeError::StoreTokenError(e) => Some(e),
              SubscribeError::SendEmailError(e) => Some(e),
              SubscribeError::PoolError(e) => Some(e),
              SubscribeError::InsertSubscriberError(e) => Some(e),
              SubscribeError::TransactionCommitError(e) => Some(e),
          }
      }
  }

  impl ResponseError for SubscribeError {
      fn status_code(&self) -> StatusCode {
          match self {
              SubscribeError::ValidationError(_) => StatusCode::BAD_REQUEST,
              SubscribeError::StoreTokenError(_)
              | SubscribeError::SendEmailError(_)
              | SubscribeError::PoolError(_)
              | SubscribeError::TransactionCommitError(_)
              | SubscribeError::InsertSubscriberError(_) => {
                  StatusCode::INTERNAL_SERVER_ERROR
              }
          }
      }
  }
  ```

- One problem with having three types of database error indicator is that we
  have to remove our `From<sqlx::Error>` since it maps to multiple variants and
  manually call `map_err` instead of counting on `?` to call `from` when we are
  dealing with a `sqlx::Error`.

  ```rs
  //! src/routes/subscriptions.rs
  // [...]

  pub async fn subscribe(/* */) -> Result<HttpResponse, SubscribeError> {
      // [...]
      let mut transaction =
          pool.begin().await.map_err(SubscribeError::PoolError)?;
      let subscriber_id = insert_subscriber(&mut transaction, &new_subscriber)
          .await
          .map_err(SubscribeError::InsertSubscriberError)?;
      // [...]
      transaction
          .commit()
          .await
          .map_err(SubscribeError::TransactionCommitError)?;
      // [...]
  }
  ```

- And here's our error message now:

  ```sh
  ...
  INFO: [HTTP REQUEST - END]
  exception.details="Failed to store the confirmation token
      for a new subscriber.

      Caused by:
          A database failure was encountered while trying to store
          a subscription token.
      Caused by:
          error returned from database: column 'subscription_token'
          of relation 'subscription_tokens' does not exist"
  exception.message="Failed to store the confirmation token for a new subscriber.",
  target=tracing_actix_web::root_span_builder,
  http.status_code=500
  ```

- The exception message is useful again and the exception.details trace all the
  way through. But it took us about 90 lines of code to get where we are now,
  including a ton of boilerplate `From` implementations. We can do the same
  thing with less code using the `thiserror` crate. We can get it down to 21
  lines of code and keep our custom `Debug` output.

  ```toml
  #! Cargo.toml
  [dependencies]
  thiserror = "1"
  ```

  ```rs
  //! src/routes/subscriptions.rs
  // [...]

  #[derive(thiserror::Error)]
  pub enum SubscribeError {
      #[error("{0}")]
      ValidationError(String),
      #[error("Failed to store the confirmation token for a new subscriber.")]
      StoreTokenError(#[from] StoreTokenError),
      #[error("Failed to send a confirmation email.")]
      SendEmailError(#[from] reqwest::Error),
      #[error("Failed to acquire a Postgres connection from the pool.")]
      PoolError(#[source] sqlx::Error),
      #[error("Failed to insert new subscriber in the database.")]
      InsertSubscriberError(#[source] sqlx::Error),
      #[error("Failed to commit SQL transaction to store a new subscriber.")]
      TransactionCommitError(#[source] sqlx::Error),
  }

  // We are still using a bespoke implementation of `Debug`
  // to get a nice report using the error source chain.
  impl std::fmt::Debug for SubscribeError {
      fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
          error_chain_fmt(self, f)
      }
  }

  // Then we have to specifically `map_err` for our `ValidationError` since
  // we no longer have `From<String>`.
  pub async fn subscribe(/* */) -> Result<HttpResponse, SubscribeError> {
      let new_subscriber =
          form.0.try_into().map_err(SubscribeError::ValidationError)?;
      // [...]
  }
  ```

- It's worth noting a few things about this. For one, we can remove all our
  implementations of `From<T>` and `Display` for `SubscribeError`. We still need
  `ResponseError` though, because `thiserror` isn't `actix-web` aware, plus we
  don't want every error giving a 500. Here we aren't using `#[from]` or
  `#[source]` for `ValidationError`, because `String` doesn't implement `Error`.
  We use `#[source]` for all our `sqlx::Error` variants again. Where we use
  `#[from]` we get both the `From<T>` implementation and set the `source`
  without specifically putting `#[source]`.
- We do have a problem now that our `SubscribeError` is failing to speak at the
  right level of abstraction. A caller of our `subscribe` function mainly needs
  to know `status_code` `400` or `500`. He doesn't need to know it was a
  database transaction error vs a send email error, since he will respond to
  both the same way. The only error the user can reasonably respond to is a
  validation problem. We currently have a variant for every fallible call in our
  `subscribe` function, so the function and error are tightly coupled. The ideal
  error type would look like this:

  ```rs
  //! src/routes/subscriptions.rs
  #[derive(thiserror::Error)]
  pub enum SubscribeError {
      #[error("{0}")]
      ValidationError(String),
      #[error(/* */)]
      UnexpectedError(/* */),
  }
  ```

- For unexpected error, we need to map any error type to it. There's already a
  type we've seen for that. `Box<dyn std::error::Error>`. Imagine this:

  ```rs
  //! src/routes/subscriptions.rs
  // [...]

  #[derive(thiserror::Error)]
  pub enum SubscribeError {
      #[error("{0}")]
      ValidationError(String),
      // Transparent delegates both `Display` and `source` implementations
      // to the type wrapped by `UnexpectedError`.
      #[error(transparent)]
      UnexpectedError(#[from] Box<dyn std::error::Error>),
  }

  impl ResponseError for SubscribeError {
      fn status_code(&self) -> StatusCode {
          match self {
              SubscribeError::ValidationError(_) => StatusCode::BAD_REQUEST,
              SubscribeError::UnexpectedError(_) => StatusCode::INTERNAL_SERVER_ERROR,
          }
      }
  }

  // Now we need to convert our errors with `map_err` before using `?`.
  pub async fn subscribe(/* */) -> Result<HttpResponse, SubscribeError> {
      // [...]
      let mut transaction = pool
          .begin()
          .await
          .map_err(|e| SubscribeError::UnexpectedError(Box::new(e)))?;
      let subscriber_id = insert_subscriber(/* */)
          .await
          .map_err(|e| SubscribeError::UnexpectedError(Box::new(e)))?;
      // [...]
      store_token(/* */)
          .await
          .map_err(|e| SubscribeError::UnexpectedError(Box::new(e)))?;
      transaction
          .commit()
          .await
          .map_err(|e| SubscribeError::UnexpectedError(Box::new(e)))?;
      send_confirmation_email(/* */)
          .await
          .map_err(|e| SubscribeError::UnexpectedError(Box::new(e)))?;
      // [...]
  }
  ```

- But now if we write a new test to trigger a failure in `insert_subscriber`, we
  see our logging has regressed.

  ```rs
  //! tests/api/subscriptions.rs
  // [...]

  #[tokio::test]
  async fn subscribe_fails_if_there_is_a_fatal_database_error() {
      // [...]
      // Break `subscriptions` instead of `subscription_tokens`
      sqlx::query!("ALTER TABLE subscriptions DROP COLUMN email;",)
          .execute(&app.db_pool)
          .await
          .unwrap();

      // [..]
  }
  ```

  ```sh
  INFO: [HTTP REQUEST - END]
    exception.details:
        "error returned from database: column 'email' of
        relation 'subscriptions' does not exist"
    exception.message:
        "error returned from database: column 'email' of
        relation 'subscriptions' does not exist"
  ```

- We lost our nice "Failed to insert new subscriber in the database." error
  message. We can even fix that though.

  ```rs
  //! src/routes/subscriptions.rs
  // [...]

  #[derive(thiserror::Error)]
  pub enum SubscribeError {
      #[error("{0}")]
      ValidationError(String),
      #[error("{1}")]
      UnexpectedError(#[source] Box<dyn std::error::Error>, String),
  }

  impl ResponseError for SubscribeError {
      fn status_code(&self) -> StatusCode {
          match self {
              // [...]
              // The variant now has two fields, we need an extra `_`
              SubscribeError::UnexpectedError(_, _) => {
                  StatusCode::INTERNAL_SERVER_ERROR
              },
          }
      }
  }

  //! src/routes/subscriptions.rs
  // [...]

  pub async fn subscribe(/* */) -> Result<HttpResponse, SubscribeError> {
      // [..]
      let mut transaction = pool.begin().await.map_err(|e| {
          SubscribeError::UnexpectedError(
              Box::new(e),
              "Failed to acquire a Postgres connection from the pool".into(),
          )
      })?;
      let subscriber_id = insert_subscriber(/* */)
          .await
          .map_err(|e| {
              SubscribeError::UnexpectedError(
                  Box::new(e),
                  "Failed to insert new subscriber in the database.".into(),
              )
          })?;
      // [..]
      store_token(/* */)
          .await
          .map_err(|e| {
              SubscribeError::UnexpectedError(
                  Box::new(e),
                  "Failed to store the confirmation token for a new \
                  subscriber.".into(),
              )
          })?;
      transaction.commit().await.map_err(|e| {
          SubscribeError::UnexpectedError(
              Box::new(e),
              "Failed to commit SQL transaction to store a new subscriber.".into(),
          )
      })?;
      send_confirmation_email(/* */)
          .await
          .map_err(|e| {
              SubscribeError::UnexpectedError(
                  Box::new(e),
                  "Failed to send a confirmation email.".into()
              )
          })?;
      // [...]
  }
  ```

  ```sh
  INFO: [HTTP REQUEST - END]
    exception.details=
        "Failed to insert new subscriber in the database.

        Caused by:
            error returned from database: column 'email' of
            relation 'subscriptions' does not exist"
    exception.message="Failed to insert new subscriber in the database."
  ```

- So our `subscribe` function is getting ugly again, but we got equivalent
  logging. It's a lot easier to implement this with the `anyhow` crate. The
  usual rule of thumb is "libraries use `thiserror`, binaries/applications use
  `anyhow`", and an HTTP service is an application. Quoting the documentation:

  > `anyhow::Error` is a wrapper around a dynamic error type. `anyhow::Error`
  > works a lot like `Box<dyn std::error::Error>`, but with these differences:
  >
  > - `anyhow::Error` requires that the error is `Send`, `Sync`, and `'static`.
  > - `anyhow::Error` guarantees that a backtrace is available, even if the
  >   underlying error type does not provide one.
  > - `anyhow::Error` is represented as a narrow pointer - exactly one word in
  >   size instead of two.

- I provided the full body of `subscribe` along with a reiteration of the
  `Debug` implementation, just to show all the final error code in one place.
  The only thing left out is our old `StoreTokenError` which hasn't changed.

  ```rs
  //! src/routes/subscriptions.rs
  // [...]
  use anyhow::Context;

  #[derive(thiserror::Error)]
  pub enum SubscribeError {
      #[error("{0}")]
      ValidationError(String),
      #[error(transparent)]
      UnexpectedError(#[from] anyhow::Error),
  }

  impl std::fmt::Debug for SubscribeError {
      fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
          error_chain_fmt(self, f)
      }
  }

  impl ResponseError for SubscribeError {
      fn status_code(&self) -> StatusCode {
          match self {
              SubscribeError::ValidationError(_) => StatusCode::BAD_REQUEST,
              // The variant now has two fields, we need an extra `_`
              SubscribeError::UnexpectedError(_) => {
                  StatusCode::INTERNAL_SERVER_ERROR
              }
          }
      }
  }

  #[tracing::instrument(/* */)]
  pub async fn subscribe(
      form: web::Form<FormData>,
      pool: web::Data<PgPool>,
      email_client: web::Data<EmailClient>,
      base_url: web::Data<ApplicationBaseUrl>,
  ) -> Result<HttpResponse, SubscribeError> {
      let new_subscriber =
          form.0.try_into().map_err(SubscribeError::ValidationError)?;
      let mut transaction = pool
          .begin()
          .await
          .context("Failed to acquire a Postgres connection from the pool.")?;
      let subscriber_id = insert_subscriber(&mut transaction, &new_subscriber)
          .await
          .context("Failed to insert new subscriber in the database.")?;
      let subscription_token = generate_subscription_token();
      store_token(&mut transaction, subscriber_id, &subscription_token)
          .await
          .context(
              "Failed to store the confirmation token for a new subscriber.",
          )?;
      transaction.commit().await.context(
          "Failed to commit SQL transaction to store a new subscriber.",
      )?;
      send_confirmation_email(
          &email_client,
          new_subscriber,
          &base_url.0,
          &subscription_token,
      )
      .await
      .context("Failed to send a confirmation email.")?;
      Ok(HttpResponse::Ok().finish())
  }
  ```

- The `context` method above is performing double duties:
  - it converts the error returned by our methods into an `anyhow::Error`;
  - it enriches it with additional context around the intentions of the caller.
- `context` is provided by the `Context` trait which `anyhow` implements for
  `Result`, giving it access to a fluent API to easily work with fallible
  functions of all kinds. This is a common pattern in the Rust community, known
  as **extension trait**, to provide additional methods for types exposed by the
  standard library (or other common crates in the ecosystem).
- The author points out that the old advice "`anyhow` is for applications,
  `thiserror` is for libraries." is not the right framing. You need to reason
  about **intent**. Use an enum and `thiserror` if you expect the caller to
  behave differently in response to an error. Use an opaque error like `anyhow`
  when you expect the caller to give up when a failure occurs. The old advice
  stems from the fact that library authors don't want to make assumptions about
  the intent of their users, so they steer towards enums to give users more
  control if they need it.
- As a rule of thumb, errors should be logged when they are handled. We
  currently have three unnecessary calls to `tracing::error!` that duplicate
  information bubbled up. If your function is propagating the error upstream, it
  should not log the error. It can, if it makes sense, add more context to it.
  If the error is propagated all the way up to the request handler, delegate
  logging to a dedicated middleware - `tracing_actix_web::TracingLogger` in our
  case. I've gone back and removed the calls you've seen earlier to
  `tracing::error!` in line with this advice. Here's our logs now for reference:

  ```sh
  INFO: test/90731 on Lambda-Air: [HTTP REQUEST - END]
    exception.details: Failed to store the confirmation token for a new subscriber.

    Caused by:
     A database error was encountered while trying to store a subscription token.
    Caused by:
     error returned from database: column "subscription_token" of relation
      "subscription_tokens" does not exist
    Caused by:
     column "subscription_token" of relation "subscription_tokens" does not exist
    --
    exception.message: Failed to store the confirmation token for a new subscriber.
  ```

- Note that the error message shows up twice in the logs now. It appears as part
  of `tracing-actix-web` logging when the `ResponseError` is returned and then
  again when the span ends (which is necessary for it to appear at all in span
  only logging systems like OpenTelemetry). You can disable the
  `tracing-actix-web` logging output by adding
  `tracing_actix_web::middleware=off` to `RUST_LOG`.
- I also went back and removed `StoreTokenError`. It's fine to let the
  `sqlx::Error` bubble up into the `context` from `anyhow`. If we wanted to keep
  it, we could've implemented it in fewer lines with `thiserror`.

## Chapter 9 - Naive Newsletter Delivery

- Looking back at our first user story, we notice it doesn't even make a
  distinction between pending and confirmed subscribers. As you spend time
  working on a problem you end up deepening your understanding of its
  **domain**. You often acquire mroe precise **language** that can be used to
  refine earlier attempts of describing the desired functionality. So it is
  worthwhile to make a habit of revisting user stories throughout the lifecycle
  of a project. So lets tighten up our user story.

  > As the blog author,  
  > I want to send an email to all my confirmed subscribers,  
  > So that I can notify them when new content is published.

- And of course the first thing we will do is write a test. But this test is to
  make sure we aren't spamming unconfirmed subscribers.
