-- A random number guessing game. 
module Main
    where

import IO
import Random

main = do
    -- use LineBuffering since we are doing small amounts of IO
    hSetBuffering stdin LineBuffering
    
    -- the <- instead of = lets us know that randomRIO is not
    -- a "real" function and may return different values
    -- randomRIO will give us an Int from 1-100 with this call
    num <- randomRIO (1::Int, 100)

    putStrLn "I'm thinking of a number between 1 and 100"
    doGuessing num

doGuessing num = do
    putStrLn "Enter your guess:"
    -- put whatever getLine returns into guess
    guess <- getLine
    -- read converts our guess to a numeric avalue
    let guessNum = read guess
    if guessNum < num
        then do putStrLn "Too Low!"
                doGuessing num
        else if guessNum > num
            then do putStrLn "Too High!"
                    doGuessing num
            else do putStrLn "You Win!!!"
