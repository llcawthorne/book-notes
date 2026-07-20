module Piecewise
    where

-- A piecewise declaration of a function
-- This could have been handled by a case statement
f 0 = 1
f 1 = 5
f 2 = 2
f _ = -1

-- putting this in here so i can do composition in hugs
square x = x * x
