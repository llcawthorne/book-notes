module Recursion
    where
-- there is no for loop in Haskell
-- so much looping is done through recursion
-- it is clearly defined as piecewise functions for a base case
-- and a corresponding series of cases defined in terms of the base

-- recursive factorial definition
factorial 1 = 1
factorial n = n * factorial (n-1)

-- fibonacci sequence
fib 1 = 1
fib 2 = 1
fib n = fib (n-1) + fib (n-2)

-- a recursive definition of raising a^b
exponentiate a 1 = a
exponentiate a b = a * exponentiate a (b-1)

-- multiply with addition
my_mult n 0 = 0
my_mult n 1 = n
my_mult n m = n + my_mult n (m-1)

-- recursion on lists.  base case is a [] (empty list)
-- the recursive case is a cons list (ie a value cons'd onto another list [:])
--
-- this returns the length of a string, or list such as [1,2,3,4,5]
my_length [] = 0
my_length (x:xs) = 1 + my_length xs

-- my_filter duplicates the effect of filter.  it tests for the predicate (p) 
-- and creates a new list of things for which the predicate is true
my_filter p [] = []
my_filter p (x:xs) = 
    if p x
        then x : my_filter p xs
        else my_filter p xs

-- my_map duplicates the effects of map.
-- it applies a function f to each element of a list and returns
-- a list of results
my_map f [] = []
my_map f (x:xs) = f x : my_map f xs
