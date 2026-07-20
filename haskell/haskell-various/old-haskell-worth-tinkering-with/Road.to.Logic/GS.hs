
module GS
where

mnmInt :: [Int] -> Int
mnmInt []  = error "empty list"
mnmInt [x] = x
mnmInt (x:xs) = min x (mnmInt xs)

mxmInt :: [Int] -> Int
mxmInt []  = error "empty list"
mxmInt [x] = x
mxmInt (x:xs) = max x (mxmInt xs)

min' :: Int -> Int -> Int
min' x y | x <= y       = x
         | otherwise    = y

max' :: Int -> Int -> Int
max' x y | x >= y       = x
         | otherwise    = y

removeFst :: (Eq a) => a -> [a] -> [a]
removeFst n [] = []
removeFst n [x] | n == x    = []
                | otherwise = [x]
removeFst n (x:xs) | n == x = xs
                   | otherwise = x : removeFst n xs

srtInts :: [Int] -> [Int]
srtInts [] = []
srtInts xs = m : (srtInts (removeFst m xs)) where m = mnmInt xs

srtInts' :: [Int] -> [Int]
srtInts' [] = []
srtInts' xs = let m = mnmInt xs
              in  m : (srtInts (removeFst m xs))

srtString :: [String] -> [String]
srtString [] = []
srtString [x] = [x]
srtString xs = m : (srtString (removeFst m xs)) where m = mnmString xs

mnmString :: [String] -> String
mnmString []  = ""
mnmString [x] = x
mnmString (x:xs) = min x (mnmString xs)

average :: [Int] -> Rational
average [] = error "empty list"
average xs = toRational (sum xs) / toRational (length xs)

sum' :: [Int] -> Int
sum' [] = 0
sum' (x:xs) = x + sum' xs

length' :: [a] -> Int
length' [] = 0
length' (x:xs) = 1 + length' xs

count :: Char -> String -> Int
count c [] = 0
count c [x] | c == x    = 1
            | otherwise = 0
count c (x:xs) | c == x = 1 + count c xs
            | otherwise = 0 + count c xs

blowup :: String -> String
blowup [] = ""
blowup [x] = [x]
blowup (x: xs) = x : blowup' 2 (xs)

blowup' :: Int -> String -> String
blowup' 0 _ = ""
blowup' _ [] = ""
blowup' n [x] = take n $ repeat x
blowup' n (x:xs) = take n (repeat x) ++ blowup' (n+1) xs

prefix :: String -> String -> Bool
prefix [] ys = True
prefix (x:xs) [] = False
prefix (x:xs) (y:ys) = x == y && prefix xs ys

substring :: String -> String -> Bool
substring [] ys = True
substring xs [] = False
substring xs (y:ys) | prefix xs (y:ys) = True
                    | prefix xs ys = True
                    | otherwise    = substring xs ys

substring' :: String -> String -> Bool
substring' [] ys = True
substring' xs [] = False
substring' xs ys | prefix xs ys        = True
                 | otherwise           = substring' xs (tail ys)

ba = "Mr T Fool"

factors :: Integer -> [Integer]
factors n | n < 1       = error "Argument not positive.  I'm positive!!!"
          | n == 1      = []
          | otherwise   = p : factors (div n p) where p = ld n

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
