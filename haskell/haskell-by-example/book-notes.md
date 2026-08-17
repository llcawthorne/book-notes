# Learn Haskell by Example

## Chapter 2 - Ancient secret keeping on modern machines

- Create a new project with `stack new caesar`.
- Use `:{` and `:}` for multi-line ghci commands.
- Use `{-` and `-}` for multi-line comments and `--` for single-line comments.
- Lists are homogenous. Tuples are fixed length but can have multiple types.
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
- The `then` and `else` branch of an `if` need to evaluate to the same type.

  ```hs
  -- rot13, digits, and alphabetRot are defined in ch02/caesar/src/Lib.hs
  rot135 :: String -> String
  rot135 [] = []
  rot135 (ch : xs)
    | isLower ch = lowerRot 13 ch : rot135 xs
    | isUpper ch = upperRot 13 ch : rot135 xs
    | isDigit ch = alphabetRot digits 5 ch : rot135 xs
    | otherwise = ch : rot135 xs
  ```

- Note that `code/chapterX/project/lib/Exercises.hs` has well commented
  solutions to exercises presented in the book. For example:
  `chapter2/caesar/src/Exercises.hs`

## Chapter 3 - Every line counts

- The `do` keyword starts a `do` block where we can invoke IO actions
  or any kind of monad. In the `do` block of an IO action, the last expression
  needs to be a IO action.
- We use the `do` notation to specify a sequence of actions and how their
  resulting values are passed to other actions and functions.
- The `return` function wraps a value in an IO action.
- The expressions passed to actions can be built from pure functions, allowing us
  to use pure code within impure code.

  ```hs
  interactiveLines :: Int -> IO ()
  interactiveLines counter = do
    line <- getLine
    if null line
      then return ()
      else do
        putStrLn (show counter ++ ". " ++ line)
        interactiveLines (counter + 1)
  ```

- `System.Environment` provides `getArgs`, `getProgName`, and `lookupEnv`.
- Maybe is an *algebraic data type* used to return a value when the possibility
  of errors arises in a function and can be used to avoid the usage of
  `undefined`.
- Simplest argparsing scheme - only accept one argument:

  ```hs
  parseArguments :: [String] -> Maybe FilePath
  parseArguments [filePath] = Just filePath
  parseArguments _ = Nothing

  fromMaybe :: a -> Maybe a -> a
  fromMaybe _ (Just v) = v
  fromMaybe v Nothing = v
  ```

- `Data.Maybe` defines `fromMaybe` and other Maybe helper functions such as
  `maybe`, `catMaybes`, and `mapMaybe`.
- Here's a first draft of our program, that expects one filename as argument
  and prints it out upon receiving it or prints help otherwise.

  ```hs
  module Main (main) where

  import System.Environment
  printHelpText :: String -> IO ()
  printHelpText msg = do
    putStrLn (msg ++ "\n")
    progName <- getProgName
    putStrLn ("Usage: " ++ progName ++ " <filename>")

  parseArguments :: [String] -> Maybe FilePath
  parseArguments [filePath] = Just filePath
  parseArguments _ = Nothing

  main :: IO ()
  main = do
    cliArgs <- getArgs
    let mFilePath = parseArguments cliArgs
    maybe
      (printHelpText "Missing filename")
      (\filePath -> putStrLn filePath)
      mFilePath
  ```

- When using local variables for some Maybe type, it is common to prefix the
  variable name with a lowercase `m`. `mFilePath` is `Maybe FilePath`.
- The `let` keyword is used to bind definitions within actions to a certain
  identifier.
- To pass arguments when running from stack use:
  `stack run <arguments for stack> -- <arguments for the program>`

## Chapter 4 - Line numbering tool

- Some functions included in Prelude: `readFile`, `writeFile`, `lines`,
  `unlines`, `words`, and `unwords`.

  ```hs
  readLines :: FilePath -> IO [String]
  readLines filePath = do
    contents <- readFile filePath
    return (lines contents)
  ```

- Associative lists are extremely versatile but can be inefficient.
- Maybe is used not just to catch errors but to encode *optional* values.
- When you use `let` in a `do` block, it acts as a statement setting a value,
  until the end of the `do` block, but outside of `do` you pair `let` with `in`
  to define where variables are bound. Local definitions done by `let` can
  reference each other in addition to being available in `in`.
