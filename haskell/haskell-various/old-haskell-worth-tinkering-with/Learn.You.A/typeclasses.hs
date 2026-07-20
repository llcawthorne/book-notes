
import qualified Data.Map as M

-- This chapter is on making your own Types and Typeclasses
--
-- We define a new type using the 'data' keyword.  
-- Both the name and the value constructors have to be capital cased.
-- Here is how some stdlib types are defined:
-- data Bool = False | True
-- Int is something like (but not exactly):
-- data Int  = -2147483648 | -2147483647 | ... | -1 | 0 | 1 | ... | 2147483647
--
-- Here's a type to represent a circle or rectangle
-- The 'deriving (Show)' lets us make our Shap part of the Show typeclass
-- Originally:
-- data Shape = Circle Float Float Float | Rectangle Float Float Float Float
--              deriving (Show)
-- Shapes that use points are more understandable:
data Point = Point Float Float deriving (Show)
data Shape = Circle Point Float | Rectangle Point Point deriving (Show)
-- Basically, a Shape can be a Circle or a Rectangle
-- The Circle value constructor has three fields (center-x, center-y, radius)
-- The Rectangle value constructor has three fields for the 
--     (top-left-x, top-left-y, lower-right-x, lower-right-y)
-- These fields are parameters to the constructor functions
-- *Main> :t Circle
-- Circle :: Float -> Float -> Float -> Shape
-- *Main> :t Rectangle
-- Rectangle :: Float -> Float -> Float -> Float -> Shape
--
-- Here's a function that takes any Shape and returns its surface.
-- Originally:
-- surface :: Shape -> Float
-- surface (Circle _ _ r) = pi * r ^ 2
-- surface (Rectangle x1 y1 x2 y2) = (abs $ x2 - x1) * (abs $ y2 - y1)
-- surface $ Circle 10 20 10 returns 314.15927
-- surface $ Rectangle 0 0 100 100 returns 10000.0
-- Now with points:
surface :: Shape -> Float
surface (Circle _ r) = pi * r ^ 2
surface (Rectangle (Point x1 y1) (Point x2 y2))
        = (abs $ x2 - x1) * (abs $ y2 - y1)
-- nudge is a function to nudge our shape an x y amount
nudge :: Shape -> Float -> Float -> Shape
nudge (Circle (Point x y) r) a b = Circle (Point (x+a) (y+b)) r
nudge (Rectangle (Point x1 y1) (Point x2 y2)) a b
      = Rectangle (Point (x1+a) (y1+b)) (Point (x2+a) (y2+b))
-- baseCircle is a circle with center (0,0) and radius r
baseCircle :: Float -> Shape
baseCircle r = Circle (Point 0 0) r
baseRect :: Float -> Float -> Shape
baseRect width height = Rectangle (Point 0 0) (Point width height)

-- you can export datatypes from modules by putting them in the 
-- module ModuleName ( [exports] ) where array
-- You have to specify value constructors to export in parentheses or
-- To export all constructors for a type, you use (..).
-- For example:
-- module Shapes
-- ( Point(..)
-- , Shape(..)
-- , surface
-- , nudge
-- , baseCircle
-- , baseRect
-- ) where
-- If we had not done Shape(..), we could have done Shape(Rectangle, Circle)
-- Also, we could have exported Shape without () to define shape but make 
-- it impossible to call its constructors from the outside.
-- Someone importing the module would have to make Shapes through the
-- public baseCircle and baseRect functions.

-- Record Syntax
-- Let's say we want to store the first name, last name, age, height,
-- phone number, and favorite ice-cream flavor of a person or persons
--
-- the naive approach is like so, and involves pattern matching to access data
-- data Person = Person String String Int Float String String deriving (Show)
guy = Person "Buddy" "Finkelstein" 43 184.2 "526-2928" "Chocolate"
--
-- Record syntax is alot like Python dictionaries, IMHO
-- Haskell includes an alternative way to write data types, record syntax
data Person = Person { firstName :: String
                     , lastName  :: String
                     , age       :: Int
                     , height    :: Float
                     , phoneNum  :: String
                     , flavor    :: String
                     } deriving (Show)
