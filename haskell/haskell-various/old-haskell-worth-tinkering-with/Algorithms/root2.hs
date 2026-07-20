#!/usr/bin/env runhaskell
import Data.List

f  :: Double -> Double
f x = 1 + 1 / (1 + x)

loopF   :: Int -> Double
loopF x  = loopF' x
    where
        loopF' :: Int -> Double
        loopF' n | n == 0 = f 1
                 | otherwise = f (loopF' (n - 1))

foldrroot :: Int -> Double
foldrroot x = foldr ($) 1 (take x (repeat f))

foldlroot :: Int -> Double
foldlroot x = foldl (flip ($)) 1 (take x (repeat f))

-- strict foldl allows us to avoid stack overflows for large x
foldl'root :: Int -> Double
foldl'root x = foldl' (flip ($)) 1 (take x (repeat f))

main = do
  putStrLn (show (sqrt 2))
  putStrLn (show $ loopF 10000)
  putStrLn (show $ foldrroot 10000)
  putStrLn (show $ foldlroot 10000)
  putStrLn (show $ foldl'root 1000000)

  -- we could just do this all on one line!
  putStrLn (show $ foldl (flip ($)) 1 (take 1000 (repeat (\x -> (1+1/(1+x))))))
