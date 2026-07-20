-- zippingExercises.hs
module ZippingExercises where

newzip :: [a] -> [b] -> [(a, b)]
newzip [] ys = []
newzip xs [] = []
newzip (x:xs) (y:ys) = (x, y) : newzip xs ys

newzipWith :: (a -> b -> c) -> [a] -> [b] -> [c]
newzipWith _ [] ys = []
newzipWith _ xs [] = []
newzipWith f (x:xs) (y:ys) = f x y : newzipWith f xs ys

newzip' :: [a] -> [b] -> [(a, b)]
newzip' = newzipWith (,)
