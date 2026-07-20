-- file: ch04/IntParse.hs
import Data.Char (digitToInt) -- we'll need ord shortly

asInt :: String -> Int
-- asInt (x:[]) = digitToInt x
asInt (x:xs) | x == '-'  = (-1) * asInt xs
             | otherwise = (digitToInt x * 10^length xs) + asInt xs
asInt []     = 0

cLikeAsInt :: String -> Int
cLikeAsInt xs = loop 0 xs

loop :: Int -> String -> Int
loop acc (x:xs) = loop acc' xs
                  where acc' = acc * 10 + digitToInt x
loop acc []     = acc
