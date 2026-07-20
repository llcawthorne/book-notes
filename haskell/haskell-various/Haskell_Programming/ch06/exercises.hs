module Exercises where
import Data.List (sort)

-- 1) c
-- 2) b
-- 3) a
-- 4) c
-- 5) a

-- Does it typecheck
-- 1) No, didn't derive Show
-- 2) No, didn't derive Eq
-- 3) NA.  didn't typecheck.
-- 4) it typechecks, even though s1 isn't fully applied

-- Given a datatype declaration, what can we do?
data Rocks =
  Rocks String deriving (Eq, Show)

data Yeah =
  Yeah Bool deriving (Eq, Show)

data Papu = 
  Papu Rocks Yeah
  deriving (Eq, Show)

-- 1) No type for Papu String Bool
-- 2)
truth :: Papu
truth = Papu (Rocks "chomskydoz") (Yeah True)
-- 3)
equalityForall :: Papu -> Papu -> Bool
equalityForall p p' = p == p'
-- 4) We didn't derive Ord for Papu or either of the classes that make it up

-- Match the types
-- 1) It needs the Num a constraint
-- 2) You could relax it to Fractional from Float, but not back to Num
-- 3)
f :: Fractional a => a
f = 1.0
-- 4)
f' :: RealFrac a => a
f' = 1.0
-- 5)
freud :: Ord a => a -> a
freud x = x
-- 6)
freud' :: Int -> Int
freud' x = x
-- 7) Can't loosen that to a, because myX is Int
-- 8) Can't loosen that to Num, because myX is Int 
-- 9)
jung :: [Int] -> Int
jung xs = head (sort xs)
-- 10)
young :: Ord a => [a] -> a
young xs = head (sort xs)
-- 11) Can't relax to Ord a after specializing mySort to [Char]

-- Type-Kwon-Do Two: Electric Typealoo
chk :: Eq b => (a -> b) -> a -> b -> Bool
chk aToB a b = aToB a == b

arith :: Num b => (a -> b) -> Integer -> a -> b
arith aToB _ a = aToB a
