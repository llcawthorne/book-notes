-- a higher order function takes functions a parameters
-- and/or returns functions as return values
--
-- every function in haskell only takes on parameter (officially)
-- all functions we have used that take several parameters have been
-- 'curried functions'.  
-- max 4 5    -- is equivalent to
-- (max 4) 5  -- !
-- max's type is
-- max :: (Ord a) => a -> a -> a     AKA
-- max :: (Ord a) => a -> (a -> a)
-- read -> as returns.  
-- max takes a and returns a function that takes an a and returns an a
-- that's why the return type and the parameters are separated by arrows
--
-- a function that isn't given all its parameters is "partially applied)
multThree :: (Num a) => a -> a -> a -> a
multThree x y z = x * y * z
-- multThree 1 2 3 is the same as (((multThree 1) 2) 3)
-- (multThree 1) takes one paramter and returns a function
-- then 2 is applied to this new function which takes 2 and returns a function
-- then 3 is applied to the new function which takes 3 and returns results
-- mulThree :: (Num a) => a-> (a -> (a -> a)) means that our function
-- takes a and returns a type (Num a) => a -> (a -> a)
-- which takes an a and returns a type (Num a) => a -> a
-- which takes an a and returns a type (Num a) => a
--
-- since multThree a returns a function of type (Num a) => a -> a, we can:
multTwoWithNine = multThree 9
-- which gives us the new function multTwoWithNine that takes two parameters
multWithEighteen = multTwoWithNine 2
-- is a new function taking one parameter and multiply it by 9 and 2
-- it's like creating new functions "on the fly"
compareWithHundred :: (Num a, Ord a) => a -> Ordering
compareWithHundred = compare 100
-- this is the same as (but more generally useful than)
-- compareWithHundred x = compare 100 x

-- this works for infix functions too!
divideByTen :: (Floating a) => a -> a
divideByTen = (/10)
-- divideByTen 200 does 200/10
-- special case (-4) is negative four, not minus 4
subtractFour :: (Num a) => a -> a
subtractFour = (subtract 4)
-- a simple use with Chars
isUpperAlphanum :: Char -> Bool
isUpperAlphanum = (`elem` ['A'..'Z'])

-- Functions can take functions as parameters also
applyTwice :: (a -> a) -> a -> a
applyTwice f x = f (f x)
-- the (a -> a) in the declaration tells us that our first parameter
-- is a function.  the a is the second parameter, and this returns an a
-- you would call this as: applyTwice multWithEighteen 2  (returning 648)
-- applyTwice (+3) 10 returns 16.  applyTwice (3:) [1] returns [3,3,1]
-- applyTwice ("HAHA " ++) "HEY" returns "HAHA HAHA HEY"

-- zipWith
-- zipWith takes a function and two lists as parameters and then joins the
-- two lists by applying the function between correspond elements
myZipWith :: (a -> b -> c) -> [a] -> [b] -> [c]
myZipWith _ [] _ = []
myZipWith _ _ [] = []
myZipWith f (x:xs) (y:ys) = f x y : myZipWith f xs ys
-- myZipWith (+) [4,2,5,6] [2,6,2,3] returns [6,8,7,9]
-- myZipWith max [4,2,5,6] [2,6,2,3] returns [4,6,5,6]
-- myZipWith (*) (replicate 5 2) [1..] returns [2,4,6,8,10]
-- flip takes a function and returns a function with its arguments flipped
myflip :: (a -> b -> c) -> (b -> a -> c)
myflip f = g
    where  g x y = f y x
-- an easier way to do the same is:
myflip' :: (a -> b -> c) -> (b -> a -> c)
myflip' f y x = f x y

-- as we've seen, many power functions are easy to define
mymap :: (a -> b) -> [a] -> [b]
mymap _ [] = []
mymap f (x:xs) = f x : mymap f xs
-- mymap (+3) [1,2,3] returns [4,5,6]
-- mymap (++ "!") ["BIFF","BANG"] returns ["BIFF!","BANG!"]
--
-- Filter takes a predicate and a list and returns a list of elements
-- that satisfy the predicate.
myfilter :: (a -> Bool) -> [a] -> [a]
myfilter _ [] = []
myfilter p (x:xs)
    | p x       = x : filter p xs
    | otherwise = filter p xs