- Locally defined functions are often called `go` or `aux`.
- You can implement `lines` recursively:

  ```hs
  myLines :: String -> [String]
  myLines "" = []
  myLines text =
    let go "" "" = []
        go line "" = [line]
        go line (x : xs)
          | x == '\n' = line : go "" xs
          | otherwise = go (line ++ [x]) xs
     in go "" text
  ```

- We need a way to tell if a string is empty or contains non-printable chars.
  We can put together `all` with a custom function using `Data.Char` functions.
  And we have a spiffy new `numberLines` to pass our predicate into:

  ```hs
  isEmpty :: String -> Bool
  isEmpty str =
    null str
      || all (\s -> not (isPrint s) || isSeparator s) str

  isNotEmpty :: String -> Bool
  isNotEmpty str = not (isEmpty str)

  numberLines :: (String -> Bool) -> (String -> Bool) -> [String] -> NumberedLines
  numberLines shouldIncr shouldNumber text =
    let go :: Int -> [String] -> NumberedLines
        go _ [] = []
        go counter (x : xs) =
          let mNumbering = if shouldNumber x then Just counter else Nothing
              newCounter = if shouldIncr x then counter + 1 else counter
           in (mNumbering, x) : go newCounter xs
     in go 1 text

  -- then we can rewrite numberAllLines
  numberAllLines :: [String] -> NumberedLines
  numberAllLines text = numberLines (const True) (const True) text

  -- and eta reduced
  numberAllLines :: [String] -> NumberedLines
  numberAllLines = numberLines (const True) (const True)

  numberNonEmptyLines :: [String] -> NumberedLines
  numberNonEmptyLines = numberLines (const True) isNotEmpty

  numberAndIncrementNonEmptyLines :: [String] -> NumberedLines
  numberAndIncrementNonEmptyLines = numberLines isNotEmpty isNotEmpty

  ```

- In haskell, you can partially apply a function. `const x = (\_ -> x)` returns
  unary function `(_ -> True)` when called as `const True`.
- Eta reduction is dropping a redundant argument (and its lambda/parameter)
  when a function is defined as "take an argument, then immediately apply
  another function to it." Formally: `\x -> f x` is equivalent to just `f`,
  so you can eta-reduce the former to the latter.
  The rule only applies when the argument being dropped appears nowhere else
  in the body except as that final, direct application, if xs got used twice,
  or transformed before being passed to map, you couldn't eta-reduce.
- Don't let the name throw you. Eta reduction is a simple concept. Consider the
  following function that can be reduced twice because it is only applying
  a function to its two arguments and using them nowhere else other than in
  the final application:

  ```hs
  upperRot :: Int -> Char -> Char
  upperRot n ch = alphabetRot upperAlphabet n ch
  
  -- eta reduced - the type doesn't change; only the arguments
  upperRot :: Int -> Char -> Char
  upperRot = alphabetRot upperAlphabet
  ```

- Remember our *algebraic data type* Maybe? It is defined using the `data`
  keyword to define the constructors as follows:
  `data  Maybe a  =  Nothing | Just a` . An important feature of these
  constructors is that they can be pattern matched. These make it easy to use
  them to express a *sum type*. A *sum type*, also known as a *tagged union*, is
  a data type that consists of a finite number of constructors of fixed types
  but only a single one at a time. The types are associated with a name (the
  *tag*) which can be used to mark whether we want to pad left or right:
  `data PadMode = PadLeft | PadRight`. Just like types created with `type`, we
  need to add types created with `data` to the export list. We are also going
  to use a `case` keyword to pattern match on our constructors:

  ```hs
  pad :: PadMode -> Int -> String -> String
  pad mode n str =
    let diff = n - length str
        padding = replicate diff ' '
     in case mode of
          PadLeft -> padding ++ str
          PadRight -> str ++ padding
  ```

- This is a good example of thinking about the order of our arguments. `mode` is
  most likely to be set in advance, then `n`, and finally the `str` or data we
  operate on is the most likely to vary.
- In Haskell, case is semantically load-bearing for the first letter of every
  identifier - lowercase-first is always a function/variable/type-class-method,
  uppercase-first is always a type name or a data constructor, no exceptions.
