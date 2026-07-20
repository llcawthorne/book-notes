-- file: ch04/Filter.hs
oddList :: [Int] -> [Int]

oddList (x:xs) | odd x     = x : oddList xs
               | otherwise = oddList xs
oddList _                  = []

-- with filter
oddList' xs = filter odd xs
