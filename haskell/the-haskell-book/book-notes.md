# Haskell Programming from first principles

## Chapter 1 - All You Need is Lambda

## Chapter 2 - Hello, Haskell!

- The `($)` operator evaluates everything to its right first and can thereby
  be used to delay function application.
- You can use *sectioning* to partially apply an infix function: `(+2) 2`
- Sectioning for subtraction only works when it is the first argument:
  `(1 -) x`. To partially apply subtraction the other way, use `(subtract 2) 3`

## Chapter 3 - Strings

- The `::` symbol means "has the type" in Haskell.

## Chapter 4 - Basic Datatypes

- Float and Double work for calculations, but Scientific
  (`stack install scientific`) is better for a lot of cases. You may also
  use `Data.Fixed` to avoid floating point math. There are better packages
  for handling money.

## Chapter 5 - Types

- All functions are curried and the function constructor `(->)` is right
  associative. Adding parentheses to make it explicit:
  - `f :: a -> a -> a` is equivalent to `f :: a -> (a -> a)`
  - `map :: (a -> b) -> [a] -> [b]` is `map :: (a -> b) -> ([a] -> [b])`
- A functions of two arguments is really just takes one argument and returns
  a function from one argument to a result.
- Function definition `(->)` is a type constructor and is right associative,
  but function application `f a` is left associative.
- An *uncurried* version of `(+)` would take a tuple of two values and add
  them together, where our *curried* verson takes an argument and returns a
  function that takes another argument and returns a value. Some older
  functional languages use product types like tuples to express multiple
  arguments.
- Remember: `\i b -> i + (nonsense b)` is `\i -> \b -> i + (nonsense b)`

  ```hs
  -- curry and uncurry are already defined in Prelude, so we are shadowing here
  Prelude> curry f a b = f (a, b)
  Prelude> :t curry
  curry :: ((t1, t2) -> t) -> t1 -> t2 -> t
  Prelude> uncurry f (a, b) = f a b
  Prelude> :t uncurry
  uncurry :: (t1 -> t2 -> t) -> (t1, t2) -> t

  Prelude> :t fst
  fst :: (t -> b -> t)
  Prelude> :t curry fst
  curry fst :: t -> b -> t
  Prelude> fst (1, 2)
  1
  Prelude> curry fst 1 2
  1

  Prelude> :t (+)
  (+) :: Num a => a -> a -> a
  Prelude> (+) 1 2
  3
  Prelude> uncurry (+) (1, 2)
  3
  ```

- *Sectioning* is the partial application of infix operators and has a special
  syntax that allows you to partially apply the first or second argument.

  ```hs
  Prelude> elem 9 [1..10]
  True
  Prelude> 9 `elem` [1..10]
  True
  Prelude> c = (`elem` [1..10])
  Prelude> c 9
  True
  Prelude> c 25
  False
  ```

- If a variable could be *anything* (parametric polymorphism), then there's
  little that can be done to it, because it has no specific methods. If it can
  be *some* types (constrained or ad hoc polymorphism with type classes), then
  it has some methods. If it is a concrete type, you lose the type flexibility
  but due to the additive nature of inheritance you gain more potential methods.
- `Num` is called a superclass and `Integral` and `Int` are subclasses. In
  Haskell, a subclass cannot override methods of the superclass. Inheritance
  extends downwards. A member of `Num` has `Num` methods. A member of `Integral`
  has `Num` and `Integral` methods. And a concrete `Int` has `Num`, `Integral`,
  and `Int` methods.
- Most numeric literals in Haskell are only constrained to `Num`, but if you
  add a decimal or divide with `(/)` you might get constrained to `Factional`.
- A function is polymorphic when its parameters are polymorphic. *Parametricity*
  means the behavior of a function with respect to the types of its
  parametrically polymorphic arguments is uniform and the behavior *cannot*
  change just because it was applied to an argument of a different type.
- The `fromIntegral` number takes an `Integral` and returns a `Num`. It is
  useful when working with some of the Prelude functions that return `Int`.

  ## Chapter 6 - Type Classes

- A declaration of a type defines how that type is created, and a declaration
  of a type clas defines how a set of types are *consumed* or used in
  computations. A type class is like an interface in other languages and are
  a means of ad hoc polymophism. A type has an instance of a type class,
  meaning there is code that defines how the values and functions from
  that type class work for that type.
- Keep your type class instances for a type in the same file as that type.

  ```hs
  data DayOfWeek = 
    Mon | Tue | Wed | Thu | Fri | Sat | Sun

  date Date =
    Date DayOfWeek Int

  instance Eq DayOfWeek where
    (==) Mon Mon = True
    (==) Tue Tue = True
    (==) Wed Wed = True
    (==) Thu Thu = True
    (==) Fri Fri = True
    (==) Sat Sat = True
    (==) Sun Sun = True
    (==) _ _     = False

  instance Eq Date where
    (==) (Date weekday dayOfMonth)
         (Date weekday' dayOfMonth') =
      weekday == weekday'
    && dayOfMonth == dayOfMonth'
  ```

- `:set -Wall` in a repl or `-Wall` in build configuration will cause GHC
  to let us know when we're not handling all cases.
- With some constraints, we can derive `Eq`, `Ord`, `Enum`, `Bounded`, `Read`,
  and `Show`.

## Chapter 7 - More Functional Patterns

