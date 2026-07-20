#!/usr/bin/env runhaskell
import System

fib 0 = 0
fib 1 = 1
fib n = fib (n-2) + fib (n-1)

main = getArgs >>= (putStrLn . show . fib . read . head)
