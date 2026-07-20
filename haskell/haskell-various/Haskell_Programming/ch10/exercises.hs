-- exercises.hs
module Exercises where

stops  = "pbtdkg"
vowels = "aeiou"
-- 1a
onea = [(s, v, s') | s <- stops, v <- vowels, s' <- stops]
-- 1b
oneb = [(s, v, s') | s <- stops, v <- vowels, s' <- stops, s=='p']
-- 1c
nouns = ["the cat", "the baby", "Lewis", "a fireman"]
verbs = ["ran", "walked", "programmed", "rescued"]
onec = [(n, v, n') | n <- nouns, v <- verbs, n' <- nouns]

ilike  = "I like to eat eat eat apples and bananas"
ilike4 = replicate 4 ilike

-- 2 - find the integral average of the length of the words in a sentence
seekritFunc x =
  div (sum (map length (words x)))
      (length (words x))

-- 3
seekritFrac x =
  fromIntegral (sum (map length (words x))) 
  / fromIntegral (length (words x))

-- Rewriting functions using folds, with alternate point free versions!
myAnd :: [Bool] -> Bool
myAnd = foldr (\a b -> if a == False then False else b) True

myAnd' :: [Bool] -> Bool
myAnd' = foldr (&&) True

-- 1) myOr
myOr :: [Bool] -> Bool
myOr = foldr (\a b -> if a == True then True else b) False

myOr' :: [Bool] -> Bool
myOr' = foldr (||) False

-- 2) myAny
myAny :: (a -> Bool) -> [a] -> Bool
myAny p xs = foldr (\a acc -> if p a then True else acc) False xs

myAny' :: (a -> Bool) -> [a] -> Bool
myAny' p xs = myOr' $ map p xs

myAny'' :: (a -> Bool) -> [a] -> Bool
myAny'' f = foldr ((||) . f) False

-- 3) myElem
myElem :: Eq a => a -> [a] -> Bool
myElem x = foldr (\a acc -> a == x || acc) False

myElem' :: Eq a => a -> [a] -> Bool
myElem' x = any (x==)

myElem'' :: Eq a => a -> [a] -> Bool
myElem'' x = foldr ((||) . (x==)) False

-- 4) myReverse
myReverse :: [a] -> [a]
myReverse = foldl (flip (:)) []

-- 5) myMap
myMap :: (a -> b) -> [a] -> [b]
myMap f = foldr ((:) . f) [] 

-- 6) myFilter
myFilter :: (a -> Bool) -> [a] -> [a]
myFilter p xs = foldr (\a acc -> if p a then a : acc else acc) [] xs

myFilter' :: (a -> Bool) -> [a] -> [a]
myFilter' p = foldr (\a acc -> if p a then a : acc else acc) [] 

-- 7) squish
squish :: [[a]] -> [a]
squish = foldr (++) []

-- 8) squishMap
squishMap :: (a -> [b]) -> [a] -> [b]
squishMap f = foldr ((++) . f) []

-- 9) squishAgain
squishAgain :: [[a]] -> [a]
squishAgain = squishMap id

-- 10) myMaximumBy
myMaximumBy :: (a -> a -> Ordering) -> [a] -> a
myMaximumBy f xs = foldr (\a acc -> if f a acc == GT then a else acc) (last xs) xs

-- 10) myMinimumBy
myMinimumBy :: (a -> a -> Ordering) -> [a] -> a
myMinimumBy f xs = foldr (\a acc -> if f a acc == LT then a else acc) (last xs) xs
