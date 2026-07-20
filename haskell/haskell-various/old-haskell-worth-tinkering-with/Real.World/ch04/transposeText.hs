-- file ch04/transposeText.hs
import System.Environment (getArgs)
import Data.Char

interactWith function inputFile outputFile = do
  input <- readFile inputFile
  writeFile outputFile (function input)

main = mainWith myFunction
  where mainWith function = do
          args <- getArgs
          case args of
            [input,output] -> interactWith function input output
            _ -> putStrLn "error: exactly two arguments needed"

        -- replace "id" with the name of our function below
        myFunction = fixLines

-- we need a function to map String -> String
-- fixLines wraps splitFW to do that
fixLines :: String -> String
fixLines input = unlines (transLines (lines input))

-- get the first word of each line
transLines :: [String] -> [String]
transLines [] = []
transLines lns | length lns == 0 = []
               | length lns == 1 = lns
               | otherwise       = transLine (take 2 lns) ++ transLines (drop 2 lns)

transLine :: [String] -> [String]
transLine ([[], []]) = []
transLine ([[], xs]) = [ ' ' : head xs : []] ++ transLine [[], emtail xs]
transLine ([xs, []]) = [head xs : ' ' : []] ++ transLine [emtail xs, []]
transLine ([xs, ys]) = [head xs : head ys : []] ++ transLine [emtail xs, emtail ys]

emtail [] = []
emtail [x] = []
emtail (x:xs) = xs

-- transLine lns | null (head lns) = [ ' ' : (head (last lns)) : []] ++ transLine [[], tail (last lns)]
--              | null (last lns) = [head (head lns) : ' ' : []] ++ transLine [tail (head lns), []]
--              | otherwise       = [head (head lns) : (head (last lns)) : []] ++ transLine [tail (head lns), tail (last lns)]
              
