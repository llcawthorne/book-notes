
import Data.Ord
import Data.List

-- Write a function that computes the number of elements in a list. 
-- To test it, ensure that it gives the same answers as the standard length  function.
myLen :: [a] -> Int
myLen (_:xs) = 1 + myLen xs
myLen []     = 0

-- Write a function that computes the mean of a list, i.e. the sum of all 
-- elements in the list divided by its length. 
meanJean xs | length xs == 0 = 0
            | otherwise      = sum xs / fromIntegral (length xs)

-- Turn a list into a palindrome
palindromize :: [a] -> [a]
palindromize xs = xs ++ reverse xs

isPalindrome :: (Eq a) => [a] -> Bool
isPalindrome xs = xs == reverse xs

-- Create a function that sorts a list of lists based on the length of each sublist. 
-- (You may want to look at the sortBy function from the Data.List module.)
-- Here's there solutions:
sortSubLists xs = sortBy (comparing length) xs

sortSubLists' xs = sortBy (\a b -> compare (length a) (length b)) xs

sortSubLists'' xs = sortBy (isLonger) xs
                  where isLonger = comparing length

-- intersperse :: a -> [[a]] -> [a]
mintersperse :: a -> [[a]] -> [a]
mintersperse _ [] = []
mintersperse _ (x:[]) = x
mintersperse sep (x:xs) = x ++ [sep] ++ mintersperse sep xs
-- a guarded answer
inter :: (Eq a) => a -> [[a]] -> [a]
inter _ [] = []
inter e (x:xs) | xs /= [] = x ++ [e] ++ inter e xs
               | otherwise = x

-- find the height of a binary tree
data Tree a = Node a (Tree a) (Tree a)
            | Empty
              deriving (Show)

twoTree = Node 'c' Empty (Node 'd' Empty Empty)
fourTree = Node 'c' (Node 'a' Empty Empty) (Node 'd' (Node 'b' Empty (Node 'g' Empty Empty)) Empty)

treeHeight (Node _ t1 t2) | treeHeight t1 > treeHeight t2 = 1 + treeHeight t1
                          | otherwise                     = 1 + treeHeight t2
treeHeight Empty = 0
-- or with max instead of guards
hTree (Node _ left right) = 1 + max (hTree left) (hTree right)
hTree Empty               = 0

data Turn = LeftTurn
          | RightTurn
          | Straight
            deriving(Show, Eq)
type TwoDPoint = (Double, Double)

whatDirection :: TwoDPoint -> TwoDPoint -> Turn
whatDirection (a,b) (c,d) | b == d = Straight
                          | b < d  = RightTurn
                          | b > d  = LeftTurn
