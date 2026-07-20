module Main where
import System.Environment

main :: IO()
main = do args <- getArgs
          let num1 = read (args !! 0)
          let num2 = read (args !! 1)
          putStrLn (args !! 0 ++ "+" ++ args !! 1 ++ "=" 
                   ++  show (num1 + num2))
          putStrLn (args !! 0 ++ "-" ++ args !! 1 ++ "=" 
                   ++  show (num1 - num2))
          putStrLn (args !! 0 ++ "*" ++ args !! 1 ++ "=" 
                   ++  show (num1 * num2))
          putStrLn (args !! 0 ++ "/" ++ args !! 1 ++ "=" 
                   ++  show (num1 / num2))
