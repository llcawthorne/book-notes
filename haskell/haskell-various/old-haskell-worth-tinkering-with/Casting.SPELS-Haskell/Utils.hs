-- | Some utility functions
-- This code has been written by JP Moresmau (jp_at_moresmau_dot_fr)
-- This is no copyright at all it, feel free to reuse
module Utils where

import Char

capitalize :: String -> String
capitalize [] = []
capitalize (c:cs) = (Char.toUpper c):cs

lTrim :: String -> String
lTrim s = dropWhile Char.isSpace s 

splitAtFn :: (a->Bool) -> [a] -> [[a]]
splitAtFn f as = doSplitAtFn f as [] []

doSplitAtFn f [] [] total= total
doSplitAtFn f [] current total= (total ++ [current])
doSplitAtFn f (x:xs) current total 
	| f(x)      = doSplitAtFn f xs [] (total ++ [current])
	| otherwise = doSplitAtFn f xs (current ++ [x]) total
	
	
splitAtFnIncludingFirst :: (a->Bool) -> [a] -> [[a]]
splitAtFnIncludingFirst f as = doSplitAtFnIncludingFirst f as [] []

doSplitAtFnIncludingFirst f [] [] total= total
doSplitAtFnIncludingFirst f [] current total= (total ++ [current])
doSplitAtFnIncludingFirst f (x:xs) current total 
	| f(x)      = doSplitAtFnIncludingFirst f xs [x] (total ++ [current])
	| otherwise = doSplitAtFnIncludingFirst f xs (current ++ [x]) total