- `newtype` is different from `data` in that it permits only one constructor
  and only one field. We will use it in the following pattenr matching example:

  ```hs
  -- registerUser.hs
  module RegisteredUser where

  newtype Username =
    Username String

  newtype AccountNumber =
    AccountNumberInteger

  data User =
      UnregisteredUser
    | RegisteredUser Username AccountNumber

  printUser :: User -> IO ()
  printUser UnregisteredUser =
    putStrLn "UnregisteredUser"

  printUser (RegisteredUser
              (Username name)
              (AccountNumber accNum)) =
    putStrLn $ name ++ " " ++ show acctNum
  ```

- In ghci, `:browse ModuleName` will list the type signatures and functions we
  load from a module.
- Guard syntax allows us to write compact functions for two or more possible
  outcomes. Guards always evaluate sequentially. You can also use `where`
  declarations within guard blocks.

  ```hs
  myAbs :: Integer -> Integer
  myAbs x
    | x < 0     = (-x)
    | otherwise = x

  avgGrade :: (Factional a, Ord a) => a -> Char
  avgGrade x
    | y >= 0.9  = 'A'
    | y >= 0.8  = 'B'
    | y >= 0.7  = 'C'
    | y >= 0.59 = 'D'
    | y <  0.59 = 'F'
    where y = x / 100
  ```

- `(f . g) x = f (g x)`. `.` or `(.)` is the composition operator. You can
  think of the composition operator as a way of pipelining data through
  multiple functions. The composition operator has a precedence of 9, versus
  function application being 10, so you will sometimes see it used with `$` like
  `negate . sum $ xs`. You could also say `(negate . sum) xs`. The functions
  in composition are applied from right to left.
- "Point-free style" is a style of composing functions without specifying
  their arguments. The "point" in "point-free" refers to the arguments. We add
  "points" (`.`) to drop points (arguments). It helps the reader focus on the
  functions instead of the data. `f = negate . sum`.

## Chapter 8 - Recursion

- Recursion is defining a function in terms of itself via self-referential
  expressions. It is a means of expressing code that must take an *indefinite*
  number of steps to return a result. The data we are processing decides when
  we are done computing.
- The lambda calculus doesn't provide an obvious means of recursion due to the
  anonymity of expressions, but recursive functions are esssential to Turing
  completeness. The Y combinator or fixed-point combinator allows us to write
  recursive functions in the lambda calculus and is the basis for the recursion
  in Haskell.
- A recursive function needs a *base case* that stops the self-application or
  else it will run forever.

  ```hs
  applyTimes :: (Eq a, Num a) => a -> (b -> b) -> b ->b
  applyTimes 0 f b = b
  applyTimes n f b = f . applyTimes (n-1) f $ b -- f (applyTimes (n-1) f b)
  ```

- *bottom* refers to computations that do not successfully result in a value.
  The two main varieties are computations that fail with an error or those that
  fail to terminate. A partial function would be the first case.
- Type `type` keyword is used to declare a type synonym or type alias.
- Recall that multiplication is repeated addition and division is repeated
  subtraction. The quotient is how many times you can subtract the denominator
  from the numerator for a positive result.

  ```hs
  -- this is partial and doesn't handle divisors of 0 or less
  dividedBy :: Integral a => a -> a -> (a, a)
  dividedBy num denom = go num denom 0
    where go n   d count
           | n < d = (count, n)
           | otherwise =
              go (n - d) d (count + 1)
  ```

- Here's another example with recursion:

  ```hs
  import Data.List (intersperse) 

  digitToWord :: Int -> String
  digitToWord n
   | n == 0 = "zero"
   | n == 1 = "one"
   | n == 2 = "two"
   | n == 3 = "three"
   | n == 4 = "four"
   | n == 5 = "five"
   | n == 6 = "six"
   | n == 7 = "seven"
   | n == 8 = "eight"
   | n == 9 = "nine"
   | otherwise = error "not a digit"

  digits :: Int -> [Int]
  digits n = reverse (go n)
  where go n
         | n < 10 = [n]
         | otherwise = (mod n 10) : go (div n 10)

  wordNumber :: Int -> String
  wordNumber n = concat . intersperse "-" . map digitToWord . digits $ n

  ghci> wordNumber 531
  "five-three-one"
  ```

## Chapter 9 - Lists

- `[]` is the type constructor for lists as well as the data constructor for
  the empty list in the List datatype definition:

  ```hs
  data [] a = [] | a : [a]
  ```

- The list as a whole is a sum type because it is either an empty list or a
  single value consed to a list, but the second data constructor `:` is
  a product because it takes two arguments.
- You can pattern match on the data constructors:

  ```hs
  safeTail        :: [a] -> Maybe [a]
  safeTail []     = Nothing
  safeTail (_:[]) = Nothing
  safeTail (_:xs) = Just xs
  ```

- `xs` is cute name for more than one `x` and idiomatic.
- `[1, 2, 3, 4]` is syntactic sugar for `(1 : 2 : 3 : 4 : [])`
- We can discuss lists as "cons cells" and spines. A cons cell is the list's
  second data constructor `a : [a]`, the result of recursively prepending a
  value to "more list". The spine is the chain of (:) cells linking
  the list together, independent of the values they hold and it can be
  evaluated on its own without forcing those values inside the cells. Cons
  cells are nested inside one another not laid out flat in a row. Remember,
  a cons cell is a piece of data and a pointer to the next piece of data, so
  it could be written `Cons 1 (Cons 2 (Cons 3 (Cons 4 Nil)))`. 
- You can easily construct lists using ranges like `[1..10]`, which is
  equivalent to `enumFromTo 1 10`
