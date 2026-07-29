import Data.List
import qualified Data.Map as Map
import Data.Semigroup
import Data.Maybe

file1 :: [(Int,Double)]
file1 = [ (1, 200.1), (2,  199.5), (3, 199.4)
        , (4, 198.9), (5,  199.0), (6, 200.2)
        , (9, 200.3), (10, 201.2), (12, 202.9)]

file2 :: [(Int,Double)]
file2 = [(11, 201.6), (12, 201.5), (13, 201.5)
        ,(14, 203.5), (15, 204.9), (16, 207.1)
        ,(18, 210.5), (20, 208.8)]

file3 :: [(Int,Double)]
file3 = [(10, 201.2), (11, 201.6), (12, 201.5)
        ,(13, 201.5), (14, 203.5), (17, 210.5)
        ,(24, 215.1), (25, 218.7)]

file4 :: [(Int,Double)]
file4 = [(26, 219.8), (27, 220.5), (28, 223.8)
        ,(29, 222.8), (30, 223.8), (31, 221.7)
        ,(32, 222.3), (33, 220.8), (34, 219.4)
        ,(35, 220.1), (36, 220.6)]

-- the first value in our time series is an Int to represent the order of 
-- the piece of data.  1 is the first month.
-- The piece of data is Double for now, but we'll allow it to vary in case
-- we want to analyze a time series of Bools ("Did we meet the sales goal?")
-- or String ("Who was the lead sales person?")
data TS a = TS [Int] [Maybe a]

createTS :: [Int] -> [a] -> TS a
createTS times values = TS completeTimes extendedValues
  where completeTimes = [minimum times .. maximum times]
        timeValueMap = Map.fromList (zip times values)
        extendedValues = map (\v -> Map.lookup v timeValueMap) completeTimes

fileToTS :: [(Int,a)] -> TS a
fileToTS tvPairs = createTS times values
  where (times, values) = unzip tvPairs

showTVPair :: Show a => Int -> (Maybe a) -> String
showTVPair time (Just value) = mconcat [show time, "|", show value, "\n"]
showTVPair time Nothing = mconcat [show time, "|NA\n"]

instance Show a => Show (TS a) where
  show (TS times values) = mconcat rows
    where rows = zipWith showTVPair times values

-- now that we can create and view time series, let's make a few from files
ts1 :: TS Double
ts1 = fileToTS file1

ts2 :: TS Double
ts2 = fileToTS file2

ts3 :: TS Double
ts3 = fileToTS file3

ts4 :: TS Double
ts4 = fileToTS file4

-- next we want to look to Semigroup and Monoid to simplify combining files
-- we're going to solve disagreements (where the same data is in two files)
-- by saying that the second file takes priority, since it is assumed to
-- be more up-to-date.  We'll basically handle this by just inserting the
-- first TS into a Map, then inserting the second TS into the Map.  The
-- last update will be the one to stick around
insertMaybePair :: Ord k => Map.Map k v -> (k, Maybe v) -> Map.Map k v
insertMaybePair myMap (_,Nothing) = myMap
insertMaybePair myMap (key, (Just value)) = Map.insert key value myMap

combineTS :: TS a -> TS a -> TS a
combineTS (TS [] []) ts2 = ts2
combineTS ts1 (TS [] []) = ts1
combineTS (TS t1 v1) (TS t2 v2) = TS completeTimes combinedValues
  where bothTimes = mconcat [t1,t2]
        completeTimes = [minimum bothTimes .. maximum bothTimes]
        tvMap = foldl insertMaybePair Map.empty (zip t1 v1)
        updatedMap = foldl insertMaybePair tvMap (zip t2 v2)
        combinedValues = map (\v -> Map.lookup v updatedMap) completeTimes

-- we could've just pasted the logic above to this function and saved 
-- ourselves naming combineTS, but we'll just assign it to <>
instance Semigroup (TS a) where
  (<>) = combineTS

-- now we want Monoid so we can mconcat a list of TS's
instance Monoid (TS a) where
  mempty = TS [] []
  mappend = (<>)

tsAll :: TS Double
tsAll = mconcat [ts1,ts2,ts3,ts4]

-- now to find the mean of our time series
mean :: (Real a) => [a] -> Double
mean xs = total/count
  where total = realToFrac . sum $ xs
        count = realToFrac . length $ xs

meanTS :: (Real a) => TS a -> Maybe Double
meanTS (TS _ []) = Nothing
meanTS (TS times values) = if all (== Nothing) values
                           then Nothing
                           else Just avg
  where justVals = filter isJust values
        cleanVals = map fromJust justVals
        avg = mean cleanVals

-- we would also like to find the min and max of a time series, along
-- with when it happened
type CompareFunc a = a -> a -> a
type TSCompareFunc a = (Int, Maybe a) -> (Int, Maybe a) -> (Int, Maybe a)

makeTSCompare :: Eq a => CompareFunc a -> TSCompareFunc a
makeTSCompare func = newFunc
  where newFunc (i1, Nothing) (i2, Nothing) = (i1, Nothing)
        newFunc (_, Nothing) (i, val) = (i, val)
        newFunc (i, val) (_, Nothing) = (i, val)
        newFunc (i1, Just val1) (i2, Just val2) =
                if func val1 val2 == val1
                then (i1, Just val1)
                else (i2, Just val2)

compareTS :: Eq a => (a -> a -> a) -> TS a -> Maybe (Int, Maybe a)
compareTS func (TS [] []) = Nothing
compareTS func (TS times values) = if all (== Nothing) values
                                   then Nothing
                                   else Just best
  where pairs = zip times values
        best = foldl (makeTSCompare func) (0, Nothing) pairs

minTS :: Ord a => TS a -> Maybe (Int, Maybe a)
minTS = compareTS min

maxTS :: Ord a => TS a -> Maybe (Int, Maybe a)
maxTS = compareTS max

-- now we have mean, max, and min for summary statistics
-- next we are going to add the `diff` of a TS
-- the `diff` indicates the change each day
-- we can only subtract values from each other if they are Num's,
-- so `diff` will only work on Num a => TS a
diffPair :: Num a => Maybe a -> Maybe a -> Maybe a
diffPair Nothing _ = Nothing
diffPair _ Nothing = Nothing
diffPair (Just x) (Just y) = Just (x - y)

diffTS :: Num a => TS a -> TS a
diffTS (TS [] []) = TS [] []
diffTS (TS times values) = TS times (Nothing:diffValues)
  where shiftValues = tail values
        diffValues = zipWith diffPair shiftValues values

-- the best way to smooth data is to take a moving average
-- it's similar to the diff, but involves taking the average over a window
-- the moving average takes a parameter n to set the window size
meanMaybe :: (Real a) => [Maybe a] -> Maybe Double
meanMaybe vals = if any (== Nothing) vals
                 then Nothing
                 else (Just avg)
  where avg = mean (map fromJust vals)

movingAvg :: (Real a) => [Maybe a] -> Int -> [Maybe Double]
movingAvg [] n = []
movingAvg vals n = if length nextVals == n
                   then meanMaybe nextVals:movingAvg restVals n
                   else []
  where nextVals = take n vals
        restVals = tail vals

-- we finally need to make sure our moving average is centered
-- we'll put (n `div` 2) Nothing's at the front and back
movingAverageTS :: (Real a) => TS a -> Int -> TS Double
movingAverageTS (TS [] []) n = TS [] []
movingAverageTS (TS times values) n = TS times smoothedValues
  where ma = movingAvg values n
        nothings = replicate (n `div` 2) Nothing
        smoothedValues = mconcat [nothings,ma,nothings]
