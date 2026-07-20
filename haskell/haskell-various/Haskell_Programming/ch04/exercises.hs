-- exercises.hs
module Exercises where

awesome = ["Papuchon", "curry", ":)"]
also = ["Quake", "The Simons"]
allAwesome = [awesome, also]

-- 1.  length :: [a] -> Int a

isPalindrome :: (Eq a) => [a] -> Bool
isPalindrome x =
  reverse x == x

myAbs :: Integer -> Integer
myAbs x = if x < 0 then -x else x

f :: (a, b) -> (c, d) -> ((b, d), (a, c))
f x y = ((snd x, snd y), (fst x, fst y))

x = (+)

g :: [a] -> Int
g xs = w `x` i
  where w = length xs
        i = 1

my_id :: a -> a
my_id = \x -> x

h :: (a, b) -> a
h (a, b) = a
