-- pattern matching is a good place to start
-- trivial function that checks to see if its parameter is a 7
lucky :: (Integral a) => a -> String
lucky 7 = "LUCKY NUMBER SEVEN!"
lucky x = "Sorry, you're out of luck, pal!"
-- these simple examples are like piecewise case statements
-- they are matched top to bottom (like case statements)
sayMe :: (Integral a) => a -> String
sayMe 1 = "One!"
sayMe 2 = "Two!"
sayMe 3 = "Three!"
sayMe 4 = "Four!"
sayMe 5 = "Five!"
sayMe x = "Not between 1 and 5"
-- when making patterns, do most restrictive first and work down
-- always include a catch all or you risk a compiler error
-- "Exception: Non-exhaustive patterns in function charName"
--
-- recursive factorial definition
factorial :: (Integral a) => a -> a
factorial 0 =  1
factorial n = n * factorial (n-1)

-- a function to add two vectors (represented as tuples [pairs])
-- addVectors a b = (fst 1 + fst b, snd a + snd b) would work, but:
addVectors :: (Num a) => (a,a) -> (a,a) -> (a,a)
addVectors(x1,y1)(x2,y2) = (x1+x2, y1+y2)
-- (_) still matches all in pattern matching.  try:
-- since fst and snd only work with pairs, we might want this for triples
tripFirst :: (a, b, c) -> a
tripFirst (x,_,_) = x
tripSecond :: (a, b, c) -> b
tripSecond (_,y,_) = y
tripThird :: (a, b, c) -> c
tripThird (_,_,z) = z

-- pattern matching works with comprehensions also:
sampList = [(1,3),(4,3),(2,4),(5,3),(5,6),(3,1)]
-- now try myComp sampList in ghci
myComp xs = [a+b | (a,b) <- xs]

-- the pattern x:xs is used alot to match lists.  it works to match any
-- list of length 1 or more (since any list is at least _ : [])
-- in x:xs the head is x and what is leftover becomes xs
-- you could also use x:y:z:zs against a list with three elements or more!
--
-- The head function is simple to reimplement.  In this case we are
-- using (x:_) instead of (x:xs) since we don't care about the tail
myhead :: [a] -> a
myhead [] = error "Can't call head on an empty list, dummy!"
myhead (x:_) = x
mytail :: [a] -> [a]
mytail [] = error "Can't take the tail of an empty list, dummy!"
mytail (_:xs) = xs
-- Note that when binding several variables we surround them in parentheses
tell :: (Show a) => [a] -> String
tell [] = "The list is empty"
tell (x:[]) = "The list has one element: " ++ show x
tell (x:y:[]) = "The list has two elements: " ++ show x
              ++ " and " ++ show y
tell (x:y:_) = "This list is long.  The first to elements are: "
             ++ show x ++ " and " ++ show y
-- we can reimplement length also
mylength :: (Num b) => [a]->b
mylength [] = 0
mylength (_:xs) = 1 + mylength xs
-- sum and product
mysum :: (Num a) => [a] -> a
mysum [] = 0
mysum (x:xs) = x + mysum xs
myproduct :: (Num a) => [a] -> a
myproduct [] = 1
myproduct (x:xs) = x * myproduct xs

-- There are also 'patterns' which use the @ sign.
-- If you put xs@(x:y:ys) it matches x:y:ys but leaves xs as a reference
-- to the entire triple that you can use in your function
capital :: String -> String
capital "" = "Empty string, whoops!"
capital all@(x:xs) = "The first letter of " ++ all ++ " is " ++ [x]

-- Next up, "Guards, guards!"
-- something like an if/else if/else chain.  First a simple example:
bmiTell :: (RealFloat a) => a -> String
bmiTell bmi
    | bmi <= 18.5 = "You're underweight, you emo, you!"
    | bmi <= 25.0 = "You're supposedly normal.  Pffft, I bet you're ugly!"
    | bmi <= 30.0 = "You're fat! Lose some weight, fatty!"
    | otherwise = "You're a whale, congratulations!"
