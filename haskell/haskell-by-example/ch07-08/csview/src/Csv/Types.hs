{-# LANGUAGE NamedFieldPuns #-}
{-# LANGUAGE RecordWildCards #-}
{-# LANGUAGE OverloadedStrings #-}

module Csv.Types (
    DataField(..),
    Column,
    Csv (..),
    mkCsv,
    unsafeMkCsv,
    numberOfRows,
    numberOfColumns,
    appendCsv,
    textToDataField,
    dataFieldToText
  )
where

import qualified Data.Either as E
import qualified Data.List as L
import qualified Data.Maybe as M
import Data.Sliceable
import qualified Data.Text as T
import Text.Read (readMaybe)

type Column = [DataField]

data Csv = Csv
  { csvHeader :: Maybe [T.Text]
  , csvColumns :: [Column]
  }
  deriving Show

data DataField
  = IntValue Int
  | TextValue T.Text
  | NullValue
  deriving (Eq, Show)

mkCsv :: Maybe [T.Text] -> [Column] -> Either String Csv
mkCsv mHeader columns
  | not headerSizeCorrect =
      Left "Size of header row does not fit number of columns"
  | not columnSizesCorrect =
      Left "The columns do not have equal sizes"
  | otherwise = Right Csv {csvHeader=mHeader, csvColumns=columns}
  where
    headerSizeCorrect =
      M.maybe True (\h -> L.length h == L.length columns) mHeader
    columnSizesCorrect =
      L.length (L.nubBy (\x y -> length x == length y) columns) <= 1

unsafeMkCsv :: Maybe [T.Text] -> [Column] -> Csv
unsafeMkCsv header columns =
  E.either error id $ mkCsv header columns

-- because of RecordWildCards, `Csv {..}` creates `csvColumns`
-- otherwise we would have needed `Csv { csvColumns = c }` and use `c`
-- or simply `Csv { csvColumns }` thanks to `NamedFieldPuns`
numberOfRows :: Csv -> Int
numberOfRows Csv {..} =
  case csvColumns of
    [] -> 0
    (x : _) -> length x

numberOfColumns :: Csv -> Int
numberOfColumns Csv {..} = length csvColumns

appendCsv :: Csv -> Csv -> Csv
appendCsv a b =
  Csv
    { csvHeader =
        if M.isNothing (csvHeader a) && M.isNothing (csvHeader b)
          then Nothing
          else Just $ header' a ++ header' b,
      csvColumns = appendColumns (csvColumns a) (csvColumns b)
    }
  where
    header' csv =
      M.fromMaybe
        (L.replicate (numberOfColumns csv) "")
        (csvHeader csv)

    appendColumns colsA colsB =
      map (\cols -> cols ++ fillA) colsA
        ++ map (\cols -> cols ++ fillB) colsB
      where
        fillA = replicate (numberOfRows b - numberOfRows a) NullValue
        fillB = replicate (numberOfRows a - numberOfRows b) NullValue

instance Semigroup Csv where
  (<>) = appendCsv

instance Monoid Csv where
  mempty = Csv {csvHeader = Nothing, csvColumns = []}

instance Sliceable Csv where
  slicePartition idx1 idx2 Csv {..} =
    let (headerHd, headerSpl, headerTl) =
          slicePartition idx1 idx2 csvHeader
        (columnHd, columnSpl, columnTl) =
          slicePartition idx1 idx2 csvColumns
     in ( Csv {csvHeader = headerHd, csvColumns = columnHd},
          Csv {csvHeader = headerSpl, csvColumns = columnSpl},
          Csv {csvHeader = headerTl, csvColumns = columnTl}
        )

textToDataField :: T.Text -> DataField
textToDataField "" = NullValue
textToDataField raw =
  let mIntVal = readMaybe (T.unpack raw)
   in maybe (TextValue raw) IntValue mIntVal

dataFieldToText :: DataField -> T.Text
dataFieldToText (IntValue i) = T.pack $ show i
dataFieldToText (TextValue t) = t
dataFieldToText NullValue = ""
