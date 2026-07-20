
sumSquareOrSquareSum x y = if sumSquare > squareSum
                           then sumSquare
                           else squareSum
  where sumSquare = x^2 + y^2
        squareSum = (x+y)^2

-- Q1
doubleDouble x = (\x -> 2*x) x * 2

sumSquareOrSquareSumLet x y = let sumSquare = x^2 + y^2
                                  squareSum = (x+y)^2
                              in
                               if sumSquare > squareSum
                               then sumSquare
                               else squareSum

overwrite x = (\x ->
                (\x ->
                  (\x -> x) 4
                ) 3
              ) 2

-- Q3.1
-- I'm not sure what functions it wanted me to rewrite

-- Q3.2
counter x = (\x -> x + 1) ((\x -> x + 1) ((\x -> x) x))
