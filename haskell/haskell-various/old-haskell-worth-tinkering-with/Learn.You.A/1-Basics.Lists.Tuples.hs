
-- double me simply doubles the number passed to it
doubleMe x = x + x
-- double us doubles two numbers and sums them
doubleUs x y = x*2 + y*2
-- this only doubles the parameter if it is 100 or less
doubleSmallNumber x = if x > 100
                        then x
                        else x*2
-- else is required by if's
doubleSmallNumber' x = (if x > 100 then x else x*2) + 1
-- ' is valid in function names
conanO'Brien = "It's a-me, Conan O'Brien!"
-- functions cannot begin with caps
-- functions with no parameters are called a "definition" or a "name"
--
-- lists are important
lostNumbers = [4,8,15,16,23,42]
moreNumbers = [10,20,30,40,50]
-- (++) concatenates two lists
combineNumbers x y = x ++ y
-- allNumbers = lostNumbers ++ moreNumbers -- would also work
allNumbers = combineNumbers lostNumbers moreNumbers
-- a string is a list of chars, so (++) also concatenates strings
myName = "Lewis" ++ " " ++ "Cawthorne" ++ " " ++ "Jr"
-- the cons operator (:) can add an element to the head of a list
myNameToo = "Lewis" ++ (' ':"Cawthorne") ++ (' ':"Jr")
-- (:) takes a char and a list.  (++) takes two lists
-- adding a single element to the start with (:)
-- is much more efficient than appending to the end of a list with (++)
-- 
-- "Lewis" is a nice way of saying ['L','e','w','i','s']
-- ['L','e','w','i','s'] is a nice way to say 'L':'e':'w':'i':'s':[]
-- 
-- Lists can be compared lexographically with <,<=,>,>=,==
-- You can access element 3 of a list with `[0,1,2,3,4,5] !! 3` (num from 0)
-- head [0,1,2,3,4,5] returns 0.  tail [0,1,2,3,4,5] returns [1,2,3,4,5]
-- last [0,1,2,3,4,5] returns 5.  init [0,1,2,3,4,5] returns [0,1,2,3,4]
-- be careful not to use these on empty lists
-- length [0,1,2] returns 3.  null [0,1,2] returns False (True on []).
-- reverse [0,1,2] returns [2,1,0].  
-- take 2 [0,1,2] returns [0,1] (takes 2).  take 0 [0,1,2] returns []
-- take 5 [0,1,2] returns [0,1,2]  (you cannot take more than what is there)
-- drop 2 [0,1,2] returns [2] (it drops the first two elements
-- maximum [0,1,2] returns 2.  minimum [0,1,2] returns 0.
-- sum [0,1,2] returns 3.  product [0,1,2] returns 0.
-- elem 1 [0,1,2] returns True (1 is in list).  elem 4 [0,1,2] returns False
-- 
-- Ranges.  
-- [1..20] returns [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20]
-- ['a'..'z'] returns "abcdefghijklmnopqrstuvwxyz"
-- [2,4..20] returns [2,4,6,8,10,12,14,16,18,20] 
-- [3,6..20] returns [3,6,9,12,15,18]
-- in the last two, we specified the first two elements and the upper limit
-- you can only specify one step though, so you can do [1,2,3,8,16..100]
-- [20..1] does not work, but [20,19..1] does (step size -1)
-- Don't use floats, as usual they can be strange.
--
-- Infinite ranges work.  [1..] is 1 to infinity.
-- take 24 [13,26..] returns the first 24 multiple of 13
-- cycle [1,2,3] returns [1,2,3,1,2,3,1,2,3] (infinitely many times repeated)
-- cycle "LOL " returns "LOL LOL LOL "... (etc)
-- repeat 5 returns a list of infinitely many 5's
-- replicate 3 5 returns [5,5,5]
--
-- list comprehensions are like set comprensions
-- [x*2 | x <- [1..10]] returns [2,4,6,8,10,12,14,16,18,20]
-- this is double x for x a natural number less than or equal to 10
-- with a predicate, we could say:
-- [x*2 | x <- [1..10], x*2 >= 12] returns [12,14,16,18,20]
-- all the numbers from 50 to 100 whose remainder when divided by 7 is 3:
-- [ x | x <- [50..100], x `mod` 7 == 3]

-- actual code.  this function will replace any number in the range sent it
-- that is less than 10 and odd with "BOOM!" and any that is greater than 10
-- and odd with "BANG!" and will throw out even numbers
-- odd returns true if the number is odd / false if even
-- an element is in the new list only if the predicate (odd x) is True
boomBangs xs = [ if x < 10 then "BOOM!" else "BANG!" | x <- xs, odd x]
-- multiple predicates would look like:
-- [ x | x <- [10..20] , x /= 13, x /= 15, x /= 19]
--   would return [10,11,12,14,16,17,18,20]
-- multiple lists would look like:
-- [ x*y | x <- [2,5,10], y <- [8,10,11]] 
--   returning [16,20,22,40,50,55,80,100,110]
-- multiple lists with a predicate:
-- [ x*y | x <- [2,5,10], y <- [8,10,11], x*y > 50] returns [55,80,100,110]
-- these work with non-numeric lists too!
nouns = ["hobo","frog","pope"]
adjectives = ["lazy","grouchy","scheming"]
funnyList = [adjective ++ " " ++ noun 
            | adjective <- adjectives, noun <- nouns]

-- a simple rewrite of length
-- (_) means we don't care what we'll draw from the list so we aren't 
-- assigning it to anything.  this function will replace each element
-- of a list with 1, and then sum up the resulting list of 1's.
mylength xs = sum [ 1 | _ <- xs]
-- strings are list, so this will remove everything but uppercase letters
removeNonUppercase st = [ c | c <- st, c `elem` ['A'..'Z'] ]

-- comprehensions of lists of lists are possible also.
-- if xxs = [[1,3,5,2,3,1,2,4,5],[1,2,3,4,5,6,7,8,9],[1,2,4,2,1,6,3,1,3,2]]
-- then [ [ x | x <- xs, even x ] | xs <- xxs] would remove all odds
-- returning [[2,2,4],[2,4,6,8],[2,4,2,6,2]]

-- List elements must all be the same type (all chars, or all numbers), so:
-- Lists are for when you know the type, but not necessarily the size.
-- Tuples are for when you know the size, but not necessarily the type.
-- a size two tuple is a pair, a size three tuple is a triple.  A tuple
-- looks like (2,3) or (2,3,5) (parens instead of braces).
-- [ (1,2),(2,2),(3,8) ] is a list of three pair tuples.
-- [ ('a',3),('z',5),('2',2) ] is also.
-- [ ('a',3),('z',5),(2,2) ] is not valid (must be consistent within list).
-- Lists can contain tuples that can contain lists, like:
-- [ ("Christopher","Walken",55), ("Bruce","Springsteen",63) ]
-- or just ("Christopher","Walken",55) is a valid tuple alone.
-- Tuples must be the same size to be compared, and their are no singletons.
--
-- fst (8,11) returns 8.  snd (8,11) returns 11.  [only on pairs!]
-- zip is cool.  it combines two lists into a list of pairs:
-- zip [1,2,3,4,5] [5,5,5,5,5] returns [(1,5),(2,5),(3,5),(4,5),(5,5)]
-- zip [1..5] ["one","two","three","four","five"]
--     returns: [ (1,"one"),(2,"two"),(3,"three"),(4,"four"),(5,"five") ]
-- the longer list is cut off to match the shorter list in zip's
-- zip [1..] ['a','b','c'] returns [ (1,'a'),(2,'b'),(3,'c')]

-- finding right triangles with a permiter of 24...
-- representing triangles as triples is logical
-- we can find all triangles with sides equal to or smaller than 10:
triangles = [ (a,b,c) | c <- [1..10], b <- [1..10], a <- [1..10] ]
-- now if we use a predicate, we can make sure they are right triangles
-- and we will modify our ranges to make sure c (hypoteneuse is larger 
-- than the other sides
rightTriangles = [ (a,b,c)
                 | c <- [1..10], b <- [1..c], a <- [1..b]
                 , a^2 + b^2 == c^2]
-- The next step is modifying this to let us know which one(s) have 
-- a perimeter equal to 24 by adding another predicate
rightTriangles' = [ (a,b,c)
                  | c <- [1..10], b <- [1..c], a <- [1..b]
                  , a^2 + b^2 == c^2, a+b+c == 24]

