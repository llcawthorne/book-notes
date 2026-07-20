
myTake :: Int -> [a] -> [a]
myTake 0 _ = []
myTake n [] = []
myTake n (x:xs) = x : myTake (n-1) xs

fib :: Integer -> Integer
fib n 
  | n < 2 = n
  | otherwise = fib (n-1) + fib (n-2)

myGcd :: Integer -> Integer -> Integer
myGcd a 0 = a
myGcd a b = gcd b (mod a b)

myHead :: [a] -> a
myHead [] = error "Head of empty list!"
myHead (x:_) = x

myTail :: [a] -> [a]
myTail [] = error "Tail of empty list!"
myTail (_:xs) = xs

-- Q7.1
myTail' :: [a] -> [a]
myTail' [] = []
myTail' (_:xs) = xs

-- Q7.2
-- I already wrote myGcd using pattern matching above.
