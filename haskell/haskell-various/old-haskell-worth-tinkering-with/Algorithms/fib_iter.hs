#!/usr/bin/env runhaskell
import System

fib n = fib_iter 1 0 n
    where fib_iter a b n | n == 0    = b
                         | otherwise = fib_iter (a + b) a (n - 1)

phi = fib 100 / fib 99

main = getArgs >>= (putStrLn . show . fib . read . head)
