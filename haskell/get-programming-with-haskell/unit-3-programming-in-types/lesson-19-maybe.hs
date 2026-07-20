import qualified Data.Map as Map
import Data.List

data Organ = Heart | Brain | Kidney | Spleen deriving (Show,Eq)

organs :: [Organ]
organs = [Heart,Heart,Brain,Spleen,Spleen,Kidney]

ids :: [Int]
ids = [2,7,13,14,21,24]

organPairs :: [(Int,Organ)]
organPairs = zip ids organs

organCatalog :: Map.Map Int Organ
organCatalog = Map.fromList organPairs

-- QC 19.1
-- Nothing has type Maybe Organ in the example

possibleDrawers :: [Int]
possibleDrawers = [1..50]

getDrawerContents :: [Int] -> Map.Map Int Organ -> [Maybe Organ]
getDrawerContents ids catalog = map getContents ids
  where getContents = \id -> Map.lookup id catalog

availableOrgans :: [Maybe Organ]
availableOrgans = getDrawerContents possibleDrawers organCatalog

countOrgan :: Organ -> [Maybe Organ] -> Int
countOrgan organ available = length (filter
                                      (\x -> x == Just organ)
                                      available)

isSomething :: Maybe Organ -> Bool
isSomething Nothing = False
isSomething (Just _) = True

justTheOrgans :: [Maybe Organ]
justTheOrgans = filter isSomething availableOrgans

showOrgan :: Maybe Organ -> String
showOrgan (Just organ) = show organ
showOrgan Nothing = ""

organList :: [String]
organList = map showOrgan justTheOrgans

cleanList :: String
cleanList = intercalate ", " organList

-- QC 19.2
numOrZero :: Maybe Int -> Int
numOrZero Nothing = 0
numOrZero (Just n) = n

data Container = Vat Organ | Cooler Organ | Bag Organ

instance Show Container where
  show (Vat organ) = show organ ++ " in a vat"
  show (Cooler organ) = show organ ++ " in a cooler"
  show (Bag organ) = show organ ++ " in a bag"

data Location = Lab | Kitchen | Bathroom deriving Show

organToContainer :: Organ -> Container
organToContainer Brain = Vat Brain
organToContainer Heart = Cooler Heart
organToContainer organ = Bag organ

placeInLocation :: Container -> (Location,Container)
placeInLocation (Vat a) = (Lab, Vat a)
placeInLocation (Cooler a) = (Lab, Cooler a)
placeInLocation (Bag a) = (Kitchen, Bag a)

process :: Organ -> (Location, Container)
process organ = placeInLocation . organToContainer $ organ

report :: (Location,Container) -> String
report (location,container) = show container ++ " in the " ++ show location

processRequest :: Int -> Map.Map Int Organ -> String
processRequest id catalog = processAndReport organ
  where organ = Map.lookup id catalog

processAndReport :: (Maybe Organ) -> String
processAndReport (Just organ) = report (process organ)
processAndReport Nothing = "error, id not found"

-- QC 19.3
-- pattern matching
-- report :: Maybe (Location,Container) -> String
-- report Nothing = "container not found"
-- report (Just (location,container)) = show container ++ " in the "
--                                    ++ show location

-- Q19.1
-- Recall:
-- *Main> getDrawerContents possibleDrawers organCatalog
-- [Nothing,Just Heart,Nothing,Nothing,Nothing,Nothing,Just Heart,Nothing,Nothing,Nothing,Nothing,Nothing,Just Brain,Just Spleen,Nothing,Nothing,Nothing,Nothing,Nothing,Nothing,Just Spleen,Nothing,Nothing,Just Kidney,Nothing,Nothing,Nothing,Nothing,Nothing,Nothing,Nothing,Nothing,Nothing,Nothing,Nothing,Nothing,Nothing,Nothing,Nothing,Nothing,Nothing,Nothing,Nothing,Nothing,Nothing,Nothing,Nothing,Nothing,Nothing,Nothing]
emptyDrawers :: [Maybe Organ] -> Int
emptyDrawers drawerContents = length (filter (== Nothing) drawerContents)
-- *Main> emptyDrawers (getDrawerContents possibleDrawers organCatalog)
-- 44

-- Q19.2
maybeMap :: (a -> b) -> Maybe a -> Maybe b
maybeMap _ Nothing = Nothing
maybeMap f (Just a) = Just (f a)