- `zip` takes two Lists and combines them into a single list of tuples, stopping
  at the end of the shorter of the two Lists. `unzip` reverses this process.
  `zipWith` takes a function and two lists and combines matching elements of the
  two lists using the function.
- The `maybe` function is a built-in utility from the `Data.Maybe` module that
  safely extracts and processes a value contained within a Maybe wrapper,
  providing a fallback option if no value exists. It evaluates a Maybe value
  by applying a function if it contains data (Just x) or returning a default
  value if it is empty (Nothing).

  ```hs
  ys = [Just 1, Just 2, Nothing, Just 4] :: [Maybe Int]
  map (maybe "" show) ys  -- ["1", "2", "", "4"]
  ```

- That use of `maybe` along with `unzip` and `zipWith` are all we need for
  `prettyNumberedLines`:

  ```hs
  prettyNumberedLines :: PadMode -> NumberedLines -> [String]
  prettyNumberedLines mode lineNums =
    let (numbers, text) = unzip lineNums
        numberStrings = map (maybe "" show) numbers
        maxLength = maximum (map length numberStrings)
        paddedNumbers = map (pad mode maxLength) numberStrings
     in zipWith (\n l -> n ++ " " ++ l) paddedNumbers text
  ```

- `prettyNumberedLines` is doing a lot here, but it's all simple composable
  operations:

  1. `unzip` takes the list of tuples apart into a tuple of lists.
  2. `map (maybe "" show) numbers` transforms line numbers into a string
     representation and missing values (Nothing) to empty strings.
  3. `maximum (map length numberStrings)` computes the maximum length of the
     line numbers.
  4. `map (pad mode maxLength) numberStrings` pads them to maximum length.
  5. `zipWith` concatenates the padded numbers with the actual lines.
- The `let` syntax works well with a divide-and-conquer approach where you
  split a big task up into small individual steps and put them together.
- The function prefix *pretty* is usually used for functions that transform
  some data into a human-readable form.
- Now we need to print all our lines. `map` won't work for this, because it
  applies a pure function to each element, but Haskell provides `mapM` and
  `mapM_` to perform an action on a list of elements. `mapM` is just like
  `map`. It returns a list of `Unit` when applying an action to a list of
  values. `mapM_` is more useful when you aren't concerned with output, since
  it returns `Unit` alone; ignoring the output.
- So we're ready to integrate this with `main`:

  ```hs
  main :: IO ()
  main = do
    cliArgs <- getArgs
    let mFilePath = parseArguments cliArgs
    maybe
      (printHelpText "Missing filename")
      ( \filePath -> do
          fileLines <- readLines filePath
          let numbered = numberAllLines fileLines
              prettyNumbered = prettyNumberedLines PadLeft numbered
          mapM_ putStrLn prettyNumbered
      )
      mFilePath
  ```

- Now there are two ways to run this and see it work. From ghci, you can type
  `:set args testFile.txt` and call `main`, or from the project directory you
  can call `stack run -- testFile.txt`.
- Now we need to process more command line options than just `filePath`. We
  want to also process `--reverse`, `--skip-empty`, and `--left-align`.
- We have three possible options, we will represent them with an ADT:

  ```hs
  data LineNumberOption
    = ReverseNumbering
    | SkipEmptyLines
    | LeftAlign
    deriving (Eq)

  lnOptionFromString :: String -> Maybe LineNumberOption
  lnOptionFromString "--reverse"    = Just ReverseNumbering
  lnOptionFromString "--skip-empty" = Just SkipEmptyLines
  lnOptionFromString "--left-align" = Just LeftAlign
  lnOptionFromString _ = Nothing

  let numberFunction =
  if SkipEmptyLines `elem` options
    then numberNonEmptyLines 
    else numberAllLines 
  ```

- To simplify things, we're assuming the `filePath` will be the last argument.
- We can assign functions to variables, so it is easy to choose which functions
  we need based upon options.
