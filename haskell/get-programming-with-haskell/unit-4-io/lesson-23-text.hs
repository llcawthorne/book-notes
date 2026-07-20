{-# LANGUAGE OverloadedStrings #-}
import qualified Data.Text as T
import qualified Data.Text.IO as TIO
import qualified Data.Text.Lazy as LT
import qualified Data.Text.Lazy.IO as LTIO
import Data.Semigroup

firstWord :: String
firstWord = "pessimism"

secondWord :: T.Text
secondWord = T.pack firstWord

thirdWord :: String
thirdWord = T.unpack secondWord

-- QC 23.1
fourthWord :: T.Text
fourthWord = T.pack thirdWord

aWord :: T.Text
aWord = "Cheese"

-- QC 23.3
-- {-# LANGUAGE TemplateHaskell #-}

sampleInput :: T.Text
sampleInput = "this\nis\nSparta"

sampleLines :: [T.Text]
sampleLines = T.lines sampleInput

breakText :: T.Text
breakText = "simple"

exampleText :: T.Text
exampleText = "This is simple to do"

brokenText :: [T.Text]
brokenText = T.splitOn breakText exampleText

-- There's Text versions of lines, words, splitOn, unlines, unwords
-- and intercalate.  The Monoid operators also work.
-- ++ is only for lists though.  You can import semigroup and use <> though

combinedTextMonoid :: T.Text
combinedTextMonoid = mconcat ["some"," ","text"]

combinedTextSemigroup :: T.Text
combinedTextSemigroup = "some" <> " " <> "text"

-- next example in lesson-23-bg_highlight.hs
-- QC 23.3
myLines :: T.Text -> [T.Text]
myLines text = T.splitOn "\n" text

myUnlines :: [T.Text] -> T.Text
myUnlines textLines = T.intercalate "\n" textLines

-- Q23.1
helloPerson :: T.Text -> T.Text
helloPerson name = "Hello" <> " " <> name <> "!"

helloMain :: IO ()
helloMain = do
  TIO.putStrLn "Hello! What's your name?"
  name <- TIO.getLine
  let statement = helloPerson name
  TIO.putStrLn statement

-- Q23.2
toInts :: LT.Text -> [Int]
toInts = map (read . LT.unpack) . LT.lines

textMain :: IO ()
textMain = do
  userInput <- LTIO.getContents
  let numbers = toInts userInput
  TIO.putStrLn ((T.pack . show . sum) numbers)