- `take n xs` will return a list of the first `n` elements of `xs`. Taking from
  an empty list merely returns the empty list.
- `drop n xs` will return a list of `xs` with the first `n` elements removed.
- `splitAt n xs` will return a tuple of the first `n` elements of `xs` and the
  remainder of `xs`. `splitAt 3 [1..5] == ([1, 2, 3], [4, 5])`.
- `takeWhile` and `dropWhile` take a predicate and take or drop while it is
  `True` for the list elements. They stop at the first element that does not
  meet the condition. `takeWhile (<3) [1..10] == [1, 2]`.
- List comprehensions allow you to generate a new list from a list or lists.

  ```hs
  [ x^2 | x <- [1..3]] == [1, 4, 9]
  [ x^2 | x <- [1..5], rem x 2 == 1] == [1, 9, 25]
  [ x^y | x <- [1..3], y <- [2, 3]] == [1, 1, 4, 8, 9, 27]
  [ x^y | x <- [1..3], y <- [2, 3], x^y < 10] == [1, 1, 4, 8, 9]
  [ (x, y) | x <- [1..3], y <- ['a', 'b']] ==
    [(1, 'a'), (1, 'b'), (2, 'a'), (2, 'b'), (3, 'a'), (3, 'b')]
  ```

- With multiple lists, a list comprehensive generates every possible value
  for the first x valu, then it moves to the next x value, and so on.
- Strings are list of `Char`, so you can do list comprehensions with them.

  ```hs
  [x | x <- "Three Letter Acronym", elem x ['A'..'Z']] == "TLA"
  acro xs = [x | x <- xs, elem x ['A'..'Z']]
  vowels xs = [x | x <- xs, elem x "aeiou"]
  ```

- In ghci the `:sprint` command can primt variables and see what is evaluated.

  ```hs
  ghci> blah = enumFromTo 'a' 'z'
  ghci> :sprint blah
  _
  ghci> take 1 blah
  "a"
  ghci> :sprint blah
  blah = 'a' : _
  -- `length` is only strict in the spine, but in ghci it evaluates everything
  ghci> length blah
  26
  ghci> :sprint blah
  blah = "abcdefghijklmnopqrstuvwxyz"
  ```

- "Normal form" (NF) means fully evaluated, no unevaluated parts anywhere.
  "Weak head normal form" (WHNF) means evaluated at least as far as the
  outermost data constructor (or a lambda awaiting an argument) — whatever's
  inside that constructor may still be unevaluated. Every normal form
  expression is automatically also in WHNF, but not every WHNF expression
  is in normal form. So WHNF is the broader category; normal form is the
  special case where evaluation happened to go all the way down. Example:
  `(1 + 1) : undefined`
  is in WHNF (the outer `:` constructor is reached) but not normal form
  (`1 + 1` and `undefined` are both left unevaluated). `\x -> x * 10` is
  in both WHNF and NF. `"Papu" ++ "chon"` is in neither because its outermost
  component is an unevaluated function with fully applied arguments.
  `(1, "Papu" ++ "chon")` is in WHNF since it is fully evaluated up to its
  first data constructor `(,)`. When we fully define a list it is in both
  WHNF and NF, but when we define a list through ranges or functions it is
  in WHNF but not NF since the compiler only evaluates the head or first
  node and the cons constructor, not the value or rest of the list it contains.

  ```hs
  ghci> myNum :: [Int]; myNum = [1..10]
  ghci> :sprint myNum
  myNum = _
  ghci> take 2 myNum
  [1, 2]
  ghci> :sprint myNum
  myNum = 1 : 2 : _
  -- length evaluates the spine but not the values.
  ghci> x = [1, undefined]
  ghci> length x
  2
  -- if part of the spine is undefined, length will error
  gchi> x = [1] ++ undefined ++ [3]
  ghci> x
  [1*** Exception: Prelude.undefined
  ghci> length x
  *** Exception: Prelude.undefined
  ```

- In Haskell, we tend to use higher-order functions for transforming data
  rather than manualy recursion.
- `map` or `fmap` apply a function to each element of a list and return a 
  list of results (or Functor instead of list for `fmap`)

  ```hs
  map :: (a -> b) -> [a] -> [b]
  map _ []     = []
  map f (x:xs) = f x : map f xs

  ghci> badList = [1, 2, undefined]
  ghci> map (+1) badList
  [2,3,*** Exception: Prelude.undefined

  ghci> take 2 $ map (+1) badList
  [2,3]
  ```

- It doesn't need to be tail recursive since Haskell is lazy.
- `filter` takes a predicate and a list as input and it returns a list of
  values for which the predicate is new. `filter even [1..10] == [2,4,6,8,10]`.

  ```hs
  filter :: (a -> Bool) -> [a] -> [a]
  filter _ []        = []
  filter pred (x:xs)
    | pred x         = x : filter pred xs
    | otherwise      = filter pred xs

  -- these two are equivalent
  ghci> filter (\x -> elem x "aeiou") "abracadabra"
  "aaaaa"
  ghci> [x | x <- "abracadabra", elem x "aeiou"]
  "aaaaa"
  ```

- Zipping lists together allows you to combine values from multiple lists into
  a single list. `zip [1, 2, 3] [4, 5, 6] == [(1, 4), (2, 5), (3, 6)]`.
- Zip stops as soon as one list runs out of values and returns empty list
  if either list is empty.
- `unzip` will reverse this operation.
- `zipWith` takes a function and two lists and applies the function pairwise
  returning a list of results. `zipWith (+) [1, 2] [3, 4] = [4, 6]`.
