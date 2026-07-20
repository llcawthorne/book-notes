-- file: ch04/Sum.hs
mySum xs = helper 0 xs
    where helper acc (x:xs) = helper (acc + x) xs
          helper acc _      = acc

-- for huge lists
hugeSum xs = helper 0 xs
       where helper acc (x:xs) = acc `seq` helper (acc + x) xs
             helper acc _      = acc

-- foldl sum
niceSum :: [Integer] -> Integer
niceSum xs = foldl' (+) 0 xs

-- foldl partial sum [look ma!  no points]
nicerSum :: [Integer] -> Integer
nicerSum = foldl' (+) 0
