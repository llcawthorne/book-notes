import System.Random

-- Hello World!
helloPerson :: String -> String
helloPerson name = "Hello" ++ " " ++ name ++ "!"

main :: IO ()
main = do
  putStrLn "Hello!  What's your name?"
  name <- getLine
  let statement = helloPerson name
  putStrLn statement

-- QC 21.1
-- name <- getLine gets the user input as a String

-- randomRIO in action
minDie :: Int 
minDie = 1

maxDie :: Int
maxDie = 6

main2 :: IO ()
main2 = do
  dieRoll <- randomRIO (minDie, maxDie)
  putStrLn (show dieRoll)

-- QC 21.2
-- Probably not.  It has type IO String, not IO ()
-- QC 21.3
-- No.  getLine is IO String.
--
-- Next example in lesson-21-pizza.hs

-- Q21.1
-- maybeMain :: Maybe String
-- maybeMain = do
--   name <- Map.lookup 1 maybeMap
--   let statement = helloPerson name
--   return statement

-- Q21.2
fasterFib n m 0 = m
fasterFib n m c = fasterFib (n+m) n (c-1)

fibMain :: IO ()
fibMain = do
  putStrLn "Enter a number:"
  numString <- getLine
  let num = read numString
  putStrLn ("Fibonacci number " ++ numString ++ " is " ++ show (fasterFib 0 1 num))
