module Exercises where

import Data.Char
import Data.List

-- 1) a. Weekday is a type with five data constructors
-- 2) f :: Weekday -> String
-- 3) b) must being with a capital letter
-- 4) c) delivers the final element of xs

-- see Cipher.hs

-- As Patterns
-- 1)
isSubseqOf :: (Eq a) => [a] -> [a] -> Bool
isSubseqOf []         _      = True
isSubseqOf _          []     = False
isSubseqOf sub@(s:ss) (x:xs)
  | s == x    = isSubseqOf ss  xs
  | otherwise = isSubseqOf sub xs

-- 2)
capitalizeWords :: String -> [(String, String)]
capitalizeWords xs = zip (words xs) (map cap $ words xs)
  where cap ""     = ""
        cap (x:xs) = toUpper x : xs

-- Language exercises
-- 1)
capitalizeWord :: String -> String
capitalizeWord ""     = ""
capitalizeWord (x:xs) = toUpper x : xs

-- 2)
capitalizeParagraph :: String -> String
capitalizeParagraph xs = intercalate ". " (map capitalizeWord (sentences xs))

sentences :: String -> [String]
sentences "" = []
sentences xs = takeWhile (/='.') xs : sentences (dropWhile (\x -> x==' ' || x=='.') (dropWhile (/='.') xs))

-- Phone exercise
-- 1)
data DaPhone = DaPhone [(Char, String)]
               deriving Show

phone = DaPhone [('1', ""),     ('2', "abc"), ('3', "def"),
                 ('4', "ghi"),  ('5', "jkl"), ('6', "mno"),
                 ('7', "pqrs"), ('8', "tuv"), ('9', "wxyz"),
                 ('*', "^"),    ('0', " "),   ('#', ".,")  ]

-- 2)
convo :: [String]
convo =
  ["Wanna play 20 questions",
   "Ya",
   "U 1st haha",
   "Lol ok. Have u ever tasted alcohol",
   "Lol ya",
   "Wow ur cool haha. Ur turn",
   "Ok. Do u think I am pretty Lol",
   "Lol ya",
   "Just making sure rofl ur turn"]

-- validButtons = "1234567890*#"
type Digit = Char

-- valid presses: 1 and up
type Presses = Int

reverseTaps :: DaPhone -> Char -> [(Digit, Presses)]
reverseTaps phone c 
  | isUpper c = reverseTaps phone '^' ++ reverseTaps phone (toLower c)
  | otherwise = findChar phone c
   where findChar (DaPhone [])      _    = []
         findChar (DaPhone ((c', cs):xs)) c
            | elem c cs = [(c', indexOf c cs + 1)]
            | otherwise = findChar (DaPhone xs) c
         indexOf c cs = case findIndex (==c) cs
                          of Just d -> d

-- assuming the default phone definition
-- 'a' -> [('2', 1)]
-- 'A' -> [('*', 1), ('2', 1)]

cellPhonesDead :: DaPhone -> String -> [(Digit, Presses)]
cellPhonesDead phone s = concat (map (reverseTaps phone) s)

-- 3)
fingerTaps :: [(Digit, Presses)] -> Presses
fingerTaps []          = 0
fingerTaps ((_, i):xs) = i + fingerTaps xs

-- 4) most popular letter for each message
mostPopularLetter :: String -> Char
mostPopularLetter str = 
  foldr (\x acc -> if countLetters x str > countLetters acc str then x else acc) (last str) str
  where countLetters c str' = length $ filter (==c) str'

-- 5) most popular letter overall and word
coolestLtr :: [String] -> Char
coolestLtr strs = mostPopularLetter (unlines strs)

coolestWord :: [String] -> String
coolestWord strs = 
  foldr 
    (\x acc -> if wordCount x (unlines strs) > wordCount acc (unlines strs) 
               then x 
               else acc) 
    (last (words (unlines strs))) 
    (words (unlines strs))
  where wordCount w str = length $ filter (==w) (words str)

-- Hutton's razor
data Expr
  = Lit Integer
  | Add Expr Expr

-- 1)
eval :: Expr -> Integer
eval (Lit n)   = n
eval (Add x y) = eval x + eval y

-- 2)
printExpr :: Expr -> String
printExpr (Lit n)   = show n
printExpr (Add x y) = printExpr x ++ " + " ++ printExpr y
