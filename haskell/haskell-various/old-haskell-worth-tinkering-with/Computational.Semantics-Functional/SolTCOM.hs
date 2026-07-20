module SolTCOM where 

import TCOM

tree :: Integer -> [(Integer,Integer)]
tree n = [(n-x,x) | x <- [0..n]]

treeOfNumbers :: [(Integer,Integer)]
treeOfNumbers = concat [ tree n | n <- [0..] ]

type Quant = (Integer -> Bool) -> [Integer] -> Bool

check :: Quant -> (Integer,Integer) -> Bool
check q (n,m) = q (\ x -> 0 < x && x <= m) [1..n+m]

genTree :: Quant -> [(Integer,Integer)]
genTree q = filter (check q) treeOfNumbers

