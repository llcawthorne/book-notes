#!/usr/bin/env runhaskell
-- calculate Fibonacci numbers in logarithmic time

module Main where
import System

fib n = fib' 1 0 0 1 n
  where fib' a b p q 0 = b
        fib' a b p q n | even n =
          fib' a b (p^2 + q^2) (q^2 + 2 * p * q) (n `div` 2)
        fib' a b p q n =
          fib' (b * q + a * q + a * p) (b * p + a * q) p q (n - 1)

main = getArgs >>= (putStrLn . show . fib . read . head)
