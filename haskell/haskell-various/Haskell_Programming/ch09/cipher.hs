module Cipher where

import Data.Char

caesar :: Int -> [Char] -> [Char]
caesar _ "" = "" 
caesar n (x:xs) 
     | isUpper x = chr ((mod (ord x + n - ord 'A') 26) + ord 'A')
                 : caesar n xs
     | isLower x = chr ((mod (ord x + n - ord 'a') 26) + ord 'a')
                 : caesar n xs
     | otherwise = x : caesar n xs
                 
uncaesar :: Int -> [Char] -> [Char]
uncaesar _ "" = ""
uncaesar n (x:xs) 
     | isUpper x = chr ((mod (ord x - n - ord 'A') 26) + ord 'A')
                 : uncaesar n xs
     | isLower x = chr ((mod (ord x - n - ord 'a') 26) + ord 'a')
                 : uncaesar n xs
     | otherwise = x : uncaesar n xs

roundtrip :: Int -> [Char] -> [Char]
roundtrip n xs = uncaesar n . caesar n $ xs