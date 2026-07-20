-- modules must be imported before functions are declared
--
-- Data.List has useful function for working with lists
import Data.List
-- import Data.List (nub, sort) would only import nub and sort functions
-- import Data.List hiding (nub) would import all except nub from Data.List
--
-- Data.Map has many functions that nameclash with Prelude functions 
-- such as filter and null.  So a qualified import is in order.
import Data.Map as M
-- now we can access Data.Map.Filter as M.Filter

-- Data.Char module exports functions that deal with characters.
-- It's also helpful when filter and mapping over strings.
import Data.Char

-- Data.Set modules supports mathematical like sets.
-- It is wise to import it qualified
import Data.Set as S

-- Geometry is a simple module that I made!  Geometry.hs
import Geometry
-- This could also be a directory called Geometry with sub-modules
-- called sphere.hs, cuboid.hs and cube.hs.  They would be imported as
-- import qualified Geometry.Sphere as Sphere

-- nub is a function from Data.List that takes a list
-- and weeds out duplicate elements
-- this will return the number of unique items in a list
numUniques :: (Eq a) => [a] -> Int
numUniques = length . nub

-- Data.List has a number of list related functions
--
-- 'intersperse' takes an element and a list and then puts the element
-- between each pair of the list.  for example:
-- intersperse '.' "MONKEY" returns "M.O.N.K.E.Y"
-- intersperse 0 [1,2,3] returns [1,0,2,0,3]
--
-- 'intercalate' takes a list and a list and then inserts the first list
-- between each element of the secnod lists and flattens the result
-- intercalate " " ["hey","there","guys"] returns "hey there guys"
-- intercalate [0,0,0] [[1,2],3] returns [1,2,0,0,0,3]
--
-- 'transpose' transposes a list of results
-- if you think of a list of lists as a 2D matrix, then 
-- the columns become the rows and vice versa
-- transpose [[1,2,3],[4,5,6],[7,8,9]] returns [[1,4,7],[2,5,8],[3,6,9]]
-- transpose ["hey","there","guys"] returns ["htg","ehu","yey","rs","e"]
--
-- a good transpose example involves adding polynomails
-- let's say we want to add 3x^2+5x+9, 10x^3+9 and 8x^3+5x^2+x-1
-- if we represented them as [0,3,5,9], [10,0,0,9], [8,5,1,-1]
--  (lists of coefficients) then we can:
-- map sum $ transpose [[0,3,5,9],[10,0,0,9],[8,5,1,-1]] returns [18,8,6,17]
-- transpose puts all the proper powers into proper lists, and sum sum's them
--
-- foldl' and foldl1' are strict versions of foldl and foldl1 
-- they update their accumulator as they go to prevent stack overflow
-- errors when doing large lazy flows
--
-- 'concat' flattens a list into just a list of elements
-- (as opposed to a list of lists).  it removes one level of nesting per call
-- concat ["foo","bar","car"] returns "foobarcar"
-- concat [[3,4,5],[1,2,3],[2,1,1] returns [3,4,5,1,2,3,2,1,1]
-- concat [[[2,3],[3,4,5],[2]],[[2,3],[3,4]]] returns [[2,3,3,4,5,2],[2,3,3,4]]
--
-- 'concatMap' is the same as mapping a function to a list and the
-- flattening the list with concat
--
-- 'and' takes a list of boolean values and returns True only if
-- all values within the list are True
-- and $ map (>4) [5,6,7,8] returns True
-- and $ map (==4) [4,4,4,3,4] returns False
--
-- 'or' is like and, but returns True if any value in the list is True
-- or $ map (==4) [2,3,4,5,6,1] returns True
-- or $ map (>4) [1,2,3] returns False
--
-- 'any' and 'all' take a predicate and then check if any or all the elements
-- in a list satify the predicate, respectively.  They are the equivalent of
-- mapping a function of a list and doing 'and' or 'or' like we just saw.
-- any (==4) [2,3,5,6,1,4] returns True
-- all (>4)  [6,9,10) returns True
-- all (`elem` ['A'..'Z']) "HEYGUYSwhatsup" returns False
-- any (`elem` ['A'..'Z']) "HEYGUYSwhatsup" returns True
--
-- 'iterate' takesa  function and a starting value.
-- It applies the function to the starting value, then applies the 
-- function to the result, then to the result again, etc.  
-- It returns all the reuslts in the form of an infinite list.
-- take 10 $ iterate (*2) 1 returns [1,2,4,8,16,32,64,128,256,512]
-- take 3 $ iterate (++ "haha") "haha" returns 
--      ["haha","hahahaha","hahahahahaha"]
--
-- 'splitAt' takes a number and a list and splits the list at that many
-- elements.  It returns the results as a Tuple (pair) of two lists.
-- splitAt 3 "heyman" returns ("hey","man")
-- splitAt 100 "heyman" returns ("heyman","")
-- splitAt (-3) "heyman" returns ("","heyman")
-- let (a,b) = splitAt 3 "fooBar" in b ++ a returns "barfoo"
--
-- 'takeWhile' is handy.  It takes from a list while a predicate remains True
-- takeWhile (>3) [6,5,4,3,2,3,4,5,3,1,8] returns [6,5,4]
-- takeWhile (/=' ') "This is a sentence" returns "This"
--   We can easily find the sum of all the third powers under 10,000:
-- sum $ takeWhile (<10000) $ map (^3) [1..] returns 53361
--
-- 'dropWhile' drop elements from a list while the predicate is True
-- It returns whatever is left when it is done dropping.
-- dropWhile (/=' ') "This is a sentence" returns " is a sentence"
-- dropWhile (>3) [6,5,4,3,2,3,4,5,3,1,8] returns [3,2,3,4,5,4,1,8]
--
-- 'span' is like 'takeWhile' but returns a pair of lists as a tuple.
-- The first list is what takeWhile would return.
-- The second list is the rest of the list (what dropWhile would return)
-- 'break' works sort of the same, except it breaks the list into two
-- where ever the predicate becomes True.
-- span  (/=4) [1,2,3,4,5,6,7] returns ([1,2,3],[4,5,6,7])
-- break (==4) [1,2,3,4,5,6,7] returns ([1,2,3],[4,5,6,7])
-- span  (<4)  [1,2,3,4,5,6,7] returns ([1,2,3],[4,5,6,7])
-- break (>3)  [1,2,3,4,5,6,7] returns ([1,2,3],[4,5,6,7])
-- let (fw, rest) = span (/=' ') "This is a sentence" 
--     in "First word:" ++ fw ++ ", the rest:" ++ rest
-- 'span' spawns while the predicate is True.  
-- 'break' breaks the list when the predicate is first True.
-- break p is equivalent to span (not . p)
--
-- 'sort' sorts a list as long as its elements are of the Ord typeclass
-- sort [8,5,3,2,1,6,4,2] returns [1,2,2,3,4,5,6,8]
--
-- 'group' takes a list and groups adjacent elements into sublists 
-- if they are equal
-- group [1,1,1,2,2,2,3,2,2,2,5,6,7]
--   returns [[1,1,1],[2,2,2],[3],[2,2,2],[5],[6],[7]]
-- sorting a list before grouping allows for counting element occurences
-- map (\l@(x:xs) -> (x,length l)) . 
--      group . sort $ [1,1,1,1,2,2,2,2,3,3,2,2,2,5,6,7]
--   returns [(1,4),(2,7),(3,2),(5,1),(6,1),(7,1)]
--
-- 'inits' and 'tails' are like 'init' and 'tail' but they 
-- recursively reapply until there is nothing left
-- inits "w00t" returns ["","w","w0","w00","w00t"]
-- tails "w00t" returns ["w00t","00t","0t","t",""]
-- let w = "w00t" in zip (inits w) (tails w) returns
--     [("","w00t"),("w","00t"),("w0","0t"),("w00","t"),("w00t","")]

-- Here's using a fold to implement searching a list for a sublist
search :: (Eq a) => [a] -> [a] -> Bool
search needle haystack = 
    let nlen = length needle
    in  foldl (\acc x -> if take nlen x == needle then True else acc) 
                False (tails haystack)
-- this search function behaves like isInfixOf

-- 'isPrefixOf' and 'isSuffixOf' search for a sublist at the beginning
-- and at the end of a list, respectively
-- 'elem' and 'notElem' check if an element is or isn't inside a list
--
-- 'partition' takes a predicate and a list and returns a pair of lists
-- the first list is all members that satisfy the predicate
-- the second list is all members that do not
-- partition (`elem` ['A'..'Z']) "BOBsidneyMORGANeddy"
--   returns ("BOBMORGAN","sidneyeddy")
-- partition (>3) [1,5,2,3,4,5,6] returns ([5,5,6],[1,2,3,4])
-- as opposed to 'span'/'break', 'partition' goes through the entire list
-- and splits it according to the predicate rather than stopping early
--
-- 'find' takes a predicate and a list and returns the first element
-- that satisfies the predicate wrapped in a Maybe value
-- A Maybe value can be "Just something" or "Nothing"
-- find (>4) [1,2,3,4,5,6] returns Just 5
-- find (>9) [1,2,3,4,5,6] returns Nothing
-- :t find returns find :: (a -> Bool) -> [a] -> Maybe a
-- A Maybe can only return one element or no elements
--
-- 'elemIndex' is like 'elem' but returns the index of the element we are
-- looking for or Nothing (as a maybe):
-- elemIndex :: (Eq a) => a -> [a] -> Maybe Int
-- 4 `elemIndex` [1,2,3,4,5,6] returns Just 3
-- 10 `elemIndex` [1,2,3,4,5,6] returns Nothing
--
-- 'elemIndices' works the same, but returns a list of Indices
-- This does not use a Maybe type; failure is just an empty list
-- ' ' `elemIndices` "Where are the spaces?" returns [5,9,13]
--
-- 'findIndex' and 'findIndices' work the same, but they look for elements
-- that match a predicate.  findIndex (==4) xs is the same as elemIndex 4 xs
-- but 'findIndex' and 'findIndices' work with things like (>4) or (/=' ')
-- findIndices (`elem` ['A'..'Z']) "Where Are The Caps?" returns [0,6,10,14]
--
-- 'zip' and 'zipWith' have 'zip3' and zipWith3' equivalents
-- the number part can go up to 7
-- zipWith3 (\x y z) -> x + y + z) [1,2,3] [4,5,2,2] [2,2,3] returns [7,9,8]
-- zip4 [2,3,3] [2,2,2] [5,5,3] [2,2,2] returns [(2,2,5,2),(3,2,5,2),(3,2,3,2)]
--
-- 'lines' takes a string and returns every line of that string in a 
-- separate list
-- lines "first line\nsecond line\nthird line" returns:
--       ["first line","second line","third line"]
-- 'unlines' is the reverse of lines and joins strings together using a '\n'
-- 'words' and 'unwords' do the same, but for words with ' ' delimter
-- multiple spaces act like one space.
--
-- 'nub' takes a list and weeds out duplicates, returning a list of uniques
-- "nub" means a small lump or essential part of something
--
-- 'delete' takes an element and a list and delets the first occurence of 
-- that element from the list
-- delete 'h' "hey you hip guys!" returns "ey you hip guys!"
--
-- '\\' is the list difference function and works as an infix op
-- It removes any elements in the right-hand list from the left hand list
-- [1..10] \\ [2,5,9] returns [1,3,4,5,6,8,10]
-- "Im a big baby" \\ "big" returns "Im a  baby"
-- [1..10] \\ [2,5,9] is like delete 2 . delete 5 . delete 9 $ [1..10]
--
-- 'union' returns the union of two lists 
-- duplicates are removed from the second list (since it is a set union)
-- union "hey man" "man what's up" returns "hey man wt'sup"
-- union "hey hey hey" "hey man what it is?" returns "hey hey heymanwtis?"
-- [1..7] `union` [5..10] returns [1,2,3,4,5,6,7,9,10]
-- 'intersect' returns any elements found in both lists
-- [1..7] `intersect` [5..10] returns [5,6,7]
--
-- 'insert' adds an element to a list before the next element greater or equal
-- to the new element.  if used on a sorted list, the new list will be sorted
-- insert 4 [3,5,1,2,8,2] returns [3,4,5,1,2,8,2]
-- insert 4 [1,3,4,4,1] returns [1,3,4,4,4,1]
-- insert 4 [1,2,3,5,6,7] returns [1,2,3,4,5,6,7]
-- insert 3 [1,2,4,3,2,1] returns [1,2,3,4,3,2,1]
--
-- Data.List also has equivalents to length,take,drop,splitAt,!! and replicate
-- called 'genericLength','genericTake','genericDrop','genericSplitAt',
-- 'genericIndex' and 'genericReplicate'.  signatures:
-- length :: [a] -> Int
-- genericLength :: (Num a) => [b] -> a
-- so 'genericLength' returns a Num instead of an Int, so we could:
-- let xs = [1..6] in sum xs / genericLength xs   to get an average
--
-- There are also more general equivalents to 'nub','delete','union',
-- 'intersect',and 'group' called 'nubBy','deleteBy','unionBy',
-- 'intersectBy', and 'groupBy'.  The first functions use == to test for
-- equality, where the second set take an equality function and compare
-- the values using it.  group is the same as groupBy (==)
--
-- Data.Function on is often used with by functions (import Data.Function (on))
-- on :: (b -> b -> c) -> (a -> b) -> a -> a -> c
-- f `on` g = \x y -> f (g x) (g y)
-- (==) `on` (> 0) returns an equality function like \x y -> (x>0) == (y>0)
-- groupBy (\x y -> (x > 0) == (y > 0)) values  is equivalent to
-- groupBy ((==) `on` (> 0)) values
-- English: 
-- Group this list by equality on whether the elements are greater than zero.
--
-- There are also 'sortby','insertBy','maximumBy' and 'minimumBy' that
-- take a function to determine which element is greater, smaller or equal.
-- 'sort' is the equivalent to sortBy compare
-- sortBy (compare `on` length) xs would sort lists by length
-- compare `on` length is equivalent to
-- \x y -> length x `compare` length y
--
-- Where you are dealing with By function that take an equality function
-- you usualy do ((==) `on` something) and with By functions that take an
-- ordering function you often do (compare `on` something)

