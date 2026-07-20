-- an easy quicksort implementation
-- suitable for use on 1000 or so items
quick      :: [Integer] -> [Integer] 
quick []   = [] 
quick (h:t)= quick  [ y | y <- t , y < h] ++ [h] ++  quick  [ y | y <- t , y > h]
