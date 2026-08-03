module Lib (
  caesar,
  rot13,
  rot135,
  frequencyStats,
  tryToDecrypt,
)
where

import Data.Char (toLower)
import Data.List (sortBy)

type Alphabet = [Char]

lowerAlphabet :: Alphabet
lowerAlphabet = ['a' .. 'z']

upperAlphabet :: Alphabet
upperAlphabet = ['A' .. 'Z']

digits :: Alphabet
digits = ['0' .. '9']

isLower :: Char -> Bool
isLower char = char `elem` lowerAlphabet

isUpper :: Char -> Bool
isUpper char = char `elem` upperAlphabet

isDigit :: Char -> Bool
isDigit char = char `elem` digits

isMisc :: Char -> Bool
isMisc char = char `notElem` lowerAlphabet ++ upperAlphabet ++ digits

indexOf :: Char -> Alphabet -> Int
indexOf _ch [] = undefined
indexOf ch (x : xs) = if x == ch then 0 else 1 + indexOf ch xs

alphabetRot :: Alphabet -> Int -> Char -> Char
alphabetRot alphabet n ch =
  alphabet !! ((indexOf ch alphabet + n) `mod` length alphabet)

upperRot :: Int -> Char -> Char
upperRot = alphabetRot upperAlphabet

lowerRot :: Int -> Char -> Char
lowerRot = alphabetRot lowerAlphabet

rotChar :: Int -> Char -> Char
rotChar n ch
  | isLower ch = lowerRot n ch
  | isUpper ch = upperRot n ch
  | otherwise = ch

caesar :: Int -> String -> String
caesar n = map (\ch -> rotChar n ch)

rot13 :: String -> String
rot13 = caesar 13

rot135 :: String -> String
rot135 [] = []
rot135 (ch : xs)
  | isLower ch = lowerRot 13 ch : rot135 xs
  | isUpper ch = upperRot 13 ch : rot135 xs
  | isDigit ch = alphabetRot digits 5 ch : rot135 xs
  | otherwise = ch : rot135 xs

count :: Char -> String -> Int
count _e [] = 0
count e (x : xs)
  | x == e = 1 + count e xs
  | otherwise = count e xs

-- frequencyStats is useful for attacking many ciphers including Caesar
frequencyStats :: [Char] -> [(Char, Int)]
frequencyStats xs =
  let input = map toLower xs
      freqs =
        map (\e -> (e, count e input)) lowerAlphabet
   in sortBy (\(_, x) (_, y) -> compare y x) freqs

-- This was a little advanced for what we learned so far, so I used
-- the solution in the code repo. It definitely hasn't explained `zip`
-- or `lookup`.
tryToDecrypt :: String -> String
tryToDecrypt "" = ""
tryToDecrypt msg =
  let
    -- The head of the resulting list from frequencyStats contains the most
    -- frequenct letter, everything else is ignored. We perform a pattern
    -- match of which we are certain it will work!
    ((mostCommonLetter, _) : _) = frequencyStats msg
    -- An associative list (see chapter 3) containing letters and their
    -- distance to the letter 'e'. Check for yourself that this is correct!
    distances = zip ['a' .. 'z'] [-4, -3 ..]
    -- We look up the distance of the most common letter to 'e' by performing
    -- a lookup on the associative list containing the distances. We receive
    -- a Maybe of the wanted element and pattern match it accordingly.
    -- (Please see chapter 3 for this!)
    Just guessedDistance = lookup mostCommonLetter distances
   in
    -- Now we can finally try to decrypt our message by performing the cipher
    -- with the guessed distance
    caesar guessedDistance msg
