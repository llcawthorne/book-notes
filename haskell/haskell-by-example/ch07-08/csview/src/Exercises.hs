module Exercises where

import qualified Data.Either as E
import qualified Data.List as L
import qualified Data.Maybe as M
--import Data.Sliceable
import qualified Data.Text as T
import Text.Read (readMaybe)

import Csv.Types

appendCsv' :: Csv -> Csv -> Csv
appendCsv' a b =
  Csv
    { csvHeader =
        if M.isNothing (csvHeader a) && M.isNothing (csvHeader b)
          then Nothing
          else Just $ header' a ++ header' b,
      csvColumns = appendColumns a b
    }
  where
    header' csv =
      M.fromMaybe
        (L.replicate (numberOfColumns csv) "")
        (csvHeader csv)

    appendColumns a' b' =
      take (minCols) (csvColumns a')
        ++ take (minCols) (csvColumns b')
      where
        minCols = min (numberOfColumns a') (numberOfColumns b')

foldRight :: (a -> b -> b) -> b -> [a] -> b
foldRight _ z [] = z
foldRight f z (x : xs) = f x $ foldRight f z xs

myNull :: Foldable t => t a -> Bool
myNull = foldr (\_ _ -> False) True

myLength :: Foldable t => t a -> Int
myLength = foldr (\_ acc -> 1 + acc) 0

myElem :: (Foldable t, Eq a) => a -> t a -> Bool
myElem a = foldr (\x acc -> if x == a then True else acc) False

mySum :: (Foldable t, Num a) => t a -> a
mySum = foldr (+) 0

myMaximum :: (Foldable t, Ord a, Bounded a) => t a -> a
myMaximum = foldr (\x acc -> if x > acc then x else acc) minBound

myMinimum :: (Foldable t, Ord a, Bounded a) => t a -> a
myMinimum = foldr (\x acc -> if x < acc then x else acc) maxBound

