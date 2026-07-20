
-- Chapter 9 - Input and Output
-- Or, Let's Finally Write 'Hello World!'

import Data.Char  -- for later
-- we will use Control.Monad later also for 'when'
import Control.Monad
-- This is for working with files
import System.IO

-- single action is as simple as it gets:
-- main = putStrLn "hello, world"
-- putStrLn is type IO ()  -- it returns an empty tuple encapsulated by IO
-- '<-' removes the value from the "IO box" if you will...
-- foo <- putStrLn "test" would result in foo being ()

-- do binds together multiple IO actions in order
main = do
    putStrLn "Hello, what's your name?"
    name <- getLine
    putStrLn ("Hey " ++ name ++ ", you rock!")
-- getLine is type IO String, but name is just String
-- name is considered untainted and can be used in pure code
-- nameTag = "Hello, my name is " ++ getLine   will not work
-- nameTag = "Hello, my name is " ++ name  will after a 'name <- getLine'
-- the '<-' operator takes the result out of the IO action
--
-- The final action is a do block is bound to the initial name, so
-- in the previous example 'main' is type IO () (like the final putStrLn).
-- We cannot bind the final action of a do block to something else!
--
-- Remember: 
-- NOT name = getLine  this just gives getLine a new synonym
-- name <- getLine     extracts the String returned by getLine to name
--
-- IO Actions will only be performed when they are given a name of main
-- or when they are inside a bigger IO action that is composed with a
-- do block.  If they don't fall into main, they don't happen 
-- in a compiled version of the program.  This works fine from GHCI though:
anothermain = do
    putStrLn "What's your first name?"
    firstName <- getLine
    putStrLn "What's your last name?"
    lastName  <- getLine
    let bigFirstName = map toUpper firstName
        bigLastName  = map toUpper lastName
    putStrLn $ "hey " ++ bigFirstName ++ " " ++ bigLastName ++ ", how are you?"
-- I can compile this program though, and main will be what runs.
--
-- Remember to use <- to bind results from IO to names.
--
-- in a normal program, the following could be main:
reverso = do
    line <- getLine
    if null line
        -- if line is null, we are done.  
        -- return () makes an IO action from a pure value.
        then return()
        -- do here binds the next two IO actions into one
        else do
            putStrLn $ reverseWords line
            reverso

reverseWords :: String -> String
-- words splits the string into a list of words
-- mapping reverse onto the list reverses each word
-- unwords combines the list into one large string
reverseWords = unwords . map reverse . words
-- it takes an input line and reverses all the letters
--
-- Let's cover some various IO functions.
-- 'putStrLn' we have seen.  'putStr' does the same without a newline
-- 'putChar' prints a char
-- 'putStr' is actually defined something like:
-- putStr :: String -> IO ()
-- putStr [] = return ()
-- putStr (x:xs) = do
--      putChar x
--      putStr  xs
-- 'print' takes a value of any type that's an instance of Show
charToAscii = do
    putStr "Enter a char: "
    mychar <- getChar
    if mychar == '~'
        then 
            putStrLn ""
        else do
            putChar '\t'
            print $ ord mychar
            charToAscii
-- 'print' is equivalent to putStrLn . show 
-- 'print' is what GHCI uses to display what we type at the prompt
-- 
-- If we know we are working with strings, putStr and putStrLn are
-- generally used, so we don't display quotes around them.
-- print is used the most when the values might be other types.
--
-- 'getChar' gets a char.  'putChar' outputs a char.
--
-- 'when' from Control.Monad takes a Bool and an IO action
-- If the bool is True, it returns the IO action
-- If the bool is False, it returns ().
getCharTest = do
    c <- getChar
    when (c /= ' ') $ do
        putChar c
        getCharTest
-- 'when' is basically a short way to do the 
-- if something then do some IO else return()  pattern.
--
-- 'sequence' takes a list of IO actions and returns a list of results
-- main = do
--      a <- getLine
--      b <- getLine
--      c <- getLine
--      print [a,b,c]
-- -- is equivalent to:
-- main = do
--      rs <- sequence [getLine, getLine, getLine]
--      print rs
-- 'sequence' is oftne used with 'map print'
-- 'sequence (map print [1,2,3,4,5])'   prints each number separated by '\n'
-- this is common, so we have:
-- 'mapM' and 'mapM'
-- both take a function and a list and map the function over the list
--      and then sequnce the result.  mapM_ however throws away the result.
-- 'mapM_' works well with print (where our IO is the result we are after).
--
-- 'forever' takes an IO action and repeats it forever.  Its in Control.Monad
endlessScream = forever $ do
    putStr "Give me some input: "
    l <- getLine
    putStrLn $ map toUpper l
-- 'forM' from Control.Monad is like mapM with reversed parameters
-- it is great with creative lambdas and do's
forMFun = do
    colors <- forM [1,2,3,4] (\a -> do
        putStrLn $ "Which color do you associate with the number "
                 ++ show a 
                 ++ "?"
        color <- getLine
        return color)
    putStrLn "The colors that you associate with 1, 2, 3, and 4 are: "
    -- forM colors putStrLn  equivalent to:
    mapM_ putStrLn colors

-- Files and Streams
-- 'getContents' reads up to the EOF.  It's lazy though (which is good).
-- This would take all stdin up to EOF and convert it to upper case:
capslocker = do
     contents <- getContents
     putStr (map toUpper contents)

shortLinesOnly :: String -> String
shortLinesOnly input =
    let allLines = lines input
        shortLines = filter (\line -> length line < 10) allLines
        result = unlines shortLines
    in  result

-- this pattern is common
printShort = do
    contents <- getContents
    putStr (shortLinesOnly contents)

-- 'interact' makes this pattern simple
-- it takes a function of type String -> String and returns
-- an IO action that will take some input, run the function, 
-- then output the result
printShort' = interact shortLinesOnly

-- as a one liner (no call to shortLinesOnly)
printShortShort = interact $ unlines . filter ((<10) . length) . lines

respondPalindromes = 
    unlines . map (\xs -> if isPalindrome xs 
                            then "palindrome"
                            else "not a palindrome") . lines
    where isPalindrome xs = xs == reverse xs

testPalindromes = interact respondPalindromes

girlfriend = do
    handle <- openFile "girlfriend.txt" ReadMode
    contents <- hGetContents handle
    putStr contents
    hClose handle

haiku = do
    handle <- openFile "haiku.txt" ReadMode
    contents <- hGetContents handle
    putStr contents
    hClose handle

-- 'openFile' takes a FilePath (String) and an IOMode
--      it returns an IO Handle
-- type FilePath = String
-- data IOMode = ReadMode | WriteMode | AppendMode | ReadWriteMode
