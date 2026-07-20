-- file: ch04/Map.hs
import Data.Char (toUpper)

-- applying a func to every elt in a list is common, so we have map
-- first square and upperCase without map
square :: [Double] -> [Double]

square (x:xs) = x*x : square xs
square []     = []

upperCase :: String -> String

upperCase (x:xs) = toUpper x : upperCase xs
upperCase []     = []

-- now using map
square' xs    = map (**2) xs
upperCase' xs = map toUpper xs

-- how does map work?  here's an easy example of how it could be coded manually
myMap :: (a -> b) -> [a] -> [b]
myMap f (x:xs) = f x : myMap f xs
myMap _ _      = []
