#!/usr/bin/env runhaskell

-- Sieve of Eratosthenes
-- Input:  An integer n >= 2
-- Output: List of all prime numbers less than or equal to n.
sieve_erat :: Integer -> [Integer]
sieve_erat n | n <= 1    = error "Sieve undefined for n <= 1!"
             | otherwise = takeWhile (<= n) primes

primes :: [Integer]
primes = sieve [2..]
  where
      sieve (p:xs) = p : sieve [x|x <- xs, x `mod` p > 0]

main :: IO ()
main = do
  print $ show (primes !! 10000)

