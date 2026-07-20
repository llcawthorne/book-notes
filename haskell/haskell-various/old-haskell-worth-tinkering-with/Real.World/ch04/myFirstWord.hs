-- file ch04/myFirstWords.hs
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
fixLines input = unlines (splitFW input)

-- get the first word of each line
splitFW :: String -> [String]
splitFW [] = []
splitFW cs = map fst $ map (break isSpace) (lines cs)
