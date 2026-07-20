sort :: Ord a => [a] -> [a]

sort []         =  []
sort [x]        =  [x]
sort xs         =  merge (sort ys) (sort zs)
  where
    (ys,zs) = splitAt (length xs `div` 2) xs
    merge [] y=y
    merge x []=x
    merge (x:xs) (y:ys)
      | x <= y = x:merge xs (y:ys)
      | otherwise = y:merge (x:xs) ys