- The full code is available in the repo, but let's look at the final `main`:

  ```hs
  main :: IO ()
  main = do
    cliArgs <- getArgs

    let (mFilePath, options) = parseArguments cliArgs

        numberFunction =
          if SkipEmptyLines `elem` options
            then numberNonEmptyLines
            else numberAllLines

        padMode =
          if LeftAlign `elem` options
            then PadRight
            else PadLeft

        go filePath = do
          fileLines <- readLines filePath
          let numbered = numberFunction fileLines
              prettyNumbered = prettyNumberedLines padMode numbered
              revNumbered = numberFunction (reverse fileLines)
              revPretty = reverse (prettyNumberedLines padMode revNumbered)
          mapM_
            putStrLn
            ( if ReverseNumbering `elem` options
                then revPretty
                else prettyNumbered
            )

    maybe
      (printHelpText "Missing filename")
      go
      mFilePath
  ```

## Chapter 5 - Words and graphs

- In this chapter, we will play a word chain game. You start with two words of
  the same length; one is the start and the other the end. The task is to find
  a chain of other words that link the starting word to the ending word, where
  each adjacent pair of words differs by a single letter. To do this we will
  model graphs in Haskell and explore the basics of type classes. We have a
  problem though that the game is too easy as described for a computer, so we
  will complicate it by not only allowing the player to change a single letter
  but to also add a completely new letter, remove a letter, and also reorder
  the letters arbitrarily.
  Example: find (d->s)-> fins (f->o)-> ions (+l)-> loins (+t)-> tonsil (+o)->
  lotions (+u)-> solution.
  This modified problem is hard enough we need to think about
  performance and minimizing unnecessary work.
- We assume that our artificial intelligence has a complete list of English
  words. To find a valid chain, it needs to find a path from one word to the
  other with a valid transformation. We can assume all words to be arranged
  in a graph where an edge between two words is present iff we can reach one
  word from the other in a single step, with each word being a node.
- We discussed different ways to model our graph. One of the simplest methods
  for an undirected graph is the *associative list*,
  `type Graph a = [(a, a)]`, a list of tuples where
  each tuple represents a key-value pair. There are performance drawbacks to
  this. Worst case, checking an edge exists as well as gathering children of
  a given node forces us to scan the whole list, as does inserting a new edge
  since we have to check for duplicates. Instead we are going to use an
  *adjacency map*, `type Digraph a = [(a, [a])]`. Since we're using it to
  model an undirected graph, we have to insert two elements for any given
  edge. It also takes more memory to store. If it was an actual map it
  would have O(1) lookups, but since the way the book defined it, it is
  still a list of tuples. It's not O(1), but it's still an improvement:
  the association list has one entry per edge, so finding all of a node's
  neighbors can force a scan of the entire list since a match could be
  anywhere. The adjacency map has one entry per node instead, so once
  that entry is found (still a linear scan, just over nodes instead of
  edges), the whole neighbor list comes with it and checking a specific
  edge only means searching that one node's neighbors. Real O(1) would
  need an actual hash map or similar (`Data.Map` gets O(log n) instead).
  However, the book says that is what we are starting with, so we will see.
  As an exercise, we are actually going to create our own functions for working
  with this type rather than simply importing say `Data.Map`. The main
  advantage to what we're calling an *adjacency map* is on the query side:
  building it isn't clearly cheaper than the *association list* in the
  worst case, since we still have to scan to find a node's entry before
  updating it. But once built, it is only one search to collect all the
  children of a node, since we store them as a list associated with the
  node itself, so repeated queries (like the ones a BFS search does at
  every step) aren't redoing multiple expensive "children collection"
  searches over the whole list every time.
- We create the new `ladder` stack project with `stack new` and add a
  `Graph.hs` to the src folder for our Graph functions. Remember, the
  `Graph.hs` file should contain the `Graph` module. We can also put modules
  in subdirectories but that should be reflected in the name. For example,
  `Foo/Bar/Module.hs` should contain `Foo.Bar.Module`. We normally capitalize
  the subdirectory names.
- To create a graph, we need to be able to add an element to a graph. But to
  add an element to a graph, first we need to see if it is already there.
  So we will start with `member`:

  ```hs
  member :: a -> [(a, b)] -> Bool
  member _ [] = False
  member x ((x', _) : xs)
    | x' == x = True
    | otherwise = member x xs
  ```

- We immediately run into the issue we are using `(==)` without the `Eq`
  type class, which gives us an opportunity to learn about type classes.
  We can get info about `Eq` from ghci with `:info Eq`. It defines `(==)`
  and/or `(/=)` (whichever is undefined defaults to the negation of the
  other).
