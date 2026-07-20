import Data.Char

myMap :: (a -> b) -> [a] -> [b]
myMap _ [] = []
myMap f (x:xs) = f x : myMap f xs

myFilter :: (a -> Bool) -> [a] -> [a]
myFilter _ [] = []
myFilter p (x:xs) = if p x then x : myFilter p xs else myFilter p xs

-- QC 9.1
remove :: (a -> Bool) -> [a] -> [a]
remove _ [] = []
remove p (x:xs) = if p x then remove p xs else x : remove p xs

-- QC 9.2
myProduct :: (Num a) => [a] -> a
myProduct = foldl (*) 1

concatAll xs = foldl (++) "" xs
sumOfSquares xs = foldl (+) 0 (map (^2) xs)
myReverse xs = foldl (flip (:)) [] xs

myFoldl f init [] = init
myFoldl f init (x:xs) = myFoldl f newInit xs
  where newInit = f init x

myFoldr f init [] = init
myFoldr f init (x:xs) = f x rightResult
  where rightResult = myFoldr f init xs

-- Q9.1
myElem :: (Eq a) => a -> [a] -> Bool
myElem e xs = length (filter (== e) xs) > 0

-- Q9.2
isPalindrome :: [Char] -> Bool
isPalindrome xs = cleanXs == reverse cleanXs
  where cleanXs = filter isAlpha (map toLower xs)

-- Q9.3 -- in reverse because of commutativity of addition
harmonic :: Integer -> Double
harmonic 1 = 1 / 1
harmonic n = 1 / (fromIntegral n) + harmonic (n-1)

-- Q9.3 another way
myHarmonic n = sum (take n seriesValues)
  where seriesPairs = zip (cycle [1.0]) [1.0, 2.0..]
        seriesValues = map 
                         (\pair -> (fst pair)/(snd pair))
                         seriesPairs