-- where patterns match against patterns (DUH!), 
-- guards match against boolean conditions
-- if all guards match false and there is no otherwise (since it is always
-- True), then evaluation vfalls through to the next pattern in the line.
bmiTell' :: (RealFloat a) => a -> a -> String
bmiTell' weight height
    | weight / height ^ 2 <= 18.5
    = "You're underweight, you emo, you!"
    | weight / height ^ 2 <= 25.0
    = "You're supposedly normal.  Pffft, I bet you're ugly!"
    | weight / height ^ 2 <= 30.0
    = "You're fat! Lose some weight, fatty!"
    | otherwise
    = "You're a whale, congratulations!"
-- Notice that there is no equal between the function and its first guard!
-- also notice that we repeat the same calculation three times!
bmiTell'' :: (RealFloat a) => a -> a -> String
bmiTell'' weight height
    | bmi <= 18.5 = "You're underweight, you emo, you!"
    | bmi <= 25.0 = "You're supposedly normal.  Pffft, I bet you're ugly!"
    | bmi <= 30.0 = "You're fat!  Lose some weight, fatty!"
    | otherwise   = "You're a whale, congratulations!"
    where bmi = weight / height ^ 2

-- Really using the where block lets us do bmiFull
-- the names only exist for this function, so they don't pollute the namespace
-- beware:
-- where blocks are not shared across function bodies of different patterns
bmiFull :: (RealFloat a) => a -> a -> String
bmiFull weight height
    | bmi <= skinny = "You're underweight, you emo, you!"
    | bmi <= normal = "You're supposedly normal.  Pffft, I bet you're fugly!"
    | bmi <= fat    = "You're fat!  Lose some weight, fatty!"
    | otherwise     = "You're a whale, congratulations!"
    where bmi    = weight / height ^ 2
          skinny = 18.5
          normal = 25.0
          fat    = 30.0
-- the above three lines could be replaced with:
-- (skinny, normal, fat) = (18.5, 25.0, 30.0)

-- calcBmis takes a list of weight/height pairs and returns a list of BMIs
calcBmis :: (RealFloat a) => [(a, a)] -> [a]
calcBmis xs = [bmi w h | (w, h) <- xs]
    where bmi weight height = weight / height ^ 2
-- the following would be cleaner with direct pattern matching in the 
-- function parameters, but this displays using where
initials :: String -> String -> String
initials firstname lastname = [f] ++ ". " ++ [l] ++ "."
    where (f:_) = firstname
          (l:_) = lastname

max' :: (Ord a) => a -> a -> a
max' a b
    | a > b     = a
    | otherwise = b
myCompare :: (Ord a) => a -> a -> Ordering
a `myCompare` b
    | a > b     = GT
    | a < b     = LT
    | otherwise = EQ

-- Let bindings
-- Where bindings let you bind to variables at the end of a function.
-- The whole function, including guards, can see where bindings.
-- Let bindings let you bind to variables anywhere but are very local.
-- Here's an example:
cylinder :: (RealFloat a) => a -> a -> a
cylinder r h =
    let sideArea = 2 * pi * r * h
        topArea  = pi * r ^ 2
    in sideArea  + 2  * topArea
-- the names you define in the 'let' part are visible to expression(s)
-- in the 'in' part of the function.
-- 'let' clauses are expressions so can be placed almost anywhere
-- 4 * (let a = 9 in a + 1) + 2 returns 42
-- [let square x = x * x in (square 5, square 3, square 2)]
--      returns [(25,9,4)]  -- we introduced a function within a list
-- (let (a,b,c) = (1,2,3) in a+b+c) * 100  returns 600
-- let's even work in list comprehensions:
calcBmis' :: (RealFloat a) => [(a, a)] -> [a]
calcBmis' xs = [bmi | (w, h) <- xs, let bmi = w / h ^ 2]

-- Case expressions
-- case expression of pattern -> result
--                    pattern -> result
--                    pattern -> result
--                    ...
--                    _       -> result
-- pattern matching with functions is really just a pretty way to write
-- case expressions!  A runtime error occurs if you fall through a case
-- with no match, so don't forget the _ if you don't match all cases.
describeList :: [a] -> String
describeList xs = "The list is " ++ case xs of []   -> "empty."
                                               [x]  -> "a singleton list."
                                               xs   -> "a longer list."
-- is equivalent to
describeList' :: [a] -> String
describeList' xs = "The list is " ++ what xs
    where what []  = "empty."
          what [x] = "a singleton list."
          what xs  = "a longer list."
