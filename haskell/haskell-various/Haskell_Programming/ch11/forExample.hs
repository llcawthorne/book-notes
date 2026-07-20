-- forExample.hs
module ForExample where

data Example = MakeExample deriving Show

-- 1) MakeExample :: Example
-- it is invalid to ask for :type Example

-- 2) :info Example tells us about data constructor MakeExample
-- and that the typeclass derives Show

data Example2 = MakeExample2 Int deriving Show

-- 3) MakeExample2 :: Int -> Example2
