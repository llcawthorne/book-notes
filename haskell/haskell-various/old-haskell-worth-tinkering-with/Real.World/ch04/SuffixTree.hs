-- file: ch04/SuffixTree.hs
import Data.List (tails)
import Data.Char (isUpper)

-- the @ (as-pattern) matches a pattern on the right of @
-- but also binds the entire list to a variable on the left of @
suffixes :: [a] -> [[a]]
suffixes xs@(_:xs') = xs : suffixes xs'
suffixes _ = []
-- suffixes "foo" is ["foo","oo","o"]

-- non as-pattern
suffixesNA :: [a] -> [[a]]
suffixesNA (x:xs) = (x:xs) : suffixesNA xs
suffixesNA _ = []
-- our pattern is simpler, but our code more complex

-- using init (and tails)
suffixes2 xs = init (tails xs)

-- composition function (apply f to results of g on x)
compose :: (b -> c) -> (a -> b) -> a -> c
compose f g x = f (g x)

-- with composition
suffixes3 xs = compose init tails xs
-- and curried
suffixes4 = compose init tails
-- now with the built-in composition operator!
suffixes5 = init . tails
-- init . tails is like compose init tails

-- count number of capitalized words in a String
capCount = length . filter (isUpper . head) . words