- In type theory, a *product type* is a type made of a set of types compounded
  over each other. In Haskell, we represent products using tuples or data
  constructors with more than one argument. The "compounding" is from each
  type argument to the data constructor representing a value that coexists
  with all the other values simultaneously. Products of types represent a
  conjunction, "and," of those types. If you have a product of `Bool` and
  `Int`, your terms will *each* contain a `Bool` *and* an `Int` value.
- In type theory, a *sum type* of two types is a type whose terms are terms
  in either type, but not simultaenously. In Haskell, sum types are represented
  using the pipe, `|`, in a datatype definition. Sums of types represent a
  disjunction, "or" of those types. If you have a sum of `Bool` and `Int`,
  your terms will be *either a `Bool` value or an `Int` value.

## Chapter 10 - Folding Lists

- Folds as a general concept are called catamorphisms. Catamorphisms are a
  means of desconstructing data. If the spine of a list is the structure of a
  list, then a fold is what can reduce that structure. Despite the fact that
  a fold *can* break down this structure, the structure might be rebuilt. So a
  fold can return a list as a result also.
- `foldr` is "fold right" and the fold you'll most often want to use with lists.

  ```hs
  -- using the old type signature for lists. now it is for Foldable t
  foldr :: (a -> b -> b) -> b -> [a] -> b
  foldr _ z []     = z
  foldr f z (x:xs) = f x (foldr f z xs)
  
  foldl :: (b -> a -> b) -> b -> [a] -> b
  foldl _ z []     = z
  foldl f z (x:xs) = foldl f (f z x) xs

  -- Note that if `f` is `(:)` and `z` is `[]` you recreate the list
  ghci> foldr f z [1,2,3]
  = f 1 (foldr f z [2,3])
  = f 1 (f 2 (foldr f z [3]))
  = f 1 (f 2 (f 3 (foldr f z [])))
  = f 1 (f 2 (f 3 z))
  -- With f = (+) and z = 0, that's 1 + (2 + (3 + 0))

  ghci> foldl f z [1,2,3]
  = foldl f (f z 1) [2,3]
  = foldl f (f (f z 1) 2) [3]
  = foldl f (f (f (f z 1) 2) 3) []
  = f (f (f z 1) 2) 3
  -- With f = (+) and z = 0: ((0 + 1) + 2) + 3
  -- You see we have to recurse to [] before producing any value at all.

  -- The actualy type of `foldr` now is:
  foldr :: Foldable t => (a -> b -> b) -> b -> t a -> b
  ```

- `foldr` can work on an infinite list when given a function lazy in its
  second argument. `foldl`'s recursive call is a direct tail call (not
  wrapped as an argument to `f`), so it structurally can't short-circuit
  regardless of what `f` is, versus `foldr`'s call sitting inside `f x (...)`,
  where evaluation depends on `f`.

  ```hs
  myAny :: (a -> Bool) -> [a] -> Bool
  myAny f xs = foldr (\x b -> f x || b) False xs

  ghci> myAny even [1..]
  True

  ghci> myAny even (repeat 1)
  -- stuck because it's processing infinite 1's

  -- with a function ignoring its arguments, foldr only need be strict in
  -- evaluating the list up to the spine of the first cons cell to pattern
  -- match on (x:xs)
  ghci> foldr (\_ _ => 9001) 0 [1..5]
  9001
  ghci> xs = [1, 2, 3, undefined]
  ghci> foldr (\_ _ = 9001) 0 xs
  9001
  ghci> xs = [1, 2, 3] + undefined
  ghci> foldr (\_ _ = 9001) 0 xs
  9001
  ghci> xs = [undefined, undefined]
  ghci> foldr (\_ _ = 9001) 0 xs
  9001
  ghci> foldr (\_ _ = 9001) 0 undefined
  *** Exception: Prelude.undefined

  -- const actually evaluates it's first argument so is a bit more picky
  ghci> foldr const 0 [1..5]
  1 -- == const 1 (const 2 (const 3 (const 4 (const 5 0)))) == const 1 _
  ghci> foldr const 0 [1, undefined]
  1 -- but actually the second argument isn't evaluated, so this is `const 1 _`
  ghci> foldr const 0 [1,2] ++ undefined
  1 -- this is also `const 1 _`
  ghci> foldr const 0 [undefined, 2]
  *** Exception: Prelude.undefined

  ghci> foldr (flip const) 0 [1..5]
  0 -- == f_const 1 (f_const 2 (f_const 3 (f_const 4 (f_const 5 0))))
  ghci> foldl (flip const) 0 [1..5]
  5 -- == f_const (f_const (f_const (f_const (f_const 0 1) 2) 3) 4) 5
  ghci> foldl const 0 [1..5]
  0 -- == const (const (const (const (const 0 1) 2) 3) 4) 5

  -- foldl must evaluate the spine. This isn't helped by a function that only
  -- evaluates one argument.
  ghci> xs = [1..5] ++ undefined
  ghci> foldr const 0 xs
  1
  ghci> foldr (flip const) 0 xs
  *** Exception: Prelude.undefined
  ghci> foldl const 0 xs
  *** Exception: Prelude.undefined
  ghci> foldl (flip const) 0 xs
  *** Exception: Prelude.undefined
  ```

- Despite the fact that `foldl` must be strict in evaluating the spine, you
  can give it functions that ignores its arguments and workaround undefined
  values. `foldl` tends to have performance problems though, and you should
  usually use `foldl'` which is strict.
