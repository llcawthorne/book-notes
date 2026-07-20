module Palindrome where

import Control.Monad
import Data.Char (isAlpha, toLower)
import System.Exit (exitSuccess)

palindrome :: IO ()
palindrome = forever $ do
  line1 <- getLine
  case palindromeTest line1 of
    True  -> putStrLn "It's a palindrome!"
    False -> do
      putStrLn "Nope!"
      exitSuccess

palindromeTest :: String -> Bool
palindromeTest s = s' == reverse s'
  where s' = filter isAlpha $ map toLower s
