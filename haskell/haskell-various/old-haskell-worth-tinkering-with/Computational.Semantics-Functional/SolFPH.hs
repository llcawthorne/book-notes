module SolFPH where 

import FPH

listEq :: (Eq a) => [a] -> [a] -> Bool
listEq [] [] = True
listEq [] _  = False
listEq _  [] = False
listEq (x:xs) (y:ys) = x == y && listEq xs ys 

inflistEq :: (Eq a) => [a] -> [a] -> Bool
inflistEq (x:xs) (y:ys) = x == y && inflistEq xs ys 

minList :: Ord a => [a] -> a
minList [x]      = x
minList (x:y:zs) = minList ((min x y) : zs)

delete :: Ord a => a -> [a] -> [a]
delete x []     = []
delete x (y:ys) | x == y    = ys
                | otherwise = y : (delete x ys)

srt :: Ord a => [a] -> [a]
srt [] = []
srt xs = x : srt (delete x xs)
   where x = minList xs

averageLength :: String -> Rational
averageLength sonnet = average (map f (words sonnet))
             where f = length . filter (`notElem` "'?;:,.")

sublist :: Ord a => [a] -> [a] -> Bool
sublist [] []     = True 
sublist xs []     = False
sublist xs (y:ys) = prefix xs (y:ys) || sublist xs ys

data DeclClass = One | Two | Three | Four | Five 

swedishPlural :: String -> DeclClass -> String
swedishPlural noun d = case d of 
  One   -> init noun ++ "or"
  Two   -> init noun ++ "ar"
  Three -> if (last noun) `elem` swedishVowels
           then noun ++ "r"
           else noun ++ "er"
  Four  -> noun ++ "n"
  Five  -> noun

appendSuffixY :: [Phoneme] -> [Phoneme] -> [Phoneme]
appendSuffixY stem suffix = 
 stem ++ map (vh (vowel stem)) suffix
 where 
  vowel = head . filter (`elem` yawelmaniVowels)
  height   = fValue High
  vh p p' | height p == height p' = 
            (fMatch Back (fValue Back p)
             . fMatch Round (fValue Round p)) p'
          | otherwise             = p'