- Consider `foldr`'s similarity with `map`. `map` applies a function to each
  member of a list and returns a list. a fold replaces the cons constructors
  with the function and reduces the list.

  ```hs
  map :: (a -> b) -> [a] -> [b]
  map (+1) [1,2,3] = map (+1)      1 :      2 :     3  : []
                   =          (+1) 1 : (+1) 2 : (+1 3) : []

  foldr :: (a -> b -> b) -> [a] -> [b]
  foldr (+) 0 [1,2,3] = foldr (+) 0 (1 :  2 :  3 : [])
                      =              1 + (2 + (3 + 0))
  ```

- Left folds traverse the spine in the same direction as right folds but their
  folding process is left associative.
- The scan functions, `scanr` and `scanl`, can show us how a fold evaluates.
  They are similar to folds but return a list of all the intermediate stages.

  ```hs
  ghci> scanr (+) 0 [1..5]
  [15,14,12,9,5,0]
  ghci> scanl (+) 0 [1..5]
  [0,1,3,6,10,15]
  last (scanl f z xs) == foldl f z xs
  head (scanr f z xs) == foldr f z xs
  ```

- It is hard to see the importance of associativity with arithmetic functions.
  Consider `foldr (^) 2 [1..3] == 1` and `foldl (^) 2 [1..3] == 64` and
  `foldr (:) [] [1..3] == [1,2,3]` while `fold (flip (:)) [] [1..3] == [3,2,1]`.
  If we didn't `flip (:)` we would get a type error because the first argument
  is the accumulator and thus a list while the second argument is a value.
- When we write folds, we beging by thinking about what our start value for
  the fold is. This is usually the identity of the function and is also the
  fallback value for an empty list. Next we consider the arguments. A folding
  function takes to arguments, `a` and `b`, where `a` is always going to be
  a list element and `b` is either the start value or the value accumulated.

  ```hs
  -- Say we want the first three letters of each element of this list
  ghci> pab = ["Pizza", "Apple", "Banana"]
  ghci> f = (\a b -> take 3 a ++ b)
  ghci> foldr f "" pab
  "PizAppBan"
  ghci> f' = (\b a -> take 3 a ++ b)
  ghci> foldl f' "" pab
  "BanAppPiz" -- (f' (f' (f' "" "Pizza") "Apple") "Banana")
  ```

- For finite lists, `fold f z xs == foldl (flip f) z (reverse xs)`.
- You can use `foldl1` and `foldr1` when there is no proper zero value if you
  don't mind them crashing on an empty list.

  ```hs
  foldr1 :: (a -> a -> a) -> [a] -> a
  foldr1 f [x]    = x
  foldr1 f (x:xs) = f x (foldr1 f xs)

  foldl1 :: (a -> a -> a) -> [a] -> a
  foldl1 f (x:xs) = foldl f x xs
  ```

- Fold is often more convenient than explicit recursion.

  ```hs
  -- Notice for each of these the base case is identity for the operation.
  sum :: [Integer] -> Integer
  sum []     = 0
  sum (x:xs) = x + sum xs

  length :: [a] -> Integer
  length []     = 0
  length (_:xs) = 1 + length xs

  product :: [Integer] -> Integer
  product []     = 1
  product (x:xs) = x * product xs

  concat :: [[a]] -> [a]
  concat []     = []
  concat (x:xs) = x ++ concat xs

  and :: [Bool] -> Bool
  and []     = True
  and (x:xs) = x && and xs

  or :: [Bool] -> Bool
  or []     = False
  or (x:xs) = x || or xs
  
  -- now with foldr
  sum :: [Integer] -> Integer
  sum = foldr (+) 0

  length :: [a] -> Integer
  length = foldr (\_ acc -> acc +1) 0

  product :: [Integer] -> Integer
  product = foldr (*) 1

  concat :: [[a]] -> [a]
  concat = foldr (++) []

  and :: [Bool] -> Bool
  and = foldr (&&) True

  or :: [Bool] -> Bool
  or = foldr (||) False
  ```

- A *catamorphism* is a generalization of folds to arbitrary datatypes. Where
  fold allows you to break down a list into an arbitrary datatype, a
  catamorphism is a means of breaking down the structure of any datatype.
  `bool` in `Data.Bool` is a simple catamorphism for `Bool` as is `maybe` for
  `Maybe` and `either` for `Either`.

  ```hs
  data Bool = False | True
  bool :: a -> a -> Bool -> a

  data Maybe a = Nothing | Just a
  maybe :: b -> (a -> b) -> Maybe a -> b

  data Either a b = Left a | Right b
  either :: (a -> c) -> (b -> c) -> Either a b -> c
  ```

## Chapter 11 - Algebraic Datatypes

- A type can be thought of as an enumeration of constructors that have zero or
  more arguments.

  ```hs
  data Bool = False | True
  data [] a = []    | a : [a]
  ```

- `Bool` is an enumeration of two possible constructors, each of which take
  zero arguments (nullary constructors). The type constructor `[]` enumerates
  two possible constructors and one of them takes two arguments. The pipe in
  both data declarations denotes a *sum type*, a type that has more than one
  constructor inhabiting it. In addition to sum types, Haskell has *product
  types* which we'll cover shortly. The data constructor in a product type
  has more than one parameter.
