-- squareCube.hs
module SquareCube where 

mySqr = [x^2 | x <- [1..5]]
myCube = [y^3 | y <- [1..5]]

-- 1) Tuple them up
myTuples = [(x, y) | x <- mySqr, y <- myCube]

-- 2) Tuples where values less than 50
myTuples2 = [(x, y) | x <- mySqr, y <- myCube, x < 50, y < 50]

-- 3) Find out how many of myTuples2 there are
myTuples2Length = length myTuples2