-- varietyPack.hs
module VarietyPack where

-- 1a) (a, b) -> a
k (x, y) = x
-- 1b) [Char], no
k2 = k ("three", (1 + 2))
-- 1c) k1 and k2
k1 = k ((4 - 1), 10)
k3 = k (3, True)
-- 2)
f :: (a, b, c)
  -> (d, e, f)
  -> ((a, d), (c, f))
f (a, _, c) (d, _, f) = ((a, d), (c, f))
