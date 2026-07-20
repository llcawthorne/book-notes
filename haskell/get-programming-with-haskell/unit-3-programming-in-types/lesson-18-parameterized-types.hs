import qualified Data.Map as Map

-- We can put any type in this box.  a is a parameterized type
data Box a = Box a deriving Show

wrap :: a -> Box a
wrap x = Box x

unwrap :: Box a -> a
unwrap (Box x) = x

-- QC 18.1
-- It's a Box of a Box of Char: Box (Box Char)

-- For a Triple, we're making all three values share the same type
data Triple a = Triple a a a deriving Show

type Point3D = Triple Double

aPoint :: Point3D
aPoint = Triple 0.1 53.2 12.3

type FullName = Triple String

aPerson :: FullName
aPerson = Triple "Howard" "Phillips" "Lovecraft"

type Initials = Triple Char

initials :: Initials
initials = Triple 'H' 'P' 'L'

-- Now some functions that work with all the above triples
first :: Triple a -> a
first (Triple x _ _) = x

second :: Triple a -> a
second (Triple _ x _) = x

third :: Triple a -> a
third (Triple _ _ x) = x

toList :: Triple a -> [a]
toList (Triple x y z) = [x,y,z]

transform :: (a -> a) -> Triple a -> Triple a
transform f (Triple x y z) = Triple (f x) (f y) (f z)

-- QC 18.2
-- Unlike map, transform only takes a function from a->a, so it can't
-- change the type of it's arguments

-- List is a parameterized data type.  We'll make our own version.
data List a = Empty | Cons a (List a) deriving Show

ourListCat :: List Char
ourListCat = Cons 'c' (Cons 'a' (Cons 't' Empty))

ourMap :: (a -> b) -> List a -> List b
ourMap _ Empty = Empty
ourMap f (Cons a rest) = Cons (f a) (ourMap f rest)

-- QC 18.3
-- Type error
-- QC 18.4
-- * -> * -> * -> *

data Organ = Heart | Brain | Kidney | Spleen deriving (Eq,Ord,Enum,Show)

organs :: [Organ]
organs = [Heart,Heart,Brain,Spleen,Spleen,Kidney]

ids :: [Int]
ids = [2,7,13,14,21,24]

organPairs :: [(Int,Organ)]
organPairs = zip ids organs

organCatalog :: Map.Map Int Organ
organCatalog = Map.fromList organPairs

-- Q18.1
tripleMap :: (a -> b) -> Triple a -> Triple b
tripleMap f (Triple a b c) = Triple (f a) (f b) (f c)

boxMap :: (a -> b) -> Box a -> Box b
boxMap f (Box a) = Box (f a)

-- Q18.2
-- I had this with hardcoded counts for the organs, and didn't have 
-- the 0 represented.  Changed it to solution from book
-- It turned out nothing had 0 anyway, but I should've coded something to
-- count how many organs I have.
organValues :: [Organ]
organValues = map snd (Map.toList organCatalog)

allOrgans :: [Organ]
allOrgans = [Heart .. Spleen]

organCounts :: [Int]
organCounts = map countOrgan allOrgans
  where countOrgan = (\organ ->
                       (length . filter (== organ)) organValues)

organInventory :: Map.Map Organ Int
organInventory = Map.fromList (zip allOrgans organCounts)