-- by doing this, Haskell automatically creates firstName, lastName, 
-- age, height, phoneNum and flavor accessor functions and show looks nicer:
-- Person {firstName = "buddy", lastName = "finkel", age = 30, 
--         height = 6.0, phoneNum = "867-5309", flavor = "choc"}
-- firstName guy returns "buddy"

-- Record Syntax makes sense any time you have several fields and it isn't
-- obvious what they are.
-- data Vector = Vector Int Int Int  is fairly self-explanatory
-- data Person = Person String String Int Int String String  is not

-- Type Parameters
-- Type Constructors take types as parameters to produce new types.
-- It is alot like templates in C++.  Let's look at:
-- data Maybe a = Nothing | Just a
-- a is the type parameter, so Maybe is a type constructor
--   (compare to Person = Person String  (not Person a =)
-- 'Maybe' is not a type per se.  The type constructor will produce a
-- 'Nothing', 'Maybe Int', 'Maybe Char', 'Maybe String', 'Maybe Person', etc
-- Behind the scenes, lists also work like this.
--
-- Nothing is a polymorphic type "Maybe a" that contains nothing.
-- It can be given to something that requires any Maybe whatever
--
-- Type parameters make sense when the type conitained inside the data
-- type's value constructors isn't that important for the type to work.
-- A list of stuff is a list of stuff, no matter what that stuff is.
-- Maybe represents having Nothing, or having one of something.
-- Map k v, it doesn't matter what type the key or the value is.
--
-- Convention: Never add typeclass constraints in data declarations!
-- You need them in the functions either way, but if you put them in the
-- data declarations ALL functions require the constraints, even if the
-- constraints do not matter to the function in question.
--
-- Let's do a parameterized 3D vector type that will usually hold numbers
-- A simple vector type:
data Vector a = Vector a a a deriving (Show)

-- 'Vector t' (the first part of our data whatever =) not 'Vector t t t'
vplus :: (Num t) => Vector t -> Vector t -> Vector t
(Vector i j k) `vplus` (Vector l m n) = Vector (i+l) (j+m) (k+n)

vectMult :: (Num t) => Vector t -> t -> Vector t
(Vector i j k) `vectMult` m = Vector (i*m) (j*m) (k*m)

scalarMult :: (Num t) => Vector t -> Vector t -> t
(Vector i j k) `scalarMult` (Vector l m n) = i*l + j*m + k*n
-- The functions only work on numeric vectors (which makes sense)
-- but we can declare any type of vector as long as the three components
-- are all of the same type.

-- Derived Instances
-- We have already seen the 'deriving' keyword with (Show)
-- Haskell can automatically make our type an instance of:
-- Eq, Ord, Enum, Bounded, Show, Read through 'deriving'
--
data Person' = Person' { firstName' :: String
                       , lastName'  :: String
                       , age'       :: Int
                       } deriving (Eq,Show,Read)
-- As long as the types of each field are of the Eq class, Haskell
-- can test for equality on our new type by comparing each of the fields.
mikeD = Person' {firstName' = "Michael", lastName' = "Diamond", age' = 43}
adRock = Person' {firstName' = "Adam", lastName' = "Horovitz", age' = 41}
mca = Person' {firstName' = "Adam", lastName' = "Yauch", age' = 44}
beastieBoys = [mca, adRock, mikeD]
-- Here's some GHC output showing Eq and Show in action
-- *Main> let lewisC = Person' {firstName' = "Lewis", lastName' = "Cawthorne", age' = 32}
-- *Main> lewisC
-- Person' {firstName' = "Lewis", lastName' = "Cawthorne", age' = 32}
-- *Main> mikeD
-- Person' {firstName' = "Michael", lastName' = "Diamond", age' = 43}
-- *Main> mikeD `elem` beastieBoys   -- elem requires Eq typeclass
-- True
-- *Main> lewisC `elem` beastieBoys 
-- False
--
-- deriving (Ord) works like you would expect, comparing internal elements
-- lexicographically.  but if there are multiple definitions for a type,
-- then they first are looked at in order of definition.
-- Thus, False is less than True in Bool 
--       Nothing is less than any Just a type in Maybe and 
--       Circle is less than Rectangle in our earlier defined Shape.
-- Person' doesn't have an | in its data def, so internal elements are
--       always compared lexicographically
--
-- If all the value contructors take no parameters, we can use deriving (Enum)
-- Enum's have predecessors and sucessors
-- Bounded is for things that have a lowest and highest possible value
data Day = Monday | Tuesday | Wednesday | Thursday | Friday 
         | Saturday | Sunday deriving (Eq, Ord, Show, Read, Bounded, Enum)
