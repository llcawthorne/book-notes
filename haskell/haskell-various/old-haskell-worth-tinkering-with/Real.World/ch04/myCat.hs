-- file: ch04/myCat.hs

import System.Environment (getArgs)

interactWith function inputFile = do
  input <- readFile inputFile
  function input

main = mainWith myFunction
  where mainWith function = do
          args <- getArgs
          case args of
            [input] -> interactWith function input
            _ -> putStrLn "error: exactly two arguments needed"

        -- replace "id" with the name of our function below
        myFunction = putStrLn
