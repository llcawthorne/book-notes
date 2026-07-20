-- exercises.hs
module Exercises where

import Data.Char

-- 1) Char -> Bool and Char -> Char
-- 2)
filterLower :: String -> String
filterLower = filter isUpper

two = filterLower "HbEfLrLxO"
-- 3)
capFirst :: String -> String
capFirst ""     = ""
capFirst (x:xs) = toUpper x : xs
-- 4)
capAll :: String -> String
capAll ""     = "!!!"
capAll (x:xs) = toUpper x : capAll xs
-- 5)
capFirstOnly :: String -> Char
capFirstOnly ""     = ' '
capFirstOnly (x:xs) = toUpper x
-- 6)
capFirstOnly' :: String -> Char
capFirstOnly' = toUpper . head

-- see cipher.hs

-- Standard Functions
-- Ex: myAnd
-- direct recursion, not using (&&)
myAnd :: [Bool] -> Bool
myAnd []     = True
myAnd (x:xs) = if not x then False else myAnd xs

-- direct recursion, using (&&)
myAnd' :: [Bool] -> Bool
myAnd' []     = True
myAnd' (x:xs) = x && myAnd xs

-- 1) myOr
myOr :: [Bool] -> Bool
myOr []     = False
myOr (x:xs) = if x then True else myOr xs

myOr' :: [Bool] -> Bool
myOr' []     = False
myOr' (x:xs) = x || myOr xs

-- 2) myAny
myAny :: (a -> Bool) -> [a] -> Bool
myAny _ []     = False
myAny p (x:xs) = p x || myAny p xs

-- 3) myElem, two different ways
myElem :: Eq a => a -> [a] -> Bool
myElem x []    = False
myElem x (y:ys) 
   | x == y    = True
   | otherwise = myElem x ys

myElem' :: Eq a => a -> [a] -> Bool
myElem' x = any (x==) 

-- 4) myReverse
myReverse :: [a] -> [a]
myReverse []     = []
myReverse (x:xs) = myReverse xs ++ [x]

myReverse' :: [a] -> [a]
myReverse' = foldl (flip (:)) []

-- 5) squish
squish :: [[a]] -> [a]
squish []     = []
squish (x:xs) = x ++ squish xs

-- 6) squishMap
squishMap :: (a -> [b]) -> [a] -> [b]
squishMap _ []     = []
squishMap f (x:xs) = f x ++ squishMap f xs

-- 7) squishAgain
squishAgain :: [[a]] -> [a]
squishAgain = squishMap id

-- 8) myMaximumBy
myMaximumBy :: (a -> a -> Ordering) -> [a] -> a
myMaximumBy _ []        = undefined
myMaximumBy _ (x:[])    = x
myMaximumBy f (x:x':xs) 
    | f x x' == GT = myMaximumBy f (x:xs)
    | otherwise    = myMaximumBy f (x':xs)

-- 9) myMinimumBy
myMinimumBy :: (a -> a -> Ordering) -> [a] -> a
myMinimumBy _ []        = undefined
myMinimumBy _ (x:[])    = x
myMinimumBy f (x:x':xs)
    | f x x' == LT = myMinimumBy f (x:xs)
    | otherwise    = myMinimumBy f (x':xs)

-- 10) myMaximum and myMinimum using my_By above
myMaximum :: (Ord a) => [a] -> a
myMaximum = myMaximumBy compare

myMinimum :: (Ord a) => [a] -> a
myMinimum = myMinimumBy compare
