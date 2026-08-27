-- Csv/Print.hs
module Csv.Print
  ( writeCsv
  , printCsv
  , fromCsv
  , withSummaries
  , unsafeWithSummaries
  , pretty
  , prettyText
  )
where

import qualified Data.List as L
import qualified Data.Maybe as M
import qualified Data.Text as T
import qualified Data.Text.IO as TIO
import qualified Data.Either as E

import Csv.Types

toFileContent :: Csv -> [T.Text]
toFileContent Csv {..} =
  let rows = L.map (L.map dataFieldToText) $ L.transpose csvColumns
   in L.map (T.intercalate ",") $ M.maybe rows (: rows) csvHeader

writeCsv :: FilePath -> Csv -> IO ()
writeCsv path = TIO.writeFile path . T.intercalate "\n" . toFileContent

printCsv :: Csv -> IO ()
printCsv = mapM_ TIO.putStrLn . toFileContent

data PrettyCsv = PrettyCsv
  { pcHeader :: Maybe [T.Text]
  , pcColumns :: [[T.Text]]
  , pcSummaries :: Maybe [T.Text]
  }
  deriving (Eq, Show)

fromCsv :: Csv -> PrettyCsv
fromCsv Csv {..} =
  PrettyCsv
    { pcHeader = csvHeader,
      pcColumns =
        L.map (L.map dataFieldToText) csvColumns,
      pcSummaries = Nothing
    }

unsafeWithSummaries :: PrettyCsv -> [T.Text] -> PrettyCsv
unsafeWithSummaries pcsv summaries =
  E.either error id $ withSummaries pcsv summaries

withSummaries ::
  PrettyCsv ->
  [T.Text] ->
  Either String PrettyCsv
withSummaries pcsv@(PrettyCsv {..}) summaries
  | L.length summaries /= L.length pcColumns =
      Left "The number of summaries does not match the number of columns"
  | otherwise = Right $ pcsv {pcSummaries = Just $ summaries}

pretty :: PrettyCsv -> String
pretty = T.unpack . prettyText

prettyText :: PrettyCsv -> T.Text
prettyText PrettyCsv {..} =
  let paddings = L.map fieldPaddings allColumns
      columns = L.zipWith L.zip paddings allColumns
      padded = L.map (L.map $ uncurry padField) columns
      rows = L.transpose padded
      columnSizes = L.map (L.maximum . L.map T.length) padded
      prettyRows = L.map (prettyRow "|") rows
      outerBorder =
        flip T.replicate "-" $
          M.maybe 0 T.length (M.listToMaybe prettyRows)
      innerBorder = prettyRow "+" $ L.map (`T.replicate` "-") columnSizes
   in printRows (outerBorder, innerBorder) prettyRows
  where
    printRows :: (T.Text, T.Text) -> [T.Text] -> T.Text
    printRows (outer, inner) [] = ""
    printRows (outer, inner) allRows@(header : rows) =
      T.intercalate "\n" $
        if M.isJust pcHeader
          then [outer, header, inner, addSummary rows, outer]
          else [outer, addSummary allRows, outer]
      where
        addSummary [] = ""
        addSummary rows =
          T.intercalate "\n" $
            if M.isJust pcSummaries
              then (L.init rows) ++ [inner, L.last rows]
              else rows

    allColumns :: [[T.Text]]
    allColumns = case (pcHeader, pcSummaries) of
      (Nothing, Nothing) ->
        pcColumns
      (Just header, Nothing) ->
        L.zipWith (:) header pcColumns
      (Nothing, Just summaries) ->
        L.zipWith (\c s -> c ++ [s]) pcColumns summaries
      (Just header, Just summaries) ->
        L.zipWith3 (\h c s -> h : c ++ [s]) header pcColumns summaries

    prettyRow :: T.Text -> [T.Text] -> T.Text
    prettyRow delimiter =
      L.foldl' (\acc x -> T.concat [acc, x, delimiter]) delimiter

    padField :: Int -> T.Text -> T.Text
    padField n field = T.concat [" ", field, T.replicate n " ", " "]

    fieldPaddings :: [T.Text] -> [Int]
    fieldPaddings col =
      L.map (\x -> L.maximum (L.map T.length col) - T.length x) col