-- remember p is a function that takes x and returns True or False
-- myfilter (>5) [1,2,3,4,5,6,7] returns [6,7]
--
-- Many things done with comprehensions also work easily with map/filter
--
-- a more legible quicksort using filter
quicksort :: (Ord a) => [a] -> [a]
quicksort [] = []
quicksort (x:xs) =
    let smallerSorted = quicksort (filter (<=x) xs)
        biggerSorted  = quicksort (filter (> x) xs)
    in  smallerSorted ++ [x] ++ biggerSorted

-- now lets do something "fun".  find the largest number
-- under 100,000 that's divisible by 3829.
largestDivisible :: (Integral a) => a
largestDivisible = head (filter p [100000,99999..])
    where p x = x `mod` 3829 == 0

-- takeWhile takes a predicte and a list and returns elements
-- as long as the predicate holds true.
-- the sum of all odd squares that are smaller than 10,000 is:
oddSquareSum  = sum (takeWhile (<10000) (filter odd (map (^2) [1..])))
oddSquareSum' = sum (takeWhile (<10000) [m | m <- [n^2 | n <- [1..]], odd m])
-- both return 166650
--
-- Collatz sequences.  We take a natural number.  If it is even, we divide
-- it by two.  If it's odd, we multiply it by 3 and then add 1 to that.  Then
-- we do the same to the result, etc.  We get back a chain of numbers.
-- It is thought that for all numbers, the chain terminates at 1.
-- 13 => 13,40,20,10,5,16,8,4,2,1.  10 terms.
-- Now, let's see for all numbers 1-100, how many have chains with >15 terms.
chain :: (Integral a) => a -> [a]
chain 1 = [1]
chain n
    | even n = n:chain (n `div` 2)
    | odd  n = n:chain (n*3 + 1)
numLongChains :: Int
numLongChains = length (filter isLong (map chain [1..100]))
    where isLong xs = length xs > 15
