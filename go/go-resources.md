# Go Resources

## Free resources

- [A Tour of Go](https://go.dev/tour) - interactive intro to the syntax.
- [Go by Example](https://gobyexample.com) - short annotated examples, handy
  for syntax lookups mid-chapter.
- [Learn Go with Tests](https://quii.gitbook.io/learn-go-with-tests) - learn Go
  through TDD, chapter by chapter.
- [Gophercises](https://gophercises.com) - 20 mini-projects. Free with an
  email sign-up; each exercise's spec is in its repo README at
  `github.com/gophercises/<name>`, so the videos are optional.
- [Gossip Glomers](https://fly.io/dist-sys/) - distributed systems challenges
  (echo, unique IDs, broadcast, counters, Kafka-style log, transactions) run
  against Jepsen's Maelstrom. Needs Java; Graphviz and gnuplot for its graphs.
- [Build Your Own Database From Scratch](https://build-your-own.org/database/) -
  a database in Go. Part I (the key-value store) is free online; the rest is a
  paid ebook ([Leanpub](https://leanpub.com/build_your_own_database_from_scratch),
  ~$25, or ~$35 with chapter-by-chapter Go source).
- [Protohackers](https://protohackers.com) - network server puzzles checked by
  a remote tester; good goroutine practice.
- [CodeCrafters](https://codecrafters.io) - build your own Redis, Git, SQLite,
  HTTP server, shell, etc. with automated tests. Some challenges free, full
  access paid.
- [build-your-own-x](https://github.com/codecrafters-io/build-your-own-x) -
  curated "build your own" tutorials, filterable by language.
- [Crafting Interpreters](https://craftinginterpreters.com) - free online;
  Java and C in the book, but popular to follow in Go or Rust.

## Official docs

- [Effective Go](https://go.dev/doc/effective_go) - idiomatic Go from the Go
  team. Short and a bit dated, but worth an afternoon.
- [The Go Programming Language Specification](https://go.dev/ref/spec) -
  unusually readable for a language spec.

## Core books

- *The Go Programming Language* - Alan Donovan & Brian Kernighan, 2015. The
  "K&R of Go." Thorough and precise, but predates generics, modules, and
  `context`. Code: <https://github.com/adonovan/gopl.io>
- *Learning Go* - Jon Bodner, O'Reilly, 2nd ed. 2024. The usual modern pick
  for experienced programmers: idiomatic Go including generics and modules.
- *100 Go Mistakes and How to Avoid Them* - Teiva Harsanyi, Manning, 2022. Real
  traps like `append` aliasing, `defer` in loops, and nil interfaces.
- *Concurrency in Go* - Katherine Cox-Buday, O'Reilly, 2017. The standard deep
  dive on goroutines, channels, `select`, pipelines, and cancellation.
- *Efficient Go* - Bartłomiej Płotka, O'Reilly, 2022. Performance,
  benchmarking, and profiling.
