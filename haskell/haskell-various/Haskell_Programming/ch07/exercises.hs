-- exercises.hs
module Exercises where

-- 1) d
-- 2) b
-- 3) d
-- 4) b
-- 5) a
 
-- Let's write code
-- 1)
tensDigit :: Integral a => a -> a
tensDigit x = d
  where xLast  = x `div` 10
        (_, d) = xLast `divMod` 10
-- 1b) yes
-- 1c)
hundredsDigit :: Integral a => a -> a
hundredsDigit x = d
  where xLast = x `div` 100
        d     = xLast `mod` 10

-- 2)
foldBool :: a -> a -> Bool -> a
foldBool x y b = case b of
  True -> y
  _    -> x

foldBool2 :: a -> a -> Bool -> a
foldBool2 x y b 
         | b         = y
         | otherwise = x

foldBool3 :: a -> a -> Bool -> a
foldBool3 x _ False = x
foldBool3 _ y True  = y

-- 3)
g :: (a -> b) -> (a, c) -> (b, c)
g f (a, c) = (f a, c)

-- 4)
roundTrip :: (Show a, Read a) => a -> a
roundTrip = read . show

main = do
  print (roundTrip 4) 
  print (id 4)