-- succ Monday returns Tuesday
-- pred Thursday returns Wednesday
-- minBound :: Day returns Monday
-- [Thursday .. Sunday] returns [Thursday,Friday,Saturday,Sunday]
-- [minBound .. maxBound] :: Day returns a list of all 7 days

-- Type synonyms
-- Type synonyms are interchangeable types (like [Char] and String
-- The standard library defines String as a list of Char like so:
-- type String = [Char]
-- The 'type' keyword doesn't make anything new (unlike 'data')
-- It just lets us call our type something else
--
-- Let's revisit our phoneBook.
-- It was an association list of key-value pairs like:
-- phoneBook :: [(String,String)]
-- we could just do this:
-- type PhoneBook = [(String,String)]
-- but let's try the following:
type PhoneNumber = String
type Name = String
type PhoneBook = [(Name,PhoneNumber)]

phoneBook :: PhoneBook
phoneBook = 
    [("betty","555-2938")
    ,("bonnie","452-2928")
    ,("patsy","493-2928")
    ,("lucille","205-2928")
    ,("wendy","939-8282")
    ,("penny","853-2492")
    ]
inPhoneBook :: Name -> PhoneNumber -> PhoneBook -> Bool
inPhoneBook name pnumber pbook = (name,pnumber) `elem` pbook
-- if we hadn't used type synonyms, the function type would have been
-- String -> String -> [(String,String)] -> Bool
-- The synonyms simply allowed us to convey more meaning
--
-- Type synonyms can also be parameterized.
type AssocList k v = [(k,v)]
-- then a header for a func to find a value by key might be:
-- (Eq k) => k -> AssocList k v -> Maybe v
-- You can also partially apply type synonyms
-- short-hand for a map from integers to something would be:
-- type IntMap v = M.Map Int v   OR
-- type IntMap = M.Map Int
--
-- an internal type is:
-- data Either a b = Left a | Right b deriving (Eq, Ord, Read, Show)
-- Either a b is often used to convey failure information
-- Left will hold something that helps us locate the error
-- Right will hold the results of the computation
--
-- Here's an example
-- The new datatype just represents if a locker is taken or free
-- and Code is just a synonym for String.
data LockerState = Taken | Free deriving (Show, Eq)
type Code = String
type LockerMap = M.Map Int (LockerState, Code)

lockerLookup :: Int -> LockerMap -> Either String Code
lockerLookup lockerNumber map = 
    case M.lookup lockerNumber map of
        Nothing -> Left $ "Locker number " ++ show lockerNumber 
                ++ " doesn't exist!"
        Just (state, code) -> if state /= Taken
                                 then Right code
                                 else Left $ "Locker " ++ show lockerNumber
                                           ++ " is already taken!"
-- Either we return a code on success as a 'Right'
-- or we return a String error message
lockers :: LockerMap
lockers = M.fromList
    [(100,(Taken,"ZD39I"))
    ,(101,(Free,"JAH3I"))
    ,(103,(Free,"IQSA9"))
    ,(105,(Free,"QOTSA"))
    ,(109,(Taken,"893JJ"))
    ,(110,(Taken,"99292"))
    ]
-- *Main> lockerLookup 101 lockers
-- Right "JAH3I"
-- *Main> lockerLookup 100 lockers
-- Left "Locker 100 is already taken!"
-- *Main> lockerLookup 102 lockers
-- Left "Locker number 102 doesn't exist!"
--
-- Maybe a could have represented the result, but then we would not
-- know whether the locker was taken or didn't exist on failure.

-- Recursive Data Structures
-- Here's a recursive definition of a List
-- data List a = Empty | Cons a (List a) deriving (Show, Read, Eq, Ord)
-- It's either empty or a combination of a head with some value and a list.
-- It could also be written:
-- data List a = Empty | Cons { listHead :: a, listTail :: List a} der...
-- 4 `Cons` (5 `Cons` Empty) is like 4:(5:[])
--
-- 'infixr' and 'infixl' define precedence and associate direction
-- Here's what ++ looks like to add two lists
-- infixr 5 ++
-- (++) :: [a] -> [a] -> [a]
-- []      ++ ys = ys
-- (x:xs)  ++ ys = x : (xs ++ ys)
--
-- Binary Search Tree
-- Data.Set and Data.Map use balanced binary search trees.
-- For right now though, let's implement a normal binary search tree.
-- Recursively: A tree is either empty, or a value and two subtrees
data Tree a = EmptyTree | Node a (Tree a) (Tree a) deriving (Show, Read, Eq)
-- our inert will take an element and a tree, and return a tree with 
-- the new element in the proper location
singleton :: a -> Tree a
singleton x = Node x EmptyTree EmptyTree

treeInsert :: (Ord a) => a -> Tree a -> Tree a
-- edge: if we are trying to insert in an empty tree, just put a singleton
treeInsert x EmptyTree = singleton x
treeInsert x (Node a left right)
    | x == a = Node x left right
    | x < a  = Node a (treeInsert x left) right
    | x > a  = Node a left (treeInsert x right)

treeElem :: (Ord a) => a -> Tree a -> Bool
-- edge if we are searching in an empty tree, we won't find anything
treeElem x EmptyTree = False
treeElem x (Node a left right)
    | x == a = True
    | x < a  = treeElem x left
    | x > a  = treeElem x right

nums = [8,6,4,1,7,3,5]
numsTree = foldr treeInsert EmptyTree nums
-- now we can search out elements and print out our new trees in GHCi

-- Typeclasses 102
-- Typeclasses are like java interfaces.
-- A Typeclass defines some behavior and then types that can behave
--   in that fashion are made instances of that typeclass.
-- The behavior is achieved by defining functions of type declarations
--   that we then implement.
--
-- 'Eq' is stuff that can be equated.
-- It defines the functions == and /=.
-- Prelude defines Eq as:
-- class Eq a where
--      (==) :: a -> a -> Bool
--      (/=) :: a -> a -> Bool
--      x == y = not (x /= y)
--      x /= y = not (x == y)
-- After making the class, it isn't very useful until something is a member.
-- let's do a non-derived instance of Eq using TrafficLight datatype
data TrafficLight = Red | Yellow | Green
instance Eq TrafficLight where
    Red     == Red      = True
    Green   == Green    = True
    Yellow  == Yellow   = True
    _       == _        = False
-- 'class' is for defining typeclasses.  
-- 'instance' is for making our types instances of typeclasses
-- since == is defined in terms of /= and vice-versa, 
--      we only had to overwrite one of them in the declaration.
-- to complete the 'minimal complete defintion' for Eq
--      we must overwrite one of == or /=
instance Show TrafficLight where
    show Red    = "Red light"
    show Yellow = "Yellow light"
    show Green  = "Green light - Go!"
-- while we could have just derived Eq
-- our new Show actually has some special functionality.
-- sub-classes also work.  The first part of the Num class declaration is:
-- class (Eq a) => Num a where
-- Something must be of Eq class to be eligible to be a Num.
-- the Eq for Maybe would look like:
-- instance (Eq m) => Eq (Maybe m) where
--      Just x  == Just y  = x == y
--      Nothing == Nothing = True
--      _       == _       = False
-- Normally constraints in class declarations are used to make subclasses
--          constraints in instance declarations are used to express 
--          requirements about the contents of some type
-- In GHCI, ':info Num' will show which functions Num defines and the types
--          in the typeclass.
--          ':info TrafficLight' works too (once TrafficLight is defined)
--  Here's a new class YesNo that duplicates JavaScript strangeness of bool's
class YesNo a where
    yesno :: a -> Bool
instance YesNo Int where
    yesno 0 = False
    yesno _ = True
instance YesNo [a] where
    yesno [] = False
    yesno _  = True
instance YesNo Bool where
    yesno = id
    -- id just takes the parameter and returns the same thing
instance YesNo (Maybe a) where
    yesno (Just _) = True
    yesno Nothing  = False
instance YesNo (Tree a) where
    yesno EmptyTree = False
    yesno _         = True
instance YesNo TrafficLight where
    yesno Red   = False
    yesno _     = True
-- here's an if that works with YesNo values
yesnoIf :: (YesNo y) => y -> a -> a -> a
yesnoIf yesnoVal yesResult noResult = if yesno yesnoVal
                                      then yesResult
                                      else noResult
-- *Main> yesnoIf Red "Go!" "Stop"
-- "Stop"

-- Functor
-- The Functor typeclass represents things that can be mapped over.
-- Types that can act like a box can be functors.
-- Functor wants a type constructor instead of a concrete type in 'instance'
-- For Maybe:
-- instance Functor Maybe where
--      fmap f (Just x) = Just (f x)
--      fmap f Nothing  = Nothing
-- our binary tree is like a box
instance Functor Tree where
    fmap f EmptyTree = EmptyTree
    fmap f (Node x left right) = Node (f x) (fmap f left) (fmap f right)
-- now we can fmap (*2) ourTree to double all the values in the Tree!

-- Kinds and type-foo
-- Type constructors take types as parameters and produce concrete types
-- Functions take values as parameters and produce values
--
-- Values and Functions have Types that tell us what they are.
-- Types in turn has Kinds, which are somewhat like types of Types.
-- :k Int in GHCI reports Int :: *
-- '*' means that the type is a concrete type
-- :k Maybe in GHCI reports Maybe :: * -> *
-- '* -> *' means that it takes on concrete type and returns a concrete type
--      like taking Int and returning Maybe Int
-- :k Maybe Int in GHCI reports Maybe Int :: *
-- as expected, 'Maybe Int' is a concrete type
-- :k on a Type returns its kind, like :t on a Function returns it Type
-- :k Either in GHCI reports Either :: * -> * -> *
--
-- Now here's the type-foo
class Tofu t where
    tofu :: j a -> t a j
-- a must be concrete ('*'), so j is surely ('* -> *')
-- an example j would be 'Maybe Int'
-- therefore t would be ('* -> (* -> *) -> *')
-- let's make a type with kind of * -> (* -> *) -> *
data Frank a b = Frank {frankField :: b a} deriving (Show)
myFrank = Frank {frankField = Just "HAHA"}  -- type Frank [Char] Maybe
instance Tofu Frank where
    tofu x = Frank x
-- *Main> tofu (Just 'a') :: Frank Char Maybe
-- Frank {frankField = Just 'a'}
-- *Main> tofu ["HELLO"] :: Frank [Char] []
-- Frank {frankField = ["HELLO"]}

-- now Barry is type Barry :: (* -> *) -> * -> * -> *
data Barry t k p = Barry { yabba :: p, dabba :: t k} deriving (Show)
instance Functor (Barry a b) where
    fmap f (Barry {yabba = x, dabba = y}) = Barry {yabba = f x, dabba = y}
-- This maps f over the first field so we can do this:
-- *Main> Barry {yabba=1,dabba=(Just 3)}
-- Barry {yabba = 1, dabba = Just 3}
-- *Main> fmap (+10) Barry {yabba=1,dabba=(Just 3)}
-- Barry {yabba = 11, dabba = Just 3}
