# Learn Haskell by Example

## Chapter 2 - Ancient secret keeping on modern machines

- Use `:{` and `:}` for multi-line ghci commands.
- Use `{-` and `-}` for multi-line comments and `--` for single-line comments.
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

- When using local variables fo some Maybe type, it is common to prefix the
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
