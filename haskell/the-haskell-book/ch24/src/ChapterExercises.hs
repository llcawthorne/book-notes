{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE QuasiQuotes      #-}

module ChapterExercises where

import Control.Applicative
import Data.Char (digitToInt)
import Data.Word
import Text.RawString.QQ
import Text.Trifecta

-- SemVer Parser

-- Relevant to precedence/ordering, cannot sort numbers like strings.
data NumberOrString =
    NOSS String
  | NOSI Integer
    deriving (Eq, Ord, Show)

type Major = Integer
type Minor = Integer
type Patch = Integer
type Release = [NumberOrString]
type Metadata = [NumberOrString]

data SemVer =
  SemVer Major Minor Patch Release Metadata
    deriving (Eq, Show)

instance Ord SemVer where
  compare (SemVer major  minor  patch  release  metadata)
          (SemVer major' minor' patch' release' metadata') =
          compare major major' <> compare minor minor' <> compare patch patch'
      <>  compareRel release release'
            where compareRel [] [] = EQ
                  compareRel [] _  = GT
                  compareRel _  [] = LT
                  compareRel r  r' = compare r r'

parseNoS :: Parser NumberOrString
parseNoS = try (NOSI <$> integer <* notFollowedBy alphaNum) 
           <|> (NOSS <$> some alphaNum)

parseSemVer :: Parser SemVer
parseSemVer = do
  major <- integer
  _     <- char '.'
  minor <- integer
  _     <- char '.'
  patch <- integer
  rel   <- try (char '-' >> parseNoS `sepBy1` char '.') <|> pure []
  meta  <- try (char '+' >> parseNoS `sepBy1` char '.') <|> pure []
  return $ SemVer major minor patch rel meta

parseDigit :: Parser Char
parseDigit = oneOf "0123456789"

unsignedInt :: Parser Integer
unsignedInt = foldl (\acc d -> acc * 10 + toInteger (digitToInt d)) 0 
          <$> some parseDigit

base10Integer :: Parser Integer
base10Integer = unsignedInt

base10Integer' :: Parser Integer
base10Integer' = do
  sign <- char '-' <|> pure '+'
  n    <- unsignedInt
  return $ if sign == '-' then negate n else n

type AreaCode = Int
type Exchange = Int
type LineNumber = Int

data PhoneNumber = PhoneNumber AreaCode Exchange LineNumber
  deriving (Eq, Show)

digitVal :: Parser Int
digitVal = digitToInt <$> digit

threeDigits :: Parser Int
threeDigits = (\a b c -> a * 100 + b * 10 + c)
          <$> digitVal <*> digitVal <*> digitVal

fourDigits :: Parser Int
fourDigits = (\a b c d -> a * 1000 + b * 100 + c * 10 + d) 
         <$> digitVal <*> digitVal <*> digitVal <*> digitVal

parsePhone :: Parser PhoneNumber
parsePhone = do
  _      <- optional (try (char '1' >> char '-'))
  _      <- optional (char '(')
  areaC  <- threeDigits
  _      <- optional (char ')')
  _      <- optional (char '-' <|> char ' ')
  exch   <- threeDigits
  _      <- optional (char '-' <|> char ' ')
  lineN  <- fourDigits
  return $ PhoneNumber areaC exch lineN

data IPAddress = IPAddress Word32
  deriving (Eq, Ord, Show)

parseIPv4 :: Parser IPAddress
parseIPv4 = do
  w1 <- decimal
  _  <- char '.'
  w2 <- decimal
  _  <- char '.'
  w3 <- decimal
  _  <- char '.'
  w4 <- decimal
  return $ IPAddress (fromIntegral (w1 * 256^3 + w2 * 256^2 + w3 * 256 + w4))

-- IPv6 - in progress
data IPAddress6 = IPAddress6 Word64 Word64
  deriving (Eq, Ord, Show)

hexVal :: Parser Int
hexVal = digitToInt <$> hexDigit

fourHex :: Parser Int
fourHex = (\a b c d -> a * 16^3 + b * 16^2 + c * 16^1 + d) 
       <$> hexVal <*> hexVal <*> hexVal <*> hexVal

parseIPv6 :: Parser IPAddress6
parseIPv6 = do
  w1 <- fourHex
  _  <- char ':'
  w2 <- fourHex
  _  <- char ':'
  w3 <- fourHex
  _  <- char ':'
  w4 <- fourHex
  _  <- char ':'
  w5 <- fourHex
  _  <- char ':'
  w6 <- fourHex
  _  <- char ':'
  w7 <- fourHex
  _  <- char ':'
  w8 <- fourHex
  return $ IPAddress6
             (fromIntegral (w1 * 65536^3 + w2 * 65536^2 + w3 * 65536 + w4))
             (fromIntegral (w5 * 65536^3 + w6 * 65536^2 + w7 * 65536 + w8))
