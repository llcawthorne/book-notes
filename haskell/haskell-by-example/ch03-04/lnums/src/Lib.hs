module Lib (
  someFunc,
  numberAllLinesOrig,
  numberAllLines,
  numberLines,
  numberNonEmptyLines,
  numberAndIncrementNonEmptyLines,
  PadMode (..),
  pad,
) where

import Data.Char (isPrint, isSeparator)

someFunc :: IO ()
someFunc = putStrLn "someFunc"

type NumberedLines = [(Maybe Int, String)]

numberAllLinesOrig :: [String] -> NumberedLines
numberAllLinesOrig lines =
  let go :: Int -> [String] -> NumberedLines
      go _ [] = []
      go counter (x : xs) = (Just counter, x) : go (counter + 1) xs
   in go 1 lines

isEmpty :: String -> Bool
isEmpty str =
  null str
    || all (\s -> not (isPrint s) || isSeparator s) str

isNotEmpty :: String -> Bool
isNotEmpty str = not (isEmpty str)

numberLines :: (String -> Bool) -> (String -> Bool) -> [String] -> NumberedLines
numberLines shouldIncr shouldNumber ls =
  let go :: Int -> [String] -> NumberedLines
      go _ [] = []
      go counter (x : xs) =
        let mNumbering = if shouldNumber x then Just counter else Nothing
            newCounter = if shouldIncr x then counter + 1 else counter
         in (mNumbering, x) : go newCounter xs
   in go 1 ls

-- const is already provided
const' :: a -> b -> a
const' x = (\_ -> x)

-- This is equivalent to const``
const'' :: a -> b -> a
const'' x _ = x

numberAllLines :: [String] -> NumberedLines
numberAllLines text = numberLines (const True) (const True) text

numberNonEmptyLines :: [String] -> NumberedLines
numberNonEmptyLines = numberLines (const True) isNotEmpty

numberAndIncrementNonEmptyLines :: [String] -> NumberedLines
numberAndIncrementNonEmptyLines = numberLines isNotEmpty isNotEmpty

data PadMode = PadLeft | PadRight

pad :: PadMode -> Int -> String -> String
pad mode n str =
  let diff = n - length str
      padding = replicate diff ' '
   in case mode of
        PadLeft -> padding ++ str
        PadRight -> str ++ padding

padLeft :: Int -> String -> String
padLeft = pad PadLeft

padRight :: Int -> String -> String
padRight = pad PadRight
