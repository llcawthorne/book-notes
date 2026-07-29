
myDrop :: Int -> [a] -> [a]
myDrop n [] = []
myDrop 0 xs = xs 
myDrop n (_:xs) = myDrop (n-1) xs

-- QC 8.1
myLength :: [a] -> Int
myLength [] = 0
myLength (_:xs) = 1 + myLength xs

myCycle :: [a] -> [a]
myCycle (x:xs) = x : myCycle (xs ++ [x])

-- you can use :set +s to display timing information on functions in GHCI
ackerman :: Integer -> Integer -> Integer
ackerman 0 n = n + 1
ackerman m 0 = ackerman (m-1) 1
ackerman m n = ackerman (m-1) (ackerman m (n-1))

collatzPath :: Integer -> [Integer]
collatzPath 1 = [1]
collatzPath n
  | even n = n : collatzPath (div n 2)
  | otherwise = n : collatzPath (3*n+1)

collatz :: Integer -> Int
collatz n  = length . collatzPath $ n

-- Q8.1
myReverse :: [a] -> [a]
myReverse [] = []
myReverse (x:xs) = myReverse xs ++ [x]

-- Q8.2
fastFib :: Integer -> Integer -> Integer -> Integer
fastFib n m 0 = m
fastFib n m c = fastFib (n+m) n (c-1)
-- *Main> map (fastFib 1 0) [0..10]
-- [0,1,1,2,3,5,8,13,21,34,55]