- Haskell has type constructors and data constructors. Type constructors are
  at type level and appear in type signatures and type class declarations and
  instances. Types are static and resolve at compile time. Data constructors
  construct values at term level that you can interact with at runtime. We call
  them constructors, because they define a means of creating or building a type
  or value. Type and data constructors that take no arguments are *constants*.
  In the `Bool` declaration, `Bool` is a type constant, a concrete type that
  isn't waiting for any addition information in the form of an argument to be
  realized as a type. It enumerates two values that are also constants, `True`
  and `False`, because they take no arguments. We call `True` and `False` data
  constructors, but since they take no arguments their values are already
  established and they are not being constructed in any meaningful sense.
  When a constructor takes an argument, it must be applied to become a concrete
  type of value. A nullary constructor is called a *type constant* to
  distinguish it from a type constructor that takes arguments. The list
  constructor must be applied to a concrete type before you have a list.
- *Kinds* are the types of types, or types one level up. They are distinguished
  with `*`. Something is fully-applied or concrete when its kind is `*`. When
  it is `* -> *`, it is still waiting to be applied. We can query the kind
  of a type constructor (not a data constructor) with `:kind` or `:k` in GHCI.
  `:k Bool` is `Bool :: *`, `:k [Int]` is `[Int] :: *`, and `:k []` is
  `[] :: * -> *`. Both `Bool` and `[Int]` are fully applied, so their kind
  signatures have no function arrows. `[]` still needs to be applied to a
  concrete type before it becomes a concrete type. A type like `Either a b` has
  kind `* -> * -> *` and is waiting to be applied to two concrete type. This is
  what the
  *constructor* of "type constructor" is referring to. We use `:type` or `:t`
  when finding the type of data constructors. Type constructors have kinds and
  data constructors have types. Constructors behave like (type or value-level)
  constants if they do not take an argument, and if they take arguments, they
  act like (type or value-level) functions that don't do anything except get
  applied.
- Both data constructors and type constructors begin with capital letters, but
  a constructor before the `=` in a datatype definition is a type constructor,
  while constructors after the `=` are data constructors. When data
  constructors take arguments, those arguments refer to other types. In Haskell
  we cannot choose specific values of types as type arguments. If you are a
  `[Bool]` list you must take values of both `True` and `False`.
- *Arity* refers to the number of arguments a function or constructor takes. A
  function that takes no arguments is called *nullary*. So are data onstuctors
  that take no arguments. Nullary data constructors are constant values at term
  level and cannot constructor or represent any data other than themselves.
  They are values that act as witnesses of the datatype in which they are
  declared. Functions that take arguments might be unary or
  binary or take more arguments. Data constructors that take one argument are
  called unary. Data constructors that take more than one argument are called
  products. Tuples are considered the canonical product type but are called
  *anonymous products* because they have no name.
- Algebraic datatypes in Haskell are alebraic, because we can describe the
  patterns of argument structures using two basic operations: sum and product.
  Sum and product are most easily demonstrated in terms of *cardinality*, but
  it doesn't map perfectly as we can have infinte data structures in Haskell.
  The cardinality of a datatype is the number of possible values it defines.
- The cardinality of a datatype roughly equats to how difficult it is to
  reason about.
- `Bool` has two inhabitants that are both nullary data constructors, so the
  cardinality of `Bool` is 2. In general, a sum datatype with nullary
  constructors will have a cardinality equal to the number of constructors.
- `Int` and related datatypes (`Int8`, `Int16`, and
  `Int32`) have clearly delineated upper and lower bounds. Valid `Int8` values
  are from -128 to 127. You can test this with `minBound :: Int8` and 
  `maxBound :: Int8` after running `import Data.Int`, so `Int8` has cardinality 
  128 + 127 + 1 = 256. Anywhere you have a type of `Int8`, you have 256
  possible values. This is because `Int8` is 8 bits or `2^8 == 256` values.
  Likewise `Int16`, `Int32`, and plain `Int` are `2^16`, `2^32`, and `2^64`
  values respectively.
- Unary dataconstructors always have the same cardinality of the type they
  contain. `data Goats = Goats Int deriving (Eq, Show)` has cardinality `2^64`.
  Anything that is a valid `Int` will be a valid arguments to `Goats`.
  For cardinalithy, this means unary constructors are the identity function.
- The `newtype` keyword allows us to define a type that can only ever have a
  single unary data constructor. They are different from type declarations
  marked with the `data` keyword and from type synonym deifnitions marked by
  the `type` keyword. The cardinality of a `newtype` is the same as that of
  the type it contains. A `newtype` cannot be a product type, sum type, or
  contain nullary data constructors. It also has no runtime overhead, since it
  reuses the representation of the type it contains. Any difference is gone
  after the compiler generates the code. `newtype` declarations are similar
  in that any distinction between them and their underlying type is stripped
  away at compile time. The distinction is useful to human readers and writers
  of the code. For `newtype` though, you can define type class instances that
  different form the instances for its underlying type. The `newtype` can rely
  on type instances of the type it contains for useer-defined type classes
  if you use the `GeneralizedNewtypeDeriving` `LANGUAGE` pragma.

  ```hs
  -- without GeneralizedNewtypeDeriving we can call the Int instance
  class TooMany a where
    tooMany :: a -> Bool

  instance TooMany Int where
    tooMany n = n > 42

  newtype Goats = 
    Goats Int deriving (Eq, Show)

  instance TooMany Goats where
    tooMany (Goats n) = tooMany n

  ghci> tooMany (42 :: Int)
  False
  ghci> tooMany (Goats 42)
  False

  -- to use the PRAGMA, add this to your source file
  {-# LANGUAGE GeneralizedNewtypeDeriving #-}
  class TooMany a where
    tooMany :: a -> Bool

  instance TooMany Int where
    tooMany n = n > 42

  newtype Goats = Goats Int deriving (Eq, Show, TooMany)
  ```

