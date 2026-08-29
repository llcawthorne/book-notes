module Main where

import DogsRule
import Hello
import System.IO

main :: IO ()
main = do
  hSetBuffering stdout NoBuffering
  putStr "Please input your name: "
  name <- getLine
  sayHello name
  dogs

concatUserInput :: IO String
concatUserInput = do
  x1 <- getLine
  x2 <- getLine
  return (x1 ++ x2)

twoo :: IO ()
twoo = do c  <- getChar
          c' <- getChar
          if c == c'
            then putStrLn "True"
            else return ()
