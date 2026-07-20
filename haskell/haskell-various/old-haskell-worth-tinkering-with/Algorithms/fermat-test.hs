#!/usr/bin/env runhaskell
import Random
import Test.QuickCheck   -- for easy randoms
-- this is very fast O(log n) for large numbers, but seems
-- unreliable for small numbers.  It can have "unlucky picks" in theory.
-- It wouldn't hurt to re-run the test on nums with a different seed.
--
-- Prime test based on Fermat's Little Theorem
-- First a way to exponentiate and mod in one step O(log n)
expmod :: Integer -> Integer -> Integer -> Integer
expmod base ex m | ex == 0       = 1
                 | mod ex 2 == 0 = mod ((expmod base (div ex 2) m)^2) m
                 | otherwise     = mod (base * (expmod base (ex - 1) m)) m
-- now for the test
fermat_test :: Integer -> Bool
fermat_test n = and (((expmod a n n) == a) : ((expmod b n n) == b) : [])
    where a      = fst duo
          b      = snd duo
          duo = generate 1 (mkStdGen 1) (randomDuo (n-1))

        

randomDuo :: Integer -> Gen (Integer, Integer)
randomDuo n = do
   x1 <- choose (1,n)
   x2 <- choose (1,n)
   return (x1, x2)

-- we need some random numbers
-- genRandom n = do x <- getStdRandom $ randomR (1,n)
--                 return x

-- genRandom :: Integer -> IO Integer
-- genRandom n = do
--     r1 <- getStdGen
--     let (x, r2) = randomR (1,(n-1)) r1
--     setStdGen r2
--     return x
