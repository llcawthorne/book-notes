-- Recursion
-- isn't fibonacci always the start of this dicussion?
fib 0 = 1
fib 1 = 1
fib n = fib (n-1) + fib (n-2)
-- fib(0) and fib(1) are called 'edge conditions' because they are
-- defined non-recursively

-- recursive definition of maxiumum()
-- the maxium of a singleton list is the only element in the list
-- the maximum of a larger list is the head, if it is bigger than the maximum
-- of the tail:
mymax :: (Ord a) => [a] -> a
mymax []  = error "maximum of empty list"
mymax [x] = x
mymax (x:xs)
    | x > maxTail = x
    | otherwise = maxTail
    where maxTail = mymax xs
-- another way using max
mymax' :: (Ord a) => [a] -> a
mymax' [] = error "maximum of empty list"
mymax' [x] = x
mymax' (x:xs) = max x (mymax' xs)
-- mymax' [2,5,1] => max 2 mymax' [5,1] => max 2 (max 5 1) => max 2 5 => 5 

-- Num is not a subclass of Ord, so both must be specified if we are 
-- doing both addition/subtraction and comparison.
-- myreplicate i a produces a list of i elements of a => [a, a, a, a] i=4
myreplicate :: (Num i, Ord i) => i -> a -> [a]
myreplicate 0 a = []
myreplicate i a = a : myreplicate (i-1) a
-- Now with guards (to prevent problems with i < 0)
myreplicate' :: (Num i, Ord i) => i -> a -> [a]
myreplicate' n x
    | n <= 0        = []
    | otherwise     = x : myreplicate' (n-1) x

-- take takes a certain number of elements from a list
-- take 3 [5,4,3,2,1] returns [5,4,3]
-- two edges.  n and anything with n<= 0 returns [].  
--             anything and [] returns [].
mytake :: (Num i, Ord i) => i -> [a] -> [a]
mytake n _
    | n <= 0    = []  -- note:  no 'otherwise' so this will fall through.
mytake _ []     = []
mytake n (x:xs) = x : mytake (n-1) xs

-- myreverse.  edge is []
myreverse :: [a] -> [a]
myreverse []     = []
myreverse (x:xs) = myreverse xs ++ [x]
-- myrepeat 3 will give us a list of [3,3,3,3,3,3,3,...] infinitely long
myrepeat :: a -> [a]
myrepeat x = x:myrepeat x
-- zip has two edge conditions.  one for either list being empty.
myzip :: [a] -> [b] -> [(a,b)]
myzip _ [] = []
myzip [] _ = []
myzip (x:xs) (y:ys) =
    (x,y):myzip xs ys
-- elem takes an element and a list and looks for the element in the list
myelem :: (Eq a) => a -> [a] -> Bool
myelem a [] = False
myelem a (x:xs)
    | a == x    = True
    | otherwise = a `myelem` xs

-- Those were library functions.  How about something "fun"
-- Quicksort
-- It simply requires Ord typeclass items, and the edge condition is []
-- A sorted list is a list that has all the values smaller than (or equal to)
-- the head of the list in front (and those values are sorted), then comes
-- the head of the list in the middle and then comes all the values that are
-- bigger than the head (they're also sorted).
quicksort :: (Ord a) => [a] -> [a]
quicksort [] = []
quicksort (x:xs) =
    let smallerSorted = quicksort [a | a <- xs, a <= x]
        biggerSorted  = quicksort [a | a <- xs, a >  x]
    in  smallerSorted ++ [x] ++ biggerSorted
--                      [5,1,9,4,6,7,3]
--                 [1,4,3] ++ [5] ++ [9,6,7]
--      [] ++ [1] ++ [4,3] ++ [5] ++ [6,7] ++ [9]
-- [] ++ [1] ++ [3] ++ [4] ++ [5] ++ [6] ++ [7] ++ [9]
-- it actually goes one level deeper for []'s, but that's the gist

-- Recursion Summary
-- Usually you define an edge case and then define a function that does
-- something between some element and the function applie to the rest.
--
-- A sum is the first element plus the rest of the list
-- A product is the first element times the product of the rest of the list.
-- The length of a list is one plus the length of the tail.
--
-- Edges tend to be cases where recursion wouldn't make sense.
-- The edge with a list is often the empty list.
-- The edge with a tree is often a leaf.
-- Often the edge with numbers is some type of identity.
