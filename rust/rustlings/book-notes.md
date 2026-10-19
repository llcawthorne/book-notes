# Rustlings

- Site: <https://rustlings.rust-lang.org>
- Repo: <https://github.com/rust-lang/rustlings>

- Note: Rustlings isn't really a "book", but I needed someplace to make notes
  and save examples. In theory I could just re-init it and re-work any of the
  exercises, but I like having a place to keep reference to stuff I find
  personally useful rather than having to start over with a resource.

## Plan

Work through it alongside the Brown version of The Rust Programming Language
(TRPL). Do the exercises in order, pausing at the first one whose chapter I
haven't read yet:

| Exercises      | Read first  | Notes                                       |
| -------------- | ----------- | ------------------------------------------- |
| `01`–`04`      | TRPL 3      |                                             |
| `05`–`11`      | TRPL 4–8    | `05_vecs` needs ch8; `08_enums` needs §19.3 |
| `12`–`16`      | TRPL 9–10   | `12_options` needs ch10                     |
| `17_tests`     | TRPL 11     |                                             |
| `18_iterators` | TRPL 12–13  |                                             |
| `19`–`20`      | TRPL 14–16  |                                             |
| `21_macros`    | TRPL 19–20  |                                             |
| `22`–`23`      | finish TRPL | `22_clippy` is Appendix D                   |
| `24_async`     | TRPL 17     |                                             |

## Exercises and TRPL Chapters

| Exercise              | TRPL Chapter |
| --------------------- | ------------ |
| `01_variables`        | §3.1         |
| `02_functions`        | §3.3         |
| `03_if`               | §3.5         |
| `04_primitive_types`  | §3.2, §4.3   |
| `05_vecs`             | §8.1         |
| `06_move_semantics`   | §4.1-2       |
| `07_structs`          | §5.1, §5.3   |
| `08_enums`            | §6, §19.3    |
| `09_strings`          | §8.2         |
| `10_modules`          | §7           |
| `11_hashmaps`         | §8.3         |
| `12_options`          | §10.1        |
| `13_error_handling`   | §9           |
| `14_generics`         | §10          |
| `15_traits`           | §10.2        |
| `16_lifetimes`        | §10.3        |
| `17_tests`            | §11.1        |
| `18_iterators`        | §13.2-4      |
| `19_smart_pointers`   | §15, §16.3   |
| `20_threads`          | §16.1-3      |
| `21_macros`           | §20.5        |
| `22_clippy`           | Appendix D   |
| `23_conversions`      | n/a          |
| `24_async`            | §17          |

## Notes

- Exercises 1-4 were trivial. I forgot there was an easy way to initialize an
  array to 100 elements of the same value and looked up a complicated solution
  to converting a range to an array, but then was reminded after the fact that I
  can just do `let a = [0; 100]`. The solutions had the "correct" way to do it.
- It's a nice touch that the solutions are all empty until after you solve the
  problem. I have only had to use the hints once or twice, but they seem thorough
  enough to get you going when your stuck.
