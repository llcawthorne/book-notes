
-- first example in lesson-22-sum.hs

-- QC 22.1
getMain :: IO ()
getMain = do
  putStrLn "Enter three lines of input:"
  vals <- mapM (\_ -> getLine) [1..3]
  mapM_ putStrLn vals

-- We've seen the following:
-- mapM - takes an IO action and a regular list, performs the action on each
--        item in the list, and returns a list in the IO context
-- mapM_ - Same as mapM, but throws away the values returned
-- replicateM - takes an IO action, an Int n, and then repeats the IO action
--              n times, returning the results in an IO list
-- replicateM_ = same as replicateM, but it throws away the results

-- QC 22.2
myReplicateM n f = mapM (\_ -> f) [1 .. n]

-- next example in lesson-22-sum-lazy.hs

-- QC 22.3
reverseIt :: IO ()
reverseIt = do
  input <- getContents
  let reversed = reverse input
  putStrLn reversed

-- QC 22.4
toInts :: String -> [Int]
toInts = map read . lines

main :: IO ()
main = do
  userInput <- getContents
  let numbers = toInts userInput
  let squares = map (^2) numbers
  print (sum squares)

-- Q22.1
-- in lesson-22-simple-calc.hs

-- Q22.2
-- in lesson-22-quotes.hs
