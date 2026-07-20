-- moreBottoms.hs
module MoreBottoms where
import Data.Bool

-- 1) bottom
one = take 1 $ map (+1) [undefined, 2, 3]
-- 2) fine
two = take 1 $ map (+1) [1, undefined, 3]
-- 3) bottom
three = take 2 $ map (+1) [1, undefined, 3]
-- 4) returns a list of True False for if each elt of a [Char] is a vowel
itIsMystery xs =
  map (\x -> elem x "aeiou") xs
-- 5a) [1, 4, 9, 16, 25, 36, 49, 64, 81, 100]
fivea = map (^2) [1..10]
-- 5b) [1, 10, 20]
fiveb = map minimum [[1..10], [10..20], [20..30]]
-- 5c) [15, 15, 15]
fivec = map sum [[1..5], [1..5], [1..5]]
-- 6)
sixex = map (\x -> if x == 3 then (-x) else (x)) [1..10]
six = map (\x -> bool x (-x) (x == 3)) [1..10]
