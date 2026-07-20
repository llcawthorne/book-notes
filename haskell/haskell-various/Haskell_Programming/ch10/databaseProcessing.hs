-- databaseProcessing.hs
module DatabaseProcessing where

import Data.Time

data DatabaseItem = DbString String
                  | DbNumber Integer
                  | DbDate   UTCTime
                  deriving (Eq, Ord, Show)

theDatabase :: [DatabaseItem]
theDatabase = 
  [ DbDate (UTCTime
            (fromGregorian 1911 5 1)
            (secondsToDiffTime 34123))
  , DbNumber 9001
  , DbString "Hello, world!"
  , DbDate (UTCTime
            (fromGregorian 1921 5 1)
            (secondsToDiffTime 34123))
  ]

-- 1) filter DbDate
filterDbDate :: [DatabaseItem] -> [UTCTime]
filterDbDate db = foldr f [] db
  where f (DbDate dt) acc = dt : acc
        f _           acc = acc

-- 2) filter DbNumber
filterDbNumber :: [DatabaseItem] -> [Integer]
filterDbNumber db = foldr f [] db
  where f (DbNumber n) acc = n : acc
        f _            acc = acc

-- 3) mostRecent DbDate
mostRecent :: [DatabaseItem] -> UTCTime
mostRecent db = foldr max 
  (UTCTime (fromGregorian 1900 1 1) (secondsToDiffTime 34123)) 
  (filterDbDate db)

-- 4) sum all of the DbNumber values
sumDb :: [DatabaseItem] -> Integer
sumDb db = foldr (+) 0 (filterDbNumber db)

-- 5) average the DbNumber values
avgDb :: [DatabaseItem] -> Double
avgDb db = fromIntegral (sumDb db) / (fromIntegral (length (filterDbNumber db)))