- The `|` in sum types represents logical disjunction: "or". This is the *sum*
  in algebraic datatypes. To know the cardinality of a sum type, you add the
  cardinalities of their data constructors. Nullary constructors have a
  cardinality of 1.
- A product types cardinality is the product of the cardinalities of its
  inhabitants. A product type expresses "and". Any data constructor with two
  or more type arguments is a product.
- Records in Haskell are product types with additional syntax to provide
  convenient accessors to fields with a record.

  ```hs
  data Person =
    Person { name :: String
           , age :: Int }
           deriving (Eq, Show)

  ghci> Person "Papu" 5
  Person {name = "Papu", age = 5}
  ghci> papu = Person "Papu" 5
  -- The record declaration automatically declares `name` and `age` accessors
  ghci> name papu
  "Papu"
  ghci> age papu
  5
  ```

- All the existing algebraic rules for products and sums apply in type systems
  including the distributive property. Product types distribute over sum types.
  A type is in normal form when it is written as a sum (type) of products.

  ```hs
  data Fiction = Ficton deriving Show
  data Nonfiction = Nonfiction deriving Show

  data BookType = FictionBook Fiction
                | NonfictionBook NonFiction
                deriving Show

  type AuthorName = String

  -- This is not normal form. It is not a sum of products.
  data Author = Author (AuthorName, BookType)
  -- We apply the distributive property to rewrite Author in normal form
  data Author =
      Fiction AuthorName
    | Nonfiction AuthorName
    deriving (Eq, Show)

  -- This is another common type in papers about type systems and programming
  -- languages that is written in normal form. It is:
  -- (Number Int) + Add (Expr Expr) + ...
  data Expr =
      Number Int
    | Add Expr Expr
    | Minus Expr
    | Mult Expr Expr
    | Divide Expr Expr
  ```

- Try to avoid using type synonyms with unstructured data like text or binary.
  They are best used when you want something lighter weight than newtypes but
  also want your type signatures to be more explicit.
- Records are primarily syntax to create field references and don't do much
  heavy lifting in Haskell, but they are convenient. Whenever we have a product
  type that uses record accessors, we should define it separate from any sum
  type that is wrapping it. You want to be able to use your accessors on any
  value of the record type.
- The idea of a catamorphism deconstructing the datatype is generall applicable
  to any datatype that has values, not only lists. Below is an example of
  deconstructing values for a product type.

  ```hs
  newtype Name    = Name String deriving Show
  newtype Acres   = Acres Int deriving Show

  data FarmerType = DairyFarmer
                  | WheatFarmer
                  | SoybeanFarmer
                  deriving Show

  data Farmer =
    Farmer Name Acres FarmerType
    deriving Show

  isDairyFarmer :: Farmer -> Bool
  isDairyFarmer (Farmer _ _ DairyFarmer) = True
  isDairyFarmer _ = False

  -- we could do the same thing with records
  data FarmerRec =
    FarmerRec { name       :: Name
              , acres      :: Acres
              , farmerType :: FarmerType }
              deriving Show

  isDairyFarmerRec :: FarmerRec -> Bool
  isDairyFarmerRec farmer =
    case farmerType farmer of
      DairyFarmer -> True
      _           -> False
  ```

- The function type is exponential. Give a function `a -> b` we can calculate
  the inhabitants with the formula `b ^ a`. If b and a were both `Bool`, we
  would have `2 ^ 2 == 4` inhabitants. `a -> b -> c` is `(c ^ b) ^ a` or just
  `c ^ (b * a)`.
- A kind `* -> * -> *` is known as a *higher-kinded type* and lists are an
  example in Haskell. Getting comfortable with higher-kindred types is
  important as type arguments provide a generic way to express a "hole" to be
  filled by consumers of your datatype later.
- When we give an operator a non-alphanumeric name it is infix by default.
  Alphanumeric functions are prefix by default. The same rule applies to data
  constructors. Any operator that starts with a colon `(:)` must be an infix
  type or data constructor. All infix data constructors must start with a
  colon. The type construct of functions `(->)` is the only infix constructor
  that does not start with a colon. They also cannot be `::` as this is only
  used in type assertions.

  ```hs
  data BinaryTree a =
      Leaf
    | Node (BinaryTree a) a (BinaryTree a)
    deriving (Eq, Ord, Show)

  insert' :: Ord a => a -> BinaryTree a -> BinaryTree a
  insert' b Leaf = Node Leaf b Leaf
  insert' b (Node left a right)
    | b == a = Node left a right
    | b < a  = Node (insert' b left) a right
    | b > a  = Node left a (insert' b right)

  ghci> t1 = insert' 0 Leaf
  ghci> t1
  Node Leaf 0 Leaf

  ghci> t2 = insert' 3 t1
  ghci> t2
  Node Leaf 0 (Node Leaf 3 Leaf)

  ghci> t3 = insert' 5 t2
  ghci> t3
  Node Leaf 0 (Node Leaf 3 (Node Leaf 5 Leaf))

  mapTree :: (a -> b) -> BinaryTree a -> BinaryTree b
  mapTree _ Leaf = Leaf
  mapTree f (Node left a right) = Node (mapTree f left) (f a) (mapTree f right)

  testTree' :: BinaryTree Integer
  testTree' = Node (Node Leaf 3 Leaf) 1 (Node Leaf 4 Leaf)

  mapExpected = Node (Node Leaf 4 Leaf) 2 (Node Leaf 5 Leaf)

  mapOkay = if mapTree (+1) testTree' == mapExpected
            then print "yup OK!"
            else error "test failed!"

  preorder :: BinaryTree a -> [a]
  preorder Leaf = []
  preorder (Node left a right) = [a] ++ preorder left ++ preorder right

  inorder :: BinaryTree a -> [a]
  inorder Leaf = []
  inorder (Node left a right) = inorder left ++ [a] ++ inorder right

  postorder :: BinaryTree a -> [a]
  postorder Leaf = []
  postorder (Node left a right) = postorder left ++ postorder right ++ [a]

  -- I solved this with a traversal
  foldTree :: (a -> b -> b) -> b -> BinaryTree a -> b
  foldTree _ z Leaf = z
  foldTree f z tree = foldr f z (inorder tree)

  -- Here is my AI companions answer that works on the tree directly
  foldTree' :: (a -> b -> b) -> b -> BinaryTree a -> b
  foldTree' _ z Leaf = z
  foldTree' f z (Node left a right) =
   let z'  = foldTree f z right    -- fold the right subtree first, seeded with z
       z'' = f a z'                -- combine this node's value into that result
    in foldTree' f z'' left         -- fold the left subtree, seeded with z''
  ```

