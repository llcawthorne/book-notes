-- Problem 57 of Project Euler
-- Brute Force Method
import Data.Ratio

b57 :: Integer -> Rational
b57 n | n == 0          = 1
      | otherwise       = 1 + (1/(1+b57 (n-1)))

b57List = [b57 n | n <- [1..1000], numLength (numerator (b57 n)) > numLength(denominator (b57 n))]

numLength :: Integer -> Integer
numLength n | n == 0     = 0
            | otherwise  = 1 + numLength (div n 10)

yo :: Integer -> Integer
yo x = 3 * x