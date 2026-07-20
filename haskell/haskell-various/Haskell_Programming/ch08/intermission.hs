-- intermission.hs
module Intermission where

applyTimes :: (Eq a, Num a) => a -> (b -> b) -> b -> b
applyTimes 0 f b = b
applyTimes n f b = f (applyTimes (n-1) f b)

main = 
  applyTimes 5 (+1) 5

-- = (+1) (applyTimes 4 f 6)
-- ...
-- = (+1) (+1) (+1) (+1) (+1) 5
