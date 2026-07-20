import Data.Ratio

divides :: Integer -> Integer -> Bool
divides d n = rem n d == 0

ld :: Integer -> Integer
ld n = ldf 2 n

ldf :: Integer -> Integer -> Integer
ldf k n | divides k n = k
        | k^2 > n     = n
        | otherwise   = ldf (k+1) n

prime0 :: Integer -> Bool
prime0 n | n < 1      = error "not a positive integer"
         | n == 1     = False
         | otherwise  = ld n == n

factors :: Integer -> [Integer]
factors n | n < 1       = error "argument not positive"
          | n == 1      = []
          | otherwise   = p : factors (div n p) where p = ld n

bdivisors :: Integer -> [Integer]
bdivisors n = filter (flip divides n) [1..n]

-- Problem 57 of Project Euler
-- Brute Force Method
b57 :: Integer -> Rational
b57 n | n == 0          = 1
      | otherwise       = 1 + (1/(1+b57 (n-1)))

b57List = [b57 n | n <- [1..1000], numLength (numerator (b57 n)) > numLength(denominator (b57 n))]

numLength :: Integer -> Integer
numLength n | n == 0     = 0
            | otherwise  = 1 + numLength (div n 10)
