# Learn Haskell by Example

## Chapter 2 - Ancient secret keeping on modern machines

- Use `:{` and `}:` for multi-line ghci commands.
- Lists are homogenous but tuples are fixed length but can have multiple types.
- In functional languages functions don't return a value, they evaluate to a
  value.
- Types include Bool, Char, Integer, Int, Float, Double, and String ([Char]).
- You can use type synonyms for readability. Even `FilePath` is just a synonym
  for `String`.
- In ghci, you can use :r, :t, and :i instead of :reload, :type, and :info.
- You can call any binary function as infix by surrounding it with backticks.
- Operators are just functions written in infix notation. You can call them in
  prefix position or refer to them directly with parentheses: `(||)`, `(+)`
- `if` must have an `else` so it evaluates to a value.
