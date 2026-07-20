-- file: ch03/Roygbiv.hs
-- using a algebraic data type like a C enumeration

data Roygbiv = Red
             | Orange
             | Yellow
             | Green
             | Blue
             | Indigo
             | Violet
               deriving (Eq, Show)
