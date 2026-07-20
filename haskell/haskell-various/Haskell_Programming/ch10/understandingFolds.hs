-- understandingFolds.hs
module UnderstandingFolds where

-- 1) b and c
-- 2) foldl (flip (*)) 1 [1..3]
--  = (3 * (2 * (1 * 1)))
-- 3) c
-- 4) a
fivea = foldr (++) "" ["woot", "WOOT", "woot"]
fiveb = foldr max ' ' "fear is the little death"
fivec = foldr (&&) True [False, True]
fived = foldr (||) False [False, True]
fivee = foldl (\acc x -> acc ++ (show x)) "" [1..5]
fivef = foldr const 'a' ['1'..'5']
fiveg = foldr const '0' "tacos"
fiveh = foldr (flip const) '0' "burritos"
fivei = foldl (flip const) 'z' ['1'..'5']
