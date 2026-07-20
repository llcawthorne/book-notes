-- file: ch03/add.hs
-- pattern matching goodness!
myNot True  = False
myNot False = True

sumList (x:xs) = x + sumList xs
sumList []     = 0

-- third piece of a tuple
third (a, b, c) = c
