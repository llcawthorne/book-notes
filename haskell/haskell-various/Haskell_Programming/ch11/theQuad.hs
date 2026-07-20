-- theQuad.hs
module TheQuad where

data Quad = One
          | Two
          | Three
          | Four
          deriving (Eq, Show)

eQuad :: Either Quad Quad
eQuad = undefined
-- 8 possibilities for eQuad

prodQuad :: (Quad, Quad)
prodQuad = undefined
-- 16 possibilities for prodQuad

funcQuad :: Quad -> Quad
funcQuad = undefined
-- 4^4=256 possibilities for funcQuad

prodTBool :: (Bool, Bool, Bool)
prodTBool = undefined
-- 2*2*2=8 possibilities for prodTBool

gTwo :: Bool -> Bool -> Bool
gTwo = undefined
-- 2^2^2=16 possibilities for gTwo

fTwo :: Bool -> Quad -> Quad
fTwo = undefined
-- (2^4)^4=65536 possibilities for fTwo
