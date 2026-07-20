-- bottomMadness.hs
module BottomMadness where

-- 1) bottom
one = [x^y | x <- [1..5], y <- [2, undefined]]
-- 2) fine
two = take 1 $ [x^y | x <- [1..5], y <- [2, undefined]]
-- 3) bottom
three = sum [1, undefined, 3]
-- 4) fine
four = length [1, 2, undefined]
-- 5) bottom
five = length $ [1, 2, 3] ++ undefined
-- 6) fine
six = take 1 $ filter even [1, 2, 3, undefined]
-- 7) bottom
seven = take 1 $ filter even [1, 3, undefined]
-- 8) fine
eight = take 1 $ filter odd [1, 3, undefined]
-- 9) fine
nine = take 2 $ filter odd [1, 3, undefined]
-- 10) bottom
ten = take 3 $ filter odd [1, 3, undefined]
