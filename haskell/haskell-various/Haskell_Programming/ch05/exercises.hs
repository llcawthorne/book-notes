-- Exercises.hs
{-# LANGUAGE NoMonomorphismRestriction #-}
module Exercises where

-- 1) c
-- 2) a
-- 3) b
-- 4) c
example = 1

one_a = (* 9) 6
one_b = head [(0, "doge"), (1, "kitteh")]
one_c = head [(0 :: Integer, "doge"), (1, "kitteh")]
one_d = if False then True else False
one_e = length [1, 2, 3, 4, 5]
one_f = (length [1, 2, 3, 4]) > (length "TACOCAT")

x = 5
y = x + 5
w = y * 10

z y = y * 10

f = 4 / y

x' = "Julie"
y' = " <3 "
z' = "Haskell"
f' = x' ++ y' ++ z'

-- Type variable or specific type constructor
-- 1) f :: Num a => a -> b -> Int -> Int
--                 [0]  [1]   [2]    [3]
-- [0] constrained polymorphic, [1] fully polymorphic
-- [2] && [3] concrete
--
-- 2) f :: zed -> Zed -> Blah
--         [0]    [1]    [2]
-- [0] fully polymorphic [1] && [2] concrete
--
-- 3) f :: Enum b => a -> b -> c
--                  [0]  [1]  [2] 
-- [0] && [2] fully polymorphic, [1] constrained polymorphic
--
-- 4) f :: f -> g -> C
--        [0]  [1]  [2]
-- [0] && [1] fully polymorphic, [2] concrete

functionH :: [a] -> a
functionH (x:_) = x

functionC :: (Ord a) => a -> a -> Bool
functionC x y = if (x > y) then True else False

functionS :: (a, b) -> b
functionS (x, y) = y

myFunc :: (x -> y) -> (y -> z) -> c -> (a, x) -> (a, z)
myFunc xToY yToZ _ (a, x) = (a, (yToZ . xToY) x)

-- Given a type, write the function
-- 1)
i :: a -> a
i x = x
-- 2)
c :: a -> b -> a
c x _ = x
-- 3) yes
c'' :: b -> a -> b
c'' x _ = x
-- 4)
c' :: a -> b -> b
c' _ y = y
-- 5)
r :: [a] -> [a]
r xs = xs
-- r xs = tail xs
-- r xs = init xs
-- 6)
co :: (b -> c) -> (a -> b) -> a -> c
co bToC aToB a = (bToC . aToB) a
-- 7)
a :: (a -> c) -> a -> a
a _ x = x
-- 8)
a' :: (a -> b) -> a -> b
a' aToB a = aToB a

-- singing and arith3Broken in separate files

-- Type-Kwon-Do in separate file

