-- file: ch04/Fold.hs
foldlnew :: (a -> b -> a) -> a -> [b] -> a

foldlnew step acc (x:xs) = foldl step (step acc x) xs
foldlnew _    acc []     = acc

-- a strict foldl (like foldl' from Data.List)
foldlnew' _    acc []     = acc
foldlnew' step acc (x:xs) =
    let new = step acc x
    in  new `seq` foldlnew' step new xs

foldrnew :: (a -> b -> b) -> b -> [a] -> b

foldrnew step zero (x:xs) = step x (foldr step zero xs)
foldrnew _    zero []     = zero

foldlSum :: [Integer] -> Integer
foldlSum xs = foldl step 0 xs
    where step acc x = acc + x

foldlSum' :: [Integer] -> Integer
foldlSum' xs = foldl (+) 0 xs

myfilter :: (a -> Bool) -> [a] -> [a]
myfilter p []   = []
myfilter p (x:xs)
        | p x       = x : filter p xs
        | otherwise = filter p xs

-- fr is used for 'primitive recursion', very useful with lists
--
-- filter with foldr
frFilter :: (a -> Bool) -> [a] -> [a]
frFilter p xs = foldr step [] xs
    where step x accs | p x       = x : accs
                      | otherwise = accs
-- map with foldr
frMap :: (a -> b) -> [a] -> [b]
frMap f xs = foldr step [] xs
    where step x accs = f x : accs

-- even foldl with foldr
frFoldl :: (a -> b -> a) -> a -> [b] -> a
frFoldl f z xs = foldr step id xs z
    where step x g a = g (f a x)

-- id with foldr
identity :: [a] -> [a]
identity xs = foldr (:) [] xs
-- and append (like ++, based upon identity)
append :: [a] -> [a] -> [a]
append xs ys = foldr (:) ys xs
