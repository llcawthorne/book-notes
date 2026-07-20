module Singing where

fstString :: [Char] -> [Char]
fstString x = x ++ " in the rain"

sndString :: [Char] -> [Char]
sndString x = x ++ " over the rainbow"

sing1 = if (x > y) then fstString x else sndString y
 where x = "Singing"
       y = "Somewhere"

sing2 = if (x < y) then fstString x else sndString y
 where x = "Singing"
       y = "Somewhere"
