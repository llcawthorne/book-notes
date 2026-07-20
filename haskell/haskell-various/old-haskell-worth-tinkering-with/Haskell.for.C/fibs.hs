#!/usr/bin/env runhaskell
-- tail recursive fib def
-- uses Int for speed, but overflows after 20 digits
-- it can generate the first 90 or so fibs in a blink
fib :: Int -> Int
fib n = fibGen 0 1 n
    
fibGen :: Int -> Int -> Int -> Int
fibGen a b n = case n of
    0 -> a
    n -> fibGen b (a + b) (n - 1)

-- same thing, but polymorphic
-- will output an Integer by default, but you can ask for something 
-- different (ie. fib 50 :: Int will give an Int)
fibPoly :: (Num a, Num b) => a -> b
fibPoly n = fibGenPoly 0 1 n

fibGenPoly :: (Num a, Num b) => b -> b -> a -> b
fibGenPoly a b n = case n of
    0 -> a
    n -> fibGenPoly b (a + b) (n - 1)

-- same thing with patterns
fibPat :: (Num a, Num b) => a -> b
fibPat n = fibGenPat 0 1 n

fibGenPat :: (Num a, Num b) => b -> b -> a -> b
fibGenPat a _ 0 = a
fibGenPat a b n = fibGenPat b (a + b) (n - 1)

-- this time it is just an infinite list to take from
fibs :: [Int]
fibs = 0 : 1 : [ a + b | (a, b) <- zip fibs (tail fibs)]

-- and again as Integer type
fibsL :: [Integer]
fibsL = 0 : 1 : [ a + b | (a, b) <- zip fibsL (tail fibsL)]

main = putStrLn . show $ fib 100
