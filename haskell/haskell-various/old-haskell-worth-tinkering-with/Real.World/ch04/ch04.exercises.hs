-- file: ch04/ch04.exercises.hs

import Data.Char (digitToInt, isDigit)

-- 1) Write safe definitions of the standard head/tail/last/init functions
safeHead :: [a] -> Maybe a
safeHead (x:xs) = Just x
safeHead _      = Nothing

safeTail :: [a] -> Maybe [a]
safeTail (x:xs) = Just xs
safetail _      = Nothing

safeLast :: [a] -> Maybe a
safeLast (x:xs) = safeHead (reverse (x:xs))
safeLast _      = Nothing

safeInit :: [a] -> Maybe [a]
safeInit (x:xs) = safeTail (reverse (x:xs))
safeInit _      = Nothing

-- 2) Write splitWith to split on every element where a predicate is false
splitWith :: (a -> Bool) -> [a] -> [[a]]
splitWith _ []  = []
splitWith f [x]     | not (f x) = []
                    | otherwise = [[x]]
splitWith f (x:xs)  | not (f x) = splitWith f xs
                    | otherwise = [x:takeWhile f xs] ++ splitWith f (dropWhile f xs)

-- write asInt with folds
asInt_fold :: String -> Integer
asInt_fold ""       = error "You know that isn't a string of numbers"
asInt_fold ('-':[]) = error "Invalid negative sign alone!"
asInt_fold ('-':xs) = (-1) * asInt_fold xs
asInt_fold xs = foldl step 0 xs
    where step acc x | acc < 0              = error "Overflow or something!"  -- using Integer, shouldn't happen
                     | isDigit x            = acc * 10 + fromIntegral (digitToInt x)
                     | x == '.'             = error "Fractions make my teeth sweel"
                     | x == '-'             = error "Invalid negative sign"
                     | otherwise            = error "Danger will robinson!"

-- With Either
type ErrorMessage = String
asInt_either :: String -> Either ErrorMessage Integer
asInt_either ""       = Left "You know that isn't a string of numbers"
asInt_either ('-':[]) = Left "Invalid negative sign alone!"
asInt_either ('-':xs) = Right ((-1) * asInt_fold xs)
asInt_either xs = (foldl step (Right 0) xs)
    where step (Left message) _          = Left message
          step (Right acc) x | acc < 0   = Left "Strange overflow"
                             | isDigit x = Right (acc * 10 + fromIntegral (digitToInt x))
                             | x == '.'  = Left "Fractions make my teeth sweel"
                             | x == '-'  = Left "Invalid negative sign"
                             | otherwise = Left "Danger will robinson!"