- As-patterns allow you pattern match on part of something and still refer to
  the entire original value:

  ```hs
  f :: Show a => (a, b) -> IO (a, b)
  f t@(a, _) = do
    print a
    return t

  doubleUp :: [a] -> [a]
  doubleUp [] = []
  doubleUp xs@(x: _) = x : xs

  -- find a subsequence only if it is in the original order
  isSubseqOf :: (Eq a) => [a] -> [a] -> Bool
  isSubseqOf [] xs = True
  isSubseqOf xs [] = False
  isSubseqOf xs'@(x:xs) (y:ys)
    | x == y = isSubseqOf xs ys
    | otherwise = isSubseqOf xs' ys

  ghci> isSubseqOf "blah" "blahwoot"
  True
  ghci> isSubseqOf "blah" "wootblah"
  True
  ghci> isSubseqOf "blah" "wboloath"
  True
  ghci> isSubseqOf "blah" "wootbla"
  False
  ghci> isSubseqOf "blah" "halbwoot"
  False
  ghci> isSubseqOf "blah" "blawhoot"
  True
  ```

## Chapter 12 - Signaling Adversity

- We use `Maybe` values when we don't have any sensible values too return for
  our intended type `a` so want to be able to return `Nothing`.

  ```hs
  type Name = String
  type Age = Integer

  data Person = Person Name Age deriving Show

  mkPerson :: Name -> Age -> Maybe Person
  mkPerson name age
    | name /= "" && age >= 0 = Just $ Person name age
    | otherwise = Nothing
  ```

- `mkPerson` above is a *smart constructor*. It allows us to construct values
  of a type only when they meet certain criteria, so we know that we have a
  valid value, and return an explicit singal when they do not.
- One drawback of `Maybe` is that it is possible to fail but not say why you
  failed. To handle that we have `Either`.

  ```hs
  type Name = String
  type Age = Integer

  data Person = Person Name Age deriving Show

  data PersonInvalid = NameEmpty
                     | AgeTooLow
                     deriving (Eq, Show)

  mkPerson :: Name -> Age -> Either PersonInvalid Person
  mkPerson name age
    | name /= "" && age >= 0 = Right $ Person name age
    | name == "" = Left NameEmpty
    | otherwise = Left AgeTooLow
  ```

- The convention is `Left` to holds the error and `Right` is a valid result.
- But what if we need more than one error?

  ```hs
  type Name = String
  type Age = Integer

  type ValidatePerson a = Either [PersonInvalid] a

  data Person = Person Name Age deriving Show

  data PersonInvalid = NameEmpty
                     | AgeTooLow
                     deriving (Eq, Show)

  ageOkay :: Age -> Either [PersonInvalid] Age
  ageOkay age = case age >= 0 of
    True  -> Right age
    False -> Left [AgeTooLow]

  nameOkay :: Name -> Either [PersonInvalid] Name
  nameOkay name = case name /= "" of
    True  -> Right name
    False -> Left [NameEmpty]

  mkPerson :: Name -> Age -> ValidatePerson Person
  mkPerson name age = mkPerson' (nameOkay name) (ageOkay age)

  mkPerson' :: ValidatePerson Name 
            -> ValidatePerson Age 
            -> ValidatePerson Person
  mkPerson' (Right nameOk) (Right ageOk) = Right (Person nameOk ageOk)
  mkPerson' (Left badName) (Left badAge) = Left (badName ++ badAge)
  mkPerson' (Left badName) _             = Left badName
  mkPerson' _              (Left badAge) = Left badAge
  ```

- Note that you cannot hide polymorphic types from your type constructor.
  There is `data Unary = Unary Int` and `data Unary a = Unaray a`, but for
  `a` to have meaning it must be introduce through the type constructor.

  ```hs
  import Date.Maybe

  notThe :: String -> Maybe String
  notThe "the" = Nothing
  notThe s = Just s

  replaceThe :: String -> String
  replaceThe = unwords . map (fromMaybe "a" . notThe) . words

  ghci> replaceThe "the cow loves us"
  "a cow loves us"
  ```
