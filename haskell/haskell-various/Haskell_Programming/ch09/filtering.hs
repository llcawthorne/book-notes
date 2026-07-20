-- filtering.hs
module Filtering where

-- 1) multiples of 3 out of a list of thirty
one = filter (\x -> (rem x 3) == 0) [1..30]

-- 2) length of above
two = length . filter (\x -> (rem x 3) == 0) $ [1..30]

-- 3) filter articles
three = filter (\x -> x /= "a" && x /= "an" && x /= "the") . words 
      $ "the brown dog was a goof"