-- Data.Char
-- Data.Char has functions to work with characters.
--
-- Data.Char exports a bunch of predicates over characters, 
-- functions that take a character and tell us whether something about
-- the character is true or false.  Here's a self-explanatory list:
-- 'isControl','isSpace','isLower','isUpper','isAlpha','isAlphaNum',
-- 'isPrint','isDigit','isOctDigit','isHexDigit','isLetter',
-- 'isMark' (basically if it is an accented letter), 'isNumber',
-- 'isPunctuation','isSymbol','isSeparator' (space or other separator),
-- 'isAscii' (first 128 chars of Unicode), 
-- 'isLatin1' (first 256 chars of Unicode),
-- 'isAsciiUpper','isAsciiLower'.
-- All the predicates have a signature of Char -> Bool
--
-- all isAlphaNum "bobby283" returns True
-- all isAlphaNum "eddy the fish!" returns False
--
-- 'generalCategory' returns a general category of a character
-- generalCategory ' ' returns Space
-- generalCategory " \\t\nA9?" returns
--   [Space,Control,Control,UppercaseLetter,DecimalNumber,OtherPunctuation]
--
-- 'toUpper' converts a char to uppercase and ignores spaces, numbers, etc.
-- 'toLower' converts a char to lowercase and ignores spaces, numbers, etc.
-- 'toTitle' converts a char to titlecase.  For most chars this is upper-case.
-- 'digitToInt' converts a character to an Int (for any char '0'..'9','a'..'f'
-- map digitToInt "34538" returns [3,4,5,3,8]
-- map digitToInt "FF85AB" returns [15,15,8,5,10,11]
-- 'intToDigit' converts an int from 0..15 to a lowercase char
-- intToDigit 15 returns 'f'
--
-- 'ord' converts a character to its code
-- 'chr' converts a code to its character
-- ord 'a' returns 97       chr 97 returns 'a'
--
-- a simple Caesar cipher
encode :: Int -> String -> String
encode shift msg = 
    let ords = Data.List.map ord msg
        shifted = Data.List.map (+ shift) ords
    in  Data.List.map chr shifted
decode :: Int -> String -> String
decode shift msg = encode (negate shift) msg

-- Data.Map
-- Association lists or Dictionaries are supported through Data.Map
-- They are key-value pairs where ordering doesn't matter.
-- Data.Map association lists are internally implemented with trees.
--
-- 'fromList' is M.fromList :: (Ord k) => [(k, v)] -> M.Map k v
--   the k is the key; the v is the value in the key,value pair
-- M.fromList [("betty","555-2938"),("jenn","5422928"),("lucille","205-2928")]
--   it returns a map with the same associations, discarding duplicate keys
-- 'empty' returns an empty map (M.empty returns fromList [])
-- 'insert' takes a key, a value and a map and returns a new map
-- M.insert 3 100 M.empty returns fromList [(3,100)]
-- 'null' checks if a map is empty
-- 'size' reports the size of a map
-- 'singleton' takes a key and a value and creates a map with that one pair
-- 'lookup' returns 'Just something' if it finds something or Nothing
-- 'member' takes a key and a map and reports if the key is in the map (Bool)
-- 'map' and 'filter' work like on lists (but use M.map and M.filter)
-- 'toList' takes a map and returns a standard list of key,value tuples
-- 'keys' returns a list of all the keys in a map
-- 'elems' returns a list of all the elements in a map
-- 'keys' is equivalent to map fst . M.toList
-- 'elems' is equivalent to map snd . M.toList
-- 'fromListWith' is like 'fromList' except it uses a function supplied to
--   it to decide what to do with duplicate key values instead of discarding.
phoneBookList = 
    [("betty","555-2938")
    ,("betty","342-2492")
    ,("bonnie","452-2928")
    ,("patsy","593-2928")
    ,("patsy","943-2929")
    ,("patsy","827-9162")
    ,("lucille","205-2928")
    ,("wendy","939-8282")
    ,("penny","853-2492")
    ,("penny","555-2111")
    ]
-- fromList phoneBookList returns
--   fromList [("betty","555-2938"),("bonnie",452-2928"),("patsy","593-2938")
--            ,("lucille","205-2928"),("wendy","939-8282"),("penny","853-2492")
--            ]  -- we just lost a few of those digits!
-- We can fix that with 'fromListWith'
phoneBookToMap :: (Ord k) => [(k, String)] -> M.Map k String
phoneBookToMap xs = M.fromListWith 
                  (\number1 number2 -> number1 ++ ", " ++ number2) xs
-- M.lookup "patsy" $ phoneBookToMap phoneBookList returns
--   Just "827-9162, 943-2929, 593-2928"
-- Same thing, but we want to return lists of numbers instead of strings:
phoneBookToListMap :: (Ord k) => [(k, a)] -> M.Map k [a]
phoneBookToListMap xs = M.fromListWith 
                      (++) $ Data.List.map (\(k,v) -> (k,[v])) xs
-- M.lookup "patsy" $ phoneBookToListMap phoneBookList returns
--   Just ["827-9162","943-2929","593-2928"]
--
-- Another useful example if if you just want the greatest value 
-- associated with each key to be in the final map:
-- M.fromListWith max 
--      [(2,3),(2,5),(2,100),(3,29),(3,22),(3,11),(4,22),(4,15)]  returns:
--   fromList [(2,100),(3,29),(4,22)] 
-- or to add together values with equal keys
-- M.fromListWith (+) [(2,3),(2,5),(2,100),(3,29)] returns 
--   fromList [(2,108),(3,29)]
-- 'insertWith' is like 'insert' like 'fromListWith' is like 'fromList'
-- M.insertWith (+) 3 100 $ Map.fromList [(3,4),(5,103),(6,339)] returns
--   fromList [(3,104),(5,103),(6,339)]
-- with a standard 'insert' the new value would have been discarded

-- Data.Set
-- Sets are a cross between lists and maps, and operate like mathematical sets.
-- They are internally trees, so faster to work with than lists.
-- Each element of a set is ordered and unique.  Let's do some simple examples
text1 = "I just had an anime dream. Anime... Reality... Are they so different?"
text2 = 
  "The old man left his garbage can out and now his trash is all over my lawn!"
set1 = S.fromList text1
set2 = S.fromList text2
-- GHCI outputs shows us the following:
-- *Main> set1
-- fromList " .?AIRadefhijlmnorstuy"
-- *Main> set2
-- fromList " !Tabcdefghilmnorstuvwy"
-- 'intersection' shows us what both sets share
-- *Main> S.intersection set1 set2
-- fromList " adefhilmnorstuy"
-- 'difference' shows what is in the first set but not in the second
-- *Main> S.difference set1 set2
-- fromList ".?AIRj"
-- 'difference' also works the other way (order is important)
-- *Main> S.difference set2 set1
-- fromList "!Tbcgvw"
-- 'union' gives us all unique letters in both sentences
-- *Main> S.union set1 set2
-- fromList " !.?AIRTabcdefghijlmnorstuvwy"
-- 'null','size','member','empty','singleton','insert',and 'delete' also work
-- 
-- 'isSubsetOf' and 'isProperSubsetOf' are also defined.
-- Set A is a subset of set B if B contains all the elements that A does.
-- Set A is a proper subset of B if B contains all the elemnts that A does
--     and B has more elements than A.
-- Data.Set also exports a 'map' and 'filter' to work with sets.
-- S.filter odd $ S.fromList [3,4,5,6,7,2,3,4] returns [3,4,7]
--
-- Sets can be used to quickly sort lists and weed out duplicates by 
-- converting to set and back.  It is faster than nub:
setNub xs = S.toList $ S.fromList xs
-- *Main> setNub "HEY WHATS CRACK"
-- " ACEHKRSTWY"
-- *Main> nub "HEY WHATS CRACK"
-- "HEY WATSCRK"
