-- QC 11.1
halve :: Integer -> Integer
halve x = x `div` 2

-- QC 11.2
printDouble :: Integer -> String
printDouble = show . (*2)

-- QC 11.3
-- (((makeAddress 123) "Happy St") "Haskell Town")
-- makeAddress :: Integer -> String -> String -> (Integer, String, String)
-- makeAddress 123 :: String -> String -> (Integer, String, String)
-- (makeAddress 123) "Happy St" :: String -> (Integer, String, String)
-- ((makeAddress 123) "Happy St") "Haskell Town" :: (Integer, String, String)

-- QC 11.4
-- The function can transform the objects in the list to a different type

-- Q11.1
-- filter :: (a -> Bool) -> [a] -> [a]
-- filter doesn't transform a list to a different type

-- Q11.2
-- head :: [a] -> a
-- It needs to return a type of the items in the list

-- Q11.3
myFoldl :: (b -> a -> b) -> b -> [a] -> b
myFoldl f init [] = init
myFoldl f init (x:xs) = myFoldl f newInit xs
  where newInit = f init x