- If you are familiar with object-oriented programming, type classes use
  similar terminology but should never be confused. Type classes cannot be
  instantiated as objects and methods do not behave like class methods.
  If you must use an OOP
  concept, type classes share more with interfaces than classes.
- We can fix our `member` definition by adding a *type constraint* on `Eq`.

  ```hs
  member :: Eq a => a -> [(a, b)] -> Bool
  member _ [] = False
  member x ((x', _) : xs)
    | x' == x = True
    | otherwise = member x xs
  ```

- A *type constraint* specifies which properties have to hold for the
  polymorphic types we use. In this case `a` can be anything that has an
  instance of the `Eq` type class. If we were using `Int` instead of `a`,
  we wouldn't need the `Eq` part because the compiler knows the concrete type
  `Int` is an instance of `Eq`.

  ```hs
  hasNode :: (Eq a) => Digraph a -> a -> Bool
  hasNode = flip member

  addNode :: Eq a => DiGraph a -> a -> DiGraph a
  addNode graph node
    | graph `hasNode` node = graph
    | otherwise = (node, []) : graph
  ```

- We need a general purpose way to `alter` our graph so we can `addEdge`.

  ```hs
  alter :: Eq k => (Maybe v -> Maybe v) -> k -> [(k, v)] -> [(k, v)]
  alter f key [] =
    case f Nothing of
      Nothing -> []
      Just value -> [(key, value)]
  alter f key ((key', value') : xs)
    | key == key' =
      case f (Just value') of
        Nothing -> xs
        Just value -> (key, value) : xs
    | otherwise =
      (key', value') : alter f key xs
  ```

- When we call `alter` with `const Nothing`, it will delete existing keys.
  `alter` with `const (Just 4)` and a new key will add `(4, 4)`.
  `alter` with `maybe Nothing (const (Just 0))` with add a node with an existing
  key and do nothing with a non-existing key.

  ```hs
  ghci> myAssocList = [(1,1), (2,2), (3,3)]  :: [(Int, Int)]
  ghci> myAssocList
  [(1,1),(2,2),(3,3)]
  ghci> alter (const Nothing) 1 myAssocList
  [(2,2),(3,3)]
  ghci> alter (const (Just 4)) 4 myAssocList
  [(1,1),(2,2),(3,3),(4,4)]
  ghci> alter (maybe Nothing (const (Just 0))) 1 myAssocList
  [(1,0),(2,2),(3,3)]
  ghci> alter (maybe Nothing (const (Just 0))) 4 myAssocList
  [(1,1),(2,2),(3,3)]
  ```

- `alter` is clearly a function of associative maps and not just a graph
  function though, so it doesn't belong in `Graph.hs`. We will define a new
  `Data.AssocMap` module for the `member` and `alter` functions. We put it in
  `Data` to signify we're defining the type and functions of a data type.
  We are going to give `AssocMap` it's own constructor to hide that it's just
  a `List`, since our invariant is that each key only appears once. Since
  `AssocMap` has a single constructor with a single field, we can define
  it with `newType` instead of `data`. Why we are using `newtype` is further
  explained in Appendix B.

  ```hs
  newtype AssocMap k v = AssocMap [(k, v)]
  ```

- It is standard practice to name the constructor in a `newtype` definition
  the same as the type itself. If we export `AssocMap` but not `AssocMap (..)`, 
  the constructor will be exported but not the type. There are two ways we
  could handle the new type for our functions:

  1. Add the new constructor to every expressions that deals with associative
     lists.
  2. Construct a wrapper for each function for the new type using the old
     functions on lists.

  It is more canonical to do the first since we want to define functions for
  this type, but the second option allows us to construct functoins for the
  type from any function on lists of tuples, so we will choose the latter which
  also makes our code easier to read. We will also use the `where` keyword to
  define internal definitions within functions like `let` except the definitions
  come after they have been used.

  ```hs
  module Data.AssocMap
    ( AssocMap,
      member,
      alter,
    )
  where

  newtype AssocMap k v = AssocMap [(k, v)]

  member :: Eq k => k -> AssocMap k v -> Bool
  member key (AssocMap xs) = member' key xs
    where
      member' :: Eq k => k -> [(k, v)] -> Bool
      member' _ [] = False
      member' x ((x', __) : xs)
        | x' == x = True
        | otherwise = member' x xs

  alter :: Eq k => (Maybe v -> Maybe v) -> k -> AssocMap k v -> AssocMap k v
  alter f key (AssocMap xs) = AssocMap (alter' f key xs)
    where
      alter' :: Eq k => (Maybe v -> Maybe v) -> k -> [(k, v)] -> [(k, v)]
      alter' f key [] =
        case f Nothing of
          Nothing -> []
          Just value -> [(key, value)]
      alter' f key ((key', value') : xs)
        | key == key' =
          case f (Just value') of
            Nothing -> xs
            Just value -> (key, value) : xs
        | otherwise =
          (key', value') : alter' f key xs
  ```

