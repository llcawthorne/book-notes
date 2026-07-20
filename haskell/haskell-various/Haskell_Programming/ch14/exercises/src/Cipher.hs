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

roundtripC :: Int -> [Char] -> [Char]
roundtripC n xs = uncaesar n . caesar n $ xs

vigenere :: String -> String -> String
vigenere _   ""  = ""
vigenere key@(y:ys) (x:xs)
    | isUpper x = chr ((mod (ord x + (ord . toUpper) y) 26) + ord 'A')
                : vigenere (take (length xs) $ (++) ys $ concat $ repeat key) xs
    | isLower x = chr ((mod ((ord x - ord 'a') + ((ord . toLower) y - ord 'a')) 26) + ord 'a')
                : vigenere (take (length xs) $ (++) ys $ concat $ repeat key) xs
    | otherwise = x : vigenere (take (length xs) $ (++) (y:ys) $ concat $ repeat key) xs

unvigenere :: String -> String -> String
unvigenere _   ""  = ""
unvigenere key@(y:ys) (x:xs)
    | isUpper x = chr ((mod (ord x - (ord . toUpper) y) 26) + ord 'A')
                : unvigenere (take (length xs) $ (++) ys $ concat $ repeat key) xs
    | isLower x = chr ((mod ((ord x - ord 'a') - ((ord . toLower) y - ord 'a')) 26) + ord 'a')
                : unvigenere (take (length xs) $ (++) ys $ concat $ repeat key) xs
    | otherwise = x : unvigenere (take (length xs) $ (++) (y:ys) $ concat $ repeat key) xs

roundtripV :: String -> String -> String
roundtripV key phs = unvigenere key . vigenere key $ phs

main :: IO ()
main = do 
  putStrLn "----- Demonstrating Caesar cipher -----"
  putStr "Enter phrase to encrypt: "
  phrase <- getLine
  putStr "Enter number of characters to offset: "
  m <- getLine
  let n = (read m :: Int)
  putStrLn $ "ENCRYPTED: " ++ caesar n phrase 
  putStrLn "----- Demonstrating Vigenere cipher -----"
  putStr "Enter phrase to encrypt: "
  phrase2 <- getLine
  putStr "Enter keyphrase: "
  keyphrase <- getLine
  putStrLn $ "ENCRYPTED: " ++ vigenere keyphrase phrase2
