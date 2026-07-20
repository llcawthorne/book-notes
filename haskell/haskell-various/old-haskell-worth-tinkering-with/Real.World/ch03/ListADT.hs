-- file: ch03/ListADT.hs
data List a = Cons a (List a)
            | Nil
              deriving (Show)

-- create a List from a normal [] list
fromList (x:xs) = Cons x (fromList xs)
fromList []     = Nil

-- create a [] list from a List
-- match on the constructor...
toList (Cons x xs) = x : toList xs
toList Nil  = []

simplestList = Nil
longerList   = Cons 1 Nil
longList     = Cons 1 (Cons 2 (Cons 3 (Cons 4 (Cons 5 Nil))))
