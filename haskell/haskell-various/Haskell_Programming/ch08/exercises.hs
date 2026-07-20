-- exercises.hs
module Exercises where
import Data.List (intersperse)

-- 1) d, [[Bool]]
-- 2) b
-- 3) d
-- 4) b

-- Reviewing currying
cattyConny :: String -> String -> String
cattyConny x y = x ++ " mrow " ++ y

flippy = flip cattyConny

appedCatty = cattyConny "woops"
frappe = flippy "haha"

-- 1) "woops mrow woohoo!"
-- 2) "1 mrow haha"
-- 3) "woops mrow 2 mrow haha"
-- 4) "woops mrow blue mrow haha"

-- Recursion
-- 1) dividedBy 15 2 = 7
-- 2) 
sumtorial 0 = 0
sumtorial n = n + sumtorial (n - 1)
-- 3)
mult n 0 = 0
mult n 1 = n
mult n x = n + mult n (x-1)

-- McCarthy 91 function
mc91 n 
    | n > 100   = n - 10
    | otherwise = 91

-- Numbers into words
digitToWord :: Int -> String
digitToWord 0 = "zero"
digitToWord 1 = "one"
digitToWord 2 = "two"
digitToWord 3 = "three"
digitToWord 4 = "four"
digitToWord 5 = "five"
digitToWord 6 = "six"
digitToWord 7 = "seven"
digitToWord 8 = "eight"
digitToWord 9 = "nine"
digitToWord _ = "unknown"

digits :: Int -> [Int]
digits 0 = []
digits n = digits (n `div` 10) ++ [n `mod` 10]

wordNumber :: Int -> String
wordNumber n = concat $ intersperse "-" $ map digitToWord (digits n)
