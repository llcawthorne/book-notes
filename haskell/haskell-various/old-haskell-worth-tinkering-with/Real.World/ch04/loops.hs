-- file: ch04/IntParse.hs
import Data.Char (digitToInt) -- we'll need ord shortly
import Data.Char (toUpper)

-- asInt parses a String into an Int
asInt :: String -> Int
-- asInt (x:[]) = digitToInt x
asInt (x:xs) | x == '-'  = (-1) * asInt xs
             | otherwise = (digitToInt x * 10^length xs) + asInt xs
asInt []     = 0

-- this is more c-like (uses an accumulator)
cLikeAsInt :: String -> Int
cLikeAsInt xs = loop 0 xs

loop :: Int -> String -> Int
loop acc (x:xs) = loop acc' xs
                  where acc' = acc * 10 + digitToInt x
loop acc []     = acc

-- square all elts in a list
squareList :: [Double] -> [Double]
squareList (x:xs) = x*x : squareList xs
squareList []     = []

-- upper all the letters in a String
strUpper :: String -> String
strUpper (x:xs) = toUpper x : strUpper xs
strUpper []     = []

-- we haven't discussed map yet
strUpper' :: String -> String
strUpper' xs = map toUpper xs

-- using the accumulator improves performance
factorial 0   x = factorial 1 x
factorial acc 1 = acc
factorial acc x = factorial acc' (x-1)
                  where acc' = acc * x

-- but this works
alsoFact 1 = 1
alsoFact x = x * alsoFact (x-1)

-- so does this
andFact x = foldl (*) 1 [1..x]
