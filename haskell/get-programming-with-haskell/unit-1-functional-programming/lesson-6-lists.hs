import Data.Char

isPalindrome word = cleanedWord == reverse cleanedWord
 where cleanedWord = map toLower . filter isAlpha $ word

respond phrase = if '!' `elem` phrase
                 then "wow!"
                 else "uh.. okay"

ones n = take n (cycle [1])

-- Q6.1
myRepeat x = x : myRepeat x

-- Q6.2
subseq x y aList = take (y - x) (drop x aList)

-- Q6.3
inFirstHalf e aList = e `elem` (take firstHalf aList)
  where firstHalf = length aList `div` 2