-- there are 66!  (there are 99921 from 1-100000 and it takes about 10s)
-- map (*) [0..] returns a list something like 
-- [(0*),(1*),(2*),(3*),(4*),(5*)..
-- let listOfFuns = map (*) [0..]
-- (listOfFuns !! 4) 5 returns 20

-- Lambdas
-- Lambdas are anonymous functions that are used because we need some
-- functions only once.  Normally we make a lambda with the sole purpose
-- of passing it to a higher-order function.  To make a lambda, we write \
-- because \ looks kind of like the greek letter lambda (if you squint).
-- In the previous function, a lambda could easily replace the where clause
numLongChains' :: Int
numLongChains' =  length (filter (\xs -> length xs > 15) (map chain [1..100]))
-- see.  (\param -> function body)
-- aka.  (\xs -> length xs 15)
-- if you don't include the (), then the \ extends all the way right
-- the expression (\xs -> length xs 15) returns a function that 
-- tells us whether the length of the list passed to it is greater than 15
-- don't use lambdas unnecessarily!
-- map (+3) [1,6,3,2] is equivalent to map (\x -> x + 3) [1,6,3,2]
-- but which is more readable?
-- multiple parameters are fine with llambdas
-- zipWith (\a b -> (a * 30 + 3) / b) [5,4,3,2,1] [1,2,3,4,5]
-- map (\(a,b) -> a + b) [(1,2),(3,5),(6,3),(2,6),(2,5)]
--      returns [3,8,9,8,7]
-- 
-- lambdas make function currying more clear
-- you would never right something this way, except to prove this point
-- but these two are equivalent (same number of ->'s in all 
-- (except the 'normal' way of writing it, obviously)
addThree  :: (Num a) => a -> a -> a -> a
addThree  x y z = x + y + z
addThree' :: (Num a) => a -> a -> a -> a
addThree' = \x -> \y -> \z -> x + y + z

-- the flip function is very readable with lambdas (supposedly)
flip' :: (a -> b -> c) -> b -> a -> c
flip' f = \x y -> f y x
-- use this notation if you function is meant to be partially applied
-- and passed on to a function as a parameter

-- Folds
-- folds are like maps that reduce a list to a single value
-- they encapsulate recursive functions on lists that end with []
-- A fold takes a binary functino, a starting value and a list to fold.
-- The binary function is called with the starting value and the first
-- or last element of the list and produces a new starting value, ...
-- Only the last starting value remains once the list is reduced.
-- foldl is the left fold, it folds from the left side.
-- foldl (+) 0 [1,2,3] returns 6 because (((0+1)+2)+3) = 6
-- foldr is the right fold, it folds from the right side.
-- foldr (+) 0 [1,2,3] returns 6 because (1+(2+(3+0))) = 6
-- The author likes refering to the starting/intermediate value as the 
-- accumulator, so it is called acc in these examples:
newsum  :: (Num a) => [a] -> a
newsum  xs = foldl (\acc x -> acc + x) 0 xs
newsum' :: (Num a) => [a] -> a
newsum' xs = foldr (\acc x -> acc + x) 0 xs
-- writing like this instead of with (+) tries to make it easier to see
-- what is really going on.
-- \acc x -> acc + x is the binary function, 0 is the starting value,
-- and xs is the list to be folded up.  foldl goes like
-- (((0 + 1) + 2) + 3) with a list of [1,2,3]
-- here's product more cleanly with curry
newprod  :: (Num a) => [a] -> a
newprod  =  foldl (*) 1
-- to call it, we have to do newprod [1,2,3] or any other list, and it
-- will apply the fold to it.  we start with 1, the multiplicative identity
-- any function like foo a = bar b a can be rewritten as foo = bar b
-- because of currying, in general.
newelem  :: (Eq a) => a -> [a] -> Bool
newelem  y ys = foldl (\acc x -> if x == y then True else acc) False ys
-- the type of the 'starting value'/accumulator and the final result
-- is always the same when dealing with folds (in this case Bool)
-- in this case we start with "False' and the list 'ys' and our binary
-- function is (\acc x -> if x == y then True else acc)
-- acc with remain false until x==y is True, then it will change
-- if nothing is found, it will never change from False
-- foldr - important note
-- the binary function of foldr takes the acc as the second parameter
-- however the stating value is still the first parameter to foldr
--   and the list the second
newelem' :: (Eq a) => a -> [a] -> Bool
newelem' y ys = foldr (\x acc -> if x == y then True else acc) False ys
-- here's a map function with foldr
newmap  :: (a -> b) -> [a] -> [b]
newmap  f xs = foldr (\x acc -> f x : acc) [] xs
-- newmap (+3) [1,2,3] returns [4,5,6]
-- newmap (+3) [1,2,3] leads to foldr (\3 [] -> (+3) 3 : []
--                   leading to foldr (\2 [6] -> (+3) 2 : [6]
--                   leading to foldr (\1 [5,6] -> (+3) 1 : [5,6]
--                   leading to [4,5,6]
-- this works too
newmap' :: (a -> b) -> [a] -> [b]
newmap' f xs = foldl (\acc x -> acc ++ [f x]) [] xs
-- notice we have to use ++ to conjoin elements
-- we often use foldr when building lists from other lists,
-- because ++ is more expensive than the : operation.
--
-- if you reverse a list, you can foldr when you would've done foldl
-- Important: right folds work on infinite lists, where left folds do not
-- think of it like this, if you take an infinite list and start folding
-- from the right, you would eventually reach the beginning.
-- if you start at the beginning and work towards the end of an infinite
-- list, you would never reach the end.
--
-- Whenever you want to traverse a list element by element and return 
-- something based upon that, you probably want a fold.
-- Chances are, if you want to traverse a list and return something,
-- you will use a fold.
-- Use a fold when trying to traverse a list and return a value.
--
-- Folds, Maps, and Filters are some of the most useful and commonly used
-- tools in functional programming.

-- foldl1 and foldr1 work like foldl and foldr, but instead of specifying
-- a starting value, they use the first (or last) element of the list
-- as their starting value automatically
-- foldl1 (+) [1,2,3] returns 6 (sum)
-- foldr1 (+) [1,2,3] returns 6 (sum)
-- here's some standard library functions using folds:
foldmaximum :: (Ord a) => [a] -> a
foldmaximum =  foldr1 (\x acc -> if x > acc then x else acc)

foldreverse :: [a] -> [a]
foldreverse = foldl (\acc x -> x : acc) []

foldproduct :: (Num a) => [a] -> a
foldproduct =  foldr1 (*)

foldfilter  :: (a -> Bool) -> [a] -> [a]
foldfilter p = foldr (\x acc -> if p x then x : acc else acc) []

foldhead    :: [a] -> a
foldhead    =  foldr1 (\x _ -> x)

foldlast    :: [a] -> a
foldlast    =  foldl1 (\_ x -> x)

-- scanl and scanr are like foldl and foldr, but they return lists
-- that show all the intermediate steps of the accumlators
-- scanr (+) 0 [1,2,3] returns [6,5,3,0]
-- scanl (+) 0 [1,2,3] returns [0,1,3,6]
--
-- this will give us the number of elements it takes for the sum of the roots
-- of all natural numbers to exceed 1000:
sqrtSums :: Int
sqrtSums = length (takeWhile (<1000) (scanl1 (+) (map sqrt [1..]))) +1

-- function application ($)
-- ($) :: (a -> b) -> a -> b
-- f $ x = f x
-- normal function application (the space) has very high precedence and is
--  left associative
-- $ has the lowest precedence and is right associative
-- f a b c  is the same as (((f a) b) c)
-- f $ a b c is like f (a b c) sort of.
-- think sqrt 2 + 3 + 4 would give you (sqrt 2) + 3 + 4
--       sqrt $ 2 + 3 + 4 would give you sqrt (2+3+4), sqrt 9, 3
-- ($) is mainly a convenient way to save some parentheses 
--     and make code cleaner
-- instead of sum (map sqrt [1..130]) we can sum $ map sqrt [1..130]
-- because it is right associative:
-- sum (filter (> 10) (map (*2) [2..10]))    becomes
-- sum $ filter (> 10) $ map (*2) [2..10]
-- ($) is alwys useful in mapping and such
-- map ($ 3) [(4+), (10*), (^2), sqrt] returns [7.0,30.0,9.0,1.73]

-- Function Composition
-- (f . g)(x) is like f(g(x))
-- (.) :: (b -> c) -> (a -> b) -> a -> c
-- f . g = \x -> f (g x)
-- lamda negation of abs value to return an all negative list:
negList    :: (Num a) => [a] -> [a]
negList  xs = map (\x -> negate (abs x)) xs
-- same thing with composition
negList'   :: (Num a) => [a] -> [a]
negList' xs = map (negate . abs) xs
-- we probably could've curried that, but this demonstrates the point
-- function composition is right associative
-- these functions sum inner lists then negate the results and return a list
negLists   :: (Num a) => [[a]] -> [a]
negLists xs = map (\xs -> negate (sum (tail xs))) xs
-- with composition
negLists'   :: (Num a) => [[a]] -> [a]
negLists' xs = map (negate . sum . tail) xs
-- multi-parameter functions work too..
-- sum (replicate 5 (max 6.7 8.9)) becomes
-- (sum . replicate 5 . max 6.7) 8.9    or
-- sum. replicate 5 . max 6.7 $ 8.9
-- this would apply 8.9 to max 6.7, then apply replicate 5 to that, then
-- apply sum to the result.
-- replicate 100 (product (map (*3) (zipWith max [1,2,3,4,5] [4,5,6,7,8])))
-- replicate 100 . product . map (*3) . zipWith max [1,2,3,4,5] $ [4,5,6,7,8]
--
-- if an expression ends in three parentheses, it will probably need three
-- composition operators to rewrite it using composition
--
-- point free or pointless style tends to use composition
-- Not Point Free
sumpoint     :: (Num a) => [a] -> a
sumpoint xs   = foldl (+) 0 xs
-- Point Free
sumpointfree :: (Num a) => [a] -> a
sumpointfree  = foldl (+) 0
-- point free takes advantage of currying and lets us omit the xs
-- Not Point Free
fnpoint      :: (RealFrac t, Floating t, Integral b) => t -> b
fnpoint x     = ceiling (negate (tan (cos (max 50 x))))
-- Point Free
fnpointfree  :: (RealFrac t, Floating t, Integral b) => t -> b
fnpointfree   = ceiling . negate . tan . cos . max 50

-- oddSquareSum.  Returns the sum of all odd squares <10,000
newoddSquareSum   :: Integer
newoddSquareSum    = sum (takeWhile (<10000) (filter odd (map (^2) [1..])))
-- now composed
newoddSquareSum'  :: Integer
newoddSquareSum'   = sum . takeWhile (<10000) . filter odd . map (^2) $ [1..]
-- most legible version probably
newoddSquareSum'' :: Integer
newoddSquareSum''  = 
    let oddSquares = filter odd $ map (^2) [1..]
        belowLimit = takeWhile (<10000) oddSquares
    in  sum belowLimit

-- They all work, but remember being able to read and figure out what
-- something does will come in handy when you come back to this problem
-- a few months from now and are wordering what's up with all the parens
