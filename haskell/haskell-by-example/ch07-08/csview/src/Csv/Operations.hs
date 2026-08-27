module Csv.Operations
  ( foldCsv
  , filterCsv
  , countNonEmpty
  , countOccurences
  , searchText
  )
where

import qualified Data.List as L
import qualified Data.Text as T

import Csv.Types

foldCsv :: (DataField -> b -> b) -> b -> Csv -> [b]
foldCsv f z (Csv {csvColumns}) = map (foldr f z) csvColumns

filterCsv :: (DataField -> Bool) -> Csv -> Csv
filterCsv p csv@(Csv {csvColumns}) =
  let rows = L.transpose csvColumns
      -- we accept any row where the predicate holds for at least one field
      filtered = L.filter (any p) rows
   in csv {csvColumns = L.transpose filtered}

countNonEmpty :: Csv -> [Int]
countNonEmpty = foldCsv f 0
  where
    f NullValue acc = acc
    f _ acc = acc +1

countOccurences :: DataField -> Csv -> [Int]
countOccurences df =
  foldCsv (\x acc -> if x == df then acc + 1 else acc) 0

searchText :: T.Text -> Csv -> Csv
searchText t = filterCsv (\f -> dataFieldToText f `contains` t)
  where
    contains = flip T.isInfixOf
