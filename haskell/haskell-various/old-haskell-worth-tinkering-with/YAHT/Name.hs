-- A simple program to ask the user for his name, then say Hello Name!
--
-- we named the module Main so we can compile it if we chose
module Main
    where

import IO

-- we named this function main, so if we compile it, it will autorun main
-- the do is required to tell Haskell to perform the next series 
-- of operations in order (which we need, since they are IO)
main = do
    -- this sets input to LineBuffering instead of BlockBuffering
    -- normally the program would try to read a large block
    hSetBuffering stdin LineBuffering

    -- no () required:
    putStrLn "Please enter your name: "

    -- run getLine and store results in name
    name <- getLine
    
    -- ++ to concat.  () required, because function is higher priority than ++
    putStrLn ("Hello, " ++ name ++ ", how are you?")
