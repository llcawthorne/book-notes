{-# LANGUAGE OverloadedStrings #-}

module Text.Fractions where

import Control.Applicative
import Data.Ratio ((%))
import Text.Trifecta

badFraction :: String
badFraction = "1/0"
alsoBad :: String
alsoBad = "10"
shouldWork :: String
shouldWork = "1/2"
shouldAlsoWork :: String
shouldAlsoWork = "2/1"

parseFraction :: Parser Rational
parseFraction = do
  numerator <- decimal
  _ <- char '/'
  denominator <- decimal
  case denominator of
    0 -> fail "Denominator cannot be zero"
    _ -> return (numerator % denominator)

-- `try` rewinds the input if the first parser fails so decimal can try from
-- the start of the input string.
parseFractionOrDecimal :: Parser (Either Rational Double)
parseFractionOrDecimal = (Left <$> try parseFraction) <|> (Right <$> double)

runPF :: IO ()
runPF = do
  let parseFraction' = parseString parseFraction mempty

  print $ parseFraction' shouldWork
  print $ parseFraction' shouldAlsoWork

  print $ parseFraction' alsoBad
  print $ parseFraction' badFraction