- We still have the problem that we cannot create an `AssocMap` without the
  constructor, so we'll export an `empty` function to create an empty
  `AssocMap` along with `delete` and `insert` functions to build up
  `AssocMap` values.

  ```hs
  empty :: AssocMap k v
  empty = AssocMap []

  delete :: Eq k => k -> AssocMap k v -> AssocMap k v
  delete = alter (const Nothing)

  insert :: Eq k => k -> v -> AssocMap k v -> AssocMap k v
  insert key value = alter (const (Just value)) key
  ```

- But it's time to learn another type class. The `Show` type class is used to
  provide the `show` function, which transforms a Haskell type into a `String`.
  If we test our new `AssocMap`, ghci can't show the results because we don't
  have `show`. However, it can be automatically derived! Note that `show` isn't
  meant to provide human-readable representations of Haskell values. It is the
  dual to the `Read` type class, which provides automatically generated parsers
  for Haskell values.

  ```hs
  newtype AssocMap k v = AssocMap [(k, v)]
    deriving (Show)
  ```

- So now we can test our functions.

  ```hs
  ghci> insert 'a' "World" (insert 'b' "Hello" empty)"
  AssocMap [('b', "World"), ('a', "Hello")]
  ghci> delete 'a' (insert 'a' "Delete me!" empty)
  AssocMap []
  ``````

- It's generally possible to derive `Show` anytime the underlying types are
  in `Show`. Likewise, you can derive `Eq` if you want `(--)` to be defined
  as *structural equivalent. Two values are equal if their constructors and
  fields are equivlaent.
- We are going to define our own `lookup` so we will 
  `import Prelude hiding (lookup)`. Otherwise we would have `Prelude.lookup`
  and `Data.AssocMap.lookup`. We are also going to define `findWithDefault`
  that returns a default value if key isn't found.

  ```hs
  lookup :: (Eq k) => k -> AssocMap k v -> Maybe v
  lookup key (AssocMap xs) = lookup' key xs
    where
      lookup' _ [] = Nothing
      lookup' key ((key', value) : xs)
        | key == key' = Just value
        | otherwise = lookup' key xs

  findWithDefault :: (Eq k) => v -> k -> AssocMap k v -> v
  findWithDefault defaultValue key map =
    case lookup key map of
      Nothing -> defaultValue
      Just value -> value
  ```

- Since we want to use names defined in Prelude, it's a good time to learn
  qualified imports. `import qualified Data.AssocMap as M` will give us
  `M.lookup` and leave `lookup` alone. Now we're ready to define some functions
  in Graph.hs.

  ```hs
  type DiGraph a = M.AssocMap a [a]
  -- ...
  addEdge :: (Eq a) => (a, a) -> DiGraph a -> DiGraph a
  addEdge (node, child) = M.alter insertEdge node
   where
    insertEdge Nothing = Just [child]
    insertEdge (Just nodes) =
      Just (L.nub (child : nodes))

  addEdges :: (Eq a) => [(a, a)] -> DiGraph a -> DiGraph a
  addEdges [] graph = graph
  addEdges (edge : edges) graph = addEdge edge (addEdges edges graph)

  buildDiGraph :: (Eq a) => [(a, [a])] -> DiGraph a
  buildDiGraph nodes = go nodes M.empty
   where
    go [] graph = graph
    go ((key, value) : xs) graph = M.insert key value (go xs graph)

  children :: (Eq a) => a -> DiGraph a -> [a]
  children = M.findWithDefault []
  ```
