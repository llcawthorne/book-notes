{- PSEUDOCODE:
 - main = read list of directories and their sizes
 -        decide how to fit them on CD-Rs
 -        print solution
 -}
-- First draft of ideas into Haskell
-- assumes we are piping output of du -sb to the program
-- Now including Parsec to parse du -sb input
module Main where
import Text.ParserCombinators.Parsec
 
-- parseInput parses output of "du -sb", which consists of many lines,
-- each of which describes single directory
parseInput = 
  do dirs <- many dirAndSize
     eof
     return dirs
 
-- Datatype Dir holds information about single directory - its size and name
data Dir = Dir Int String deriving Show
 
-- `dirAndSize` parses information about single directory, which is:
-- a size in bytes (number), some spaces, then directory name, which extends till newline
dirAndSize = 
  do size <- many1 digit
     spaces
     dir_name <- anyChar `manyTill` newline
     return (Dir (read size) dir_name)

main = do input <- getContents
          putStrLn ("DEBUG: got input: \n" ++ input)
          -- compute and print solution here
