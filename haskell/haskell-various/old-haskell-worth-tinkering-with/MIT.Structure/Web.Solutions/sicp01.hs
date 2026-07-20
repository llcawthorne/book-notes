module SICP01() where

import System.Random (randomRIO)
import CPUTime (getCPUTime)

main = do
   section_1_1_1
   section_1_1_2
   section_1_1_3
   section_1_1_4
   section_1_1_5
   section_1_1_6
   section_1_1_7
   section_1_1_8
   section_1_2_1
   section_1_2_2
   section_1_2_3
   section_1_2_4
   section_1_2_5
   section_1_2_6
   section_1_3_1
   section_1_3_2
   section_1_3_3
   section_1_3_4


-- 1.1.1 The Elements of Programming - Expressions

section_1_1_1 = do
   print (486)
   print (137 + 349)
   print (1000 - 334)
   print (5 * 99)
   print (10 `div` 5)
   print (2.7 + 10)
   print (21 + 35 + 12 + 7)
   print (25 * 4 * 12)
   print (3 * 5 + 10 - 6)
   print (3 * (2 * 4 + 3 + 5) + 10 - 7 + 6)


-- 1.1.2 The Elements of Programming - Naming and the Environment

section_1_1_2 = do
   print (size)
   print (5 * size)
   print (pi' * radius * radius)
   print (circumference)
   where
      size = 2
      pi' = 3.14159
      radius = 10
      circumference = 2 * pi' * radius


-- 1.1.3 The Elements of Programming - Evaluating Combinations

section_1_1_3 = do
   print ((2 + 4 * 6) * (3 + 5 + 7))


-- 1.1.4 The Elements of Programming - Compound Procedures

section_1_1_4 = do
   print (square 21)
   print (square (2 + 5))
   print (square (square 3))
   print (sumOfSquares 3 4)
   print (f 5)

square x = x * x

sumOfSquares x y = (square x) + (square y)

f a = sumOfSquares (a + 1) (a * 2)


-- 1.1.5 The Elements of Programming - The Substitution Model for Procedure Application

section_1_1_5 = do
   print (f 5)
   print (sumOfSquares (5 + 1) (5 * 2))
   print ((square 6) + (square 10))
   print (6*6 + 10*10)
   print (36 + 100)
   print (f 5)
   print (sumOfSquares (5 + 1) (5 * 2))
   print ((square (5 + 1)) + (square (5 * 2)))

   print (((5 + 1) * (5 + 1)) + ((5 * 2) * (5 * 2)))
   print ((6 * 6) + (10 * 10))
   print (36 + 100)
   print (136)


-- 1.1.6 The Elements of Programming - Conditional Expressions and Predicates

section_1_1_6 = do
   print (x > 5 && x < 10)

   -- Exercise 1.1
   print (10)
   print (5 + 3 + 4)
   print (9 - 1)
   print (6 `div` 2)
   print (2*4 + 4 - 6)
   print (a + b + a*b)
   print (a == b)
   print (if b > a && b < a*b then b else a)
   print (if a == 4
             then 6
             else
                if b == 4
                   then 6 + 7 + a
                   else 25)
   print (2 + if b > a then b else a)
   print ((if a > b
              then a
              else if a < b
                 then b
                 else -1) * (a + 1))

   -- Exercise 1.2
   print ((5 + 4 + (2 - (3 - (6 + (4 / 5))))) /
          (3 * (6 - 2) * (2 - 7)))

   -- Note: The question asks for prefix form (I am skipping use of rationals for now)
   print ((/) ((+) 5 ((+) 4 ((-) 2 ((-) 3 ((+) 6 ((/) 4 5))))))
              ((*) 3 ((*) ((-) 6 2) ((-) 2 7))))

   -- Exercise 1.5
   -- Note: is not infinite loop in Haskell (due to lazy evaluation)
   print (test 0 (p ()))

   where
      x = 6
      a = 3
      b = a + 1

abs' x =
   if x > 0
      then x
      else
         if x == 0
            then 0
            else -x

abs'' x =
   if x < 0
      then -x
      else x

ge x y = x > y || x == y

ge' x y = not (x < y)

-- Exercise 1.3
sumSquareMax a b c =
   if a > b
      then
         if a > c
            then
               if b > c
                  then a*a + b*b
                  else a*a + c*c
            else a*a + c*c
      else
         if b > c
            then
               if a > c
                  then b*b + a*a
                  else b*b + c*c
            else b*b + c*c

-- or more concisely
sumSquareMax' a b c =
   let
      (x, y) = if a > b then (a, b) else (b, a)
      z = if y > c then y else c
   in
      x*x + z*z

-- Exercise 1.4
aPlusAbsB a b =
   (if b > 0 then (+) else (-)) a b

-- Exercise 1.5
p () = p ()
test x y =
   if x == 0
      then 0
      else y


-- 1.1.7 The Elements of Programming - Example: Square Roots by Newton's Method

section_1_1_7 = do
   print (sqrt_0 9)
   print (sqrt_0 (100 + 37))
   print (sqrt_0 (sqrt_0 2 + sqrt_0 3))
   print (square (sqrt_0 1000))

   -- Exercise 1.6
   print (newIf (2==3) 0 5)
   print (newIf (1==1) 0 5)

   -- Note: not an infinite loop in Haskell
   print (sqrtNewIf 9)

goodEnough guess x =
   abs ((square guess) - x) < 0.001

average x y =
   (x + y) / 2

improve guess x =
   average guess (x / guess)

sqrtIter guess x =
   if goodEnough guess x
      then guess
      else sqrtIter (improve guess x) x

sqrt_0 x =
   sqrtIter 1 x

-- Exercise 1.6
newIf predicate thenClause elseClause =
   if predicate
      then thenClause
      else elseClause

sqrtIterNewIf guess x =
   newIf
      (goodEnough guess x)
      guess
      (sqrtIterNewIf (improve guess x) x)

sqrtNewIf x =
   sqrtIterNewIf 1 x

-- from wadler paper
newif' True  x _ = x
newif' False _ y = y

-- Exercise 1.7
goodEnoughGP guess prev =
   (abs (guess - prev)) / guess < 0.001

sqrtIterGP guess prev x =
   if goodEnoughGP guess prev
      then guess
      else sqrtIterGP (improve guess x) guess x

sqrtGP x =
   sqrtIterGP 4 1 x

-- Exercise 1.8
improveCube guess x =
   (2*guess + x/(guess * guess)) / 3

cubeIter guess prev x =
   if goodEnoughGP guess prev
      then guess
      else cubeIter (improveCube guess x) guess x

cubeRoot' x =
   cubeIter 27 1 x


-- 1.1.8 The Elements of Programming - Procedures as Black-Box Abstractions

section_1_1_8 = do
   print (square 5)
   print (sqrt_2 25)
   print (sqrt_3 25)

-- same as above
-- square x = x * x

double x = x + x

square' x = exp (double (log x))

goodEnough' guess x =
   abs ((square guess) - x) < 0.001

improve' guess x =
   average guess (x / guess)

sqrtIter' guess x =
   if (goodEnough' guess x)
      then guess
      else sqrtIter' (improve guess x) x

sqrt_1 x =
   sqrtIter' 1 x

-- Block-structured
sqrt_2 x =
   let
      goodEnough guess x =
         abs ((square guess) - x) < 0.001

      improve guess x =
         average guess (x / guess)

      sqrtIter guess x =
         if goodEnough guess x
            then guess
            else sqrtIter (improve guess x) x
   in
      sqrtIter 1 x

-- Taking advantage of lexical scoping
sqrt_3 x =
   let
      goodEnough guess =
         abs ((square guess) - x) < 0.001

      improve guess =
         average guess (x / guess)

      sqrtIter guess =
         if (goodEnough guess)
            then guess
            else sqrtIter (improve guess)
   in
      sqrtIter 1


-- 1.2.1 Procedures and the Processes They Generate - Linear Recursion and Iteration

section_1_2_1 = do
   print (factorial 6)
   print (factorial_0 6)
   print (factorial_1 6)
   print (a 1 10)
   print (a 2 4)
   print (a 3 3)

-- Recursive
factorial n =
   if n == 1
      then 1
      else n * factorial (n - 1)

-- alternate translation
factorial_0 1 = 1
factorial_0 n = n * factorial (n - 1)

-- Iterative
factorial_1 n =
   factIter 1 1 n

factIter product counter maxCount =
   if counter > maxCount
      then product
      else factIter (counter * product) (counter + 1) maxCount

-- Iterative, block-structured (from footnote)
factorial_2 n =
   iter 1 1
   where
      iter product counter =
         if counter > n
            then product
            else iter (counter * product) (counter + 1)

-- Exercise 1.9
inc a = a + 1
dec a = a - 1
plus a b =
   if a == 0
      then b
      else inc (plus (dec a) b)
plus' a b =
   if a == 0
      then b
      else plus' (dec a) (inc b)

-- Exercise 1.10
a x y =
   case (x, y) of
      (x, 0) -> 0
      (0, y) -> 2 * y
      (x, 1) -> 2
      (x, y) -> a (x - 1) (a x (y - 1))
f' n = a 0 n
g' n = a 1 n
h' n = a 2 n
k' n = 5 * n * n


-- 1.2.2 Procedures and the Processes They Generate - Tree Recursion

section_1_2_2 = do
   print (countChange 100)

   -- Exercise 1.11
   print (fi 5)
   print (fi' 5)

   -- Exercise 1.12
   print (pascalsTriangle 5 3)

-- Recursive
fib n =
   case n of
      0 -> 0
      1 -> 1
      _ -> fib (n - 1) + fib (n - 2)

-- alternate translation
fib' 0 = 0
fib' 1 = 1
fib' n = fib' (n - 1) + fib' (n - 2)

-- Iterative
fib'' n = fibIter 1 0 n

fibIter a b count =
   if count == 0
      then b
      else fibIter (a + b) a (count -1)

-- Counting change
countChange amount = cc amount 5

cc amount kindsOfCoins
   | amount == 0 = 1
   | amount < 0 || kindsOfCoins == 0 = 0
   | otherwise =
      (cc (amount - firstDenomination kindsOfCoins) kindsOfCoins) +
         (cc amount (kindsOfCoins - 1))

firstDenomination kindsOfCoins =
   case kindsOfCoins of
      1 -> 1
      2 -> 5
      3 -> 10
      4 -> 25
      5 -> 50

-- Exercise 1.11
fi n =
   if n < 3
      then n
      else (fi (n-1)) + 2*(fi (n-2)) + 3*(fi (n-3))

fiIter a b c count =
   if count == 0
      then c
      else fiIter (a + 2*b + 3*c) a b (count - 1)

fi' n = fiIter 2 1 0 n

-- Exercise 1.12
pascalsTriangle 0 k = 1
pascalsTriangle n 0 = 1
pascalsTriangle n k =
   if n == k
      then 1
      else (pascalsTriangle (n-1) (k-1)) + (pascalsTriangle (n-1) k)


-- 1.2.3 Procedures and the Processes They Generate - Orders of Growth

section_1_2_3 = do
   -- Exercise 1.15
   print (sine 60)

-- Exercise 1.15
cube' x = x * x * x
p' x = (3 * x) - (4 * (cube' x))
sine angle =
   if abs angle < 0.001
      then angle
      else p' (sine (angle / 3))


-- 1.2.4 Procedures and the Processes They Generate - Exponentiation

section_1_2_4 = do
   print (even 3)
   print (multiply 3 4)

-- Linear recursion
exp' b n =
    if n == 0
       then 1
       else b * (exp' b  (n-1))

-- Linear iteration
expIter b counter product =
    if counter == 0
       then product
       else expIter b (counter - 1) (b * product)

exp'' b n =
   expIter b n 1

-- Logarithmic iteration
even' n = ((n `mod` 2) == 0)

fastExpt b n
   | n == 0 = 1
   | otherwise =
      if (even n)
         then square (fastExpt b (n `div` 2))
         else b * fastExpt b (n - 1)

-- alternate translation
fastExpt' b n
   | n == 0 = 1
   | even n = square (fastExpt' b (n `div` 2))
   | otherwise = b * fastExpt' b (n - 1)

-- Exercise 1.16
fun fastExpIter b n =
   let
      exp b n a =
         if n == 0
            then a
            else
               if even n
                  then exp (square b) (n `div` 2) a
                  else exp b (n-1) (b*a)
   in
      exp b n 1

-- Exercise 1.17
multiply a b
   | b == 0 = 0
   | otherwise = plus a (multiply a (dec b))

halve x = x `div` 2
fastmultiply a b =
   if b == 0
      then 0
      else
         if even b
            then double (fastmultiply a (halve b))
            else plus a (multiply a b-1)

-- Exercise 1.19
fibIter' a b p q count
     | count == 0 = b
     | otherwise =
        if (even count)
           then fibIter' a b (p*p + q*q) (2*p*q + q*q) (count `div` 2)
           else fibIter' ((b * q) + (a * q) + (a * p)) ((b * p) + (a * q)) p q (count - 1)
fib_2 n =
   fibIter' 1 0 0 1 n


-- 1.2.5 Procedures and the Processes They Generate - Greatest Common Divisors

section_1_2_5 = do
   print (gcd' 40 6)

   -- Exercise 1.20
   print (gcd' 206 40)
   print (normalOrderGcd 206 40)

gcd' a b
   | b == 0 = a
   | otherwise = gcd' b (a `mod` b)

-- alternate implementation
gcd'' a 0 = a
gcd'' a b = gcd'' b (a `mod` b)

-- Exercise 1.20
normalOrderMod a b = a `mod` b
normalOrderGcd a b =
   if b == 0
      then a
      else normalOrderGcd b (normalOrderMod a b)


-- 1.2.6 Procedures and the Processes They Generate - Example: Testing for Primality

section_1_2_6 = do
   timedPrimeTest 13

   -- Exercise 1.21
   print (smallestDivisor 199)
   print (smallestDivisor 1999)
   print (smallestDivisor 19999)

   -- Exercies 1.22
   searchForPrimes 1000 3
   searchForPrimes 10000 3
   searchForPrimes 100000 3
   searchForPrimes 1000000 3

   -- Exercies 1.24
   fastSearchForPrimes (1000 :: Int) 3
   fastSearchForPrimes (10000 :: Int) 3
   fastSearchForPrimes (100000 :: Integer) 3
   fastSearchForPrimes (1000000 :: Integer) 3

   -- Exercise 1.27
   (carmichael (561 :: Int)) >>= print
   (carmichael (1105 :: Int)) >>= print
   (carmichael (1729 :: Int)) >>= print
   (carmichael (2465 :: Int)) >>= print
   (carmichael (2821 :: Int)) >>= print
   (carmichael (6601 :: Int)) >>= print

   -- Exercise 1.28
   print (millerRabinTest 5)
   print (millerRabinTest 15)
   print (millerRabinTest 97)
   print (millerRabinTest 121)
   print (millerRabinTest 1003)
   print (millerRabinTest 1009)
   print (millerRabinTest 100003)
   print (millerRabinTest 100005)
   print (millerRabinTest 561)
   print (millerRabinTest 1105)
   print (millerRabinTest 1729)
   print (millerRabinTest 2465)
   print (millerRabinTest 2821)
   print (millerRabinTest 6601)

-- prime
divides a b = (b `mod` a == 0)

findDivisor n testDivisor =
   if square testDivisor > n
      then n
      else
         if divides testDivisor n
            then testDivisor
            else findDivisor n (testDivisor + 1)

smallestDivisor n = findDivisor n 2

prime n = (n == smallestDivisor n)

-- fastPrime
expmod nbase nexp m
   | nexp == 0 = 1
   | otherwise =
      if (even nexp)
         then (square (expmod nbase (nexp `div` 2) m)) `mod` m
         else (nbase * (expmod nbase (nexp - 1) m)) `mod` m

fermatTest n = do
   randomRIO (1, n-1) >>= return . tryIt
   where
      tryIt a = ((expmod a n n) == a)

fastPrime n ntimes =
   if ntimes == 0
      then return True
      else do
         t <- (fermatTest n)
         if t
            then fastPrime n (ntimes - 1) >>= return
            else return False

-- Exercise 1.22
reportPrime n elapsedTime = do
   putStrLn (" *** " ++ (show n) ++ " " ++ (show elapsedTime))

-- returns time in picoseconds
getTimeInMilliseconds () = do
   getCPUTime >>= return

startPrimeTest n startTime = do
   if (prime n)
      then do
         t <- getTimeInMilliseconds ()
         reportPrime n (t - startTime)
         return True
      else return False

timedPrimeTest n = do
   t <- getTimeInMilliseconds ()
   startPrimeTest n t

searchForPrimes n i =
   if (n > 2) && (even n)
      then do
         searchForPrimes (n+1) i
      else do
         t <- timedPrimeTest n
         if t
            then
               if i > 1
                  then searchForPrimes (n+2) (i-1)
                  else return ()
            else do
               searchForPrimes (n+2) i

-- Exercise 1.23
nextDivisor n =
   if n == 2
      then 3
      else n+2
findDivisor' n testDivisor =
   if (square testDivisor) > n
      then n
      else
         if divides testDivisor n
            then testDivisor
            else findDivisor' n (nextDivisor testDivisor)

-- Exercise 1.24
fastStartPrimeTest n startTime = do
   f <- fastPrime n 100
   if f
      then do
         t <- getTimeInMilliseconds ()
         reportPrime n (t - startTime)
         return True
      else return False

fastTimedPrimeTest n = do
   t <- getTimeInMilliseconds ()
   (fastStartPrimeTest n t) >>= return

fastSearchForPrimes n i =
   if (n > 2) && (even n)
      then do
         fastSearchForPrimes (n+1) i
      else do
         t <- fastTimedPrimeTest n
         if t
            then
               if i > 1
                  then fastSearchForPrimes (n+2) (i-1)
                  else return ()
            else fastSearchForPrimes (n+2) i

-- Exercise 1.25
expmod' nbase nexp m =
   fastExpt (nbase nexp) `mod` m

-- Exercise 1.26
expmod'' nbase nexp m
   | nexp == 0 = 1
   | otherwise =
      if even nexp
         then ((expmod'' nbase (nexp `div` 2) m) *
               (expmod'' nbase (nexp `div` 2) m)) `mod` m
         else (nbase * (expmod'' nbase (nexp - 1) m)) `mod` m

-- Exercise 1.27
carmichael n = do
   t <- (fastPrime n 100)
   return (t && not (prime n))

-- Exercise 1.28
expmod''' nbase nexp m =
   if nexp == 0
      then 1
      else
         if even nexp
            then
               let
                  candidate = expmod''' nbase (nexp `div` 2) m
                  root = (square candidate) `mod` m
               in
                  if (candidate /= 1) && (candidate /= (m-1)) && (root == 1)
                     then 0
                     else root
            else nbase * (expmod''' nbase (nexp-1) m) `mod` m

millerRabinTest n =
   let
      tryit a = (expmod''' a (n-1) n) == 1
      millerRabinIteration a t n =
         if a == n
            then t > (n `div` 2)
            else
               if tryit a
                  then millerRabinIteration (a+1) (t+1) n
                  else millerRabinIteration (a+1) t n
   in
      millerRabinIteration 1 0 n


-- 1.3 Formulating Abstractions with Higher-Order Procedures

cube x = x * x * x


-- 1.3.1 Formulating Abstractions with Higher-Order Procedures - Procedures as Arguments

section_1_3_1 = do
   print (sumCubes 1 10)
   print (sumCubes' 1 10)
   print (sumIntegers 1 10)
   print (sumIntegers' 1 10)
   print (8 * (piSum 1 1000))
   print (8 * (piSum' 1 1000))
   print (integral cube 0 1 0.01)
   print (integral cube 0 1 0.001)

   -- Exercise 1.29
   print (simpson cube 0 1 100)

   -- Exercise 1.30
   print (sumCubes'' 1 10)

   -- Exercise 1.31
   print (factorial_3 5)
   print (factorial_4 5)
   print (wallisPi 100)

   -- Exercise 1.32
   print (accumulate plus 0 identity 1 inc 5)
   print (accumulate multiply 1 identity 1 inc 5)
   print (accumulateIter plus identity 1 inc 5 0)
   print (accumulateIter multiply identity 1 inc 5 1)

   -- Exercise 1.33
   print (filteredAccumulate plus 0 square 1 inc 5 prime)
   print (sumSquaresOfPrimes 2 5)

sumIntegers a b =
   if a > b
      then 0
      else a + (sumIntegers (a + 1) b)

sumCubes a b =
   if a > b
      then 0
      else (cube a) + (sumCubes (a + 1) b)

piSum a b =
   if a > b
      then 0
      else (1 / (a * (a + 2))) + (piSum (a + 4) b)

sum' term a next b =
   if (a > b)
      then 0
      else (term a) + (sum' term (next a) next b)

-- Using sum
-- same as above
-- inc n = n + 1

sumCubes' a b =
   sum' cube a inc b

identity x = x

sumIntegers' a b =
   sum' identity a inc b

sumFloat term a next b =
   if a > b
      then 0
      else (term a) + (sumFloat term (next a) next b)

piSum' a b =
   let
      piTerm x = 1 / (x * (x + 2))
      piNext x = x + 4
   in
      sumFloat piTerm a piNext b

integral f a b dx =
   let
      addDx x = x + dx
   in
      (sumFloat f (a + (dx / 2)) addDx b) * dx

-- Exercise 1.29
simpson f a b n =
   let
      h = abs (b - a) / n
      sumIter term start next stop acc =
         if start > stop
            then acc
            else sumIter term (next start) next stop (acc + (term (a + start * h)))
   in
      h * (sumIter f 1 inc n 0)

-- Exercise 1.30
sumIter term a next b acc =
   if a > b
      then acc
      else sumIter term (next a) next b (acc + (term a))
-- sumCubes'' reimplements sumCubes' but uses sumIter in place of sum'
sumCubes'' a b =
   sumIter cube a inc b 0

-- Exercise 1.31
-- a.
product' term a next b =
   if a > b
      then 1
      else (term a) * (product' term (next a) next b)

factorial_3 n =
   product' identity 1 inc n

-- b.
productIter term a next b acc =
   if a > b
      then acc
      else productIter term (next a) next b (acc * (term a))

factorial_4 n =
   productIter identity 1 inc n 1

wallisPi n =
   let
      wallisTerm k =
         let
            nom = (fromIntegral k :: Double) + if even k then 2 else 1
            denom = (fromIntegral k  :: Double) + if even k then 1 else 2
         in
            nom / denom
   in
      4 * (productIter wallisTerm 1 inc n 1)

-- Exercise 1.32
-- a.
accumulate combiner nullvalue term a next b =
   if a > b
      then nullvalue
      else combiner (term a) (accumulate combiner nullvalue term (next a) next b)

sum'' a b = accumulate (+) 0 identity a inc b
product'' a b = accumulate (*) 1 identity a inc b

-- b.
-- NOTE: starting value of 'Acc' is 'NullValue'
accumulateIter combiner term a next b acc =
   if a > b
      then acc
      else accumulateIter combiner term (next a) next b (combiner acc (term a))

sum''' a b = accumulateIter (+) identity a inc b 0
product''' a b = accumulateIter (*) identity a inc b 1

-- Exercise 1.33
filteredAccumulate combiner nullvalue term a next b pred =
   if a > b
      then nullvalue
      else
         if pred a
            then combiner (term a) (filteredAccumulate combiner nullvalue term (next a) next b pred)
            else filteredAccumulate combiner nullvalue term (next a) next b pred

sumSquaresOfPrimes a b =
   filteredAccumulate (+) 0 square a inc b prime

productOfRelativelyPrime n =
   let
      isRelativelyPrimeToN k =
         (gcd k n) == 1
   in
      filteredAccumulate (*) 1 identity 1 inc (n-1) isRelativelyPrimeToN


-- 1.3.2 Formulating Abstractions with Higher-Order Procedures - Constructing Procedures Using Lambda

section_1_3_2 = do
   print (8 * piSum'' 1 1000)
   print (integral' cube 0 1 0.01)
   print ((\x -> \y -> \z -> x + y + (square z)) 1 2 3)

   print (
      let
         x = 3
      in
         x + x*10
      + x)

   print (
      let
         y = x' + 2
      in
         let
            x' = 3
         in
            x' * y)

   -- Exercise 1.34
   print (f_5 square)
   print (f_5 (\z -> z * (z + 1)))
   -- this won't type check in Haskell
   -- print (f_5 f_5)
   where
      x = 5
      x' = 2

piSum'' a b =
   sum' (\x -> 1 / (x * (x + 2))) a (\x -> x + 4) b

integral' f a b dx =
   (sum' f (a + (dx / 2)) (\x -> x + dx) b) * dx

plus4 x = x + 4

plus4' = \x -> x + 4

-- Using let
f_1 x y =
   let
      fHelper a b =
         x*(square a) + y*b + a*b
   in
      fHelper (1 + x*y) (1 - y)

f_2 x y =
   (\a -> \b -> x*(square a) + y*b + a*b)
      (1 + x*y) (1 - y)

f_3 x y =
   let
      a = 1 + x*y
      b = 1 - y
   in
      x*(square a) + y*b + a*b

f_4 x y =
   let
      a = 1 + x*y
      b = 1 - y
   in
      x*(square a) + y*b + a*b

-- Exercise 1.34
f_5 g = g 2


-- 1.3.3 Formulating Abstractions with Higher-Order Procedures - Procedures as General Methods

section_1_3_3 = do
   print (halfIntervalMethod sin 2 4)
   print (halfIntervalMethod (\x -> (x * x * x) - (2 * x) - 3) 1 2)

   print (fixedPoint cos 1)
   print (fixedPoint (\y -> (sin y) + (cos y)) 1)

   print (sqrt_5 25)

   -- Exercise 1.35
   print (goldenRatio)

   -- Exercise 1.36
   -- 35 guesses before convergence
   print (fixedPoint (\x -> (log 1000) / (log x)) 1.5)
   -- 11 guesses before convergence (averageDamp defined below)
   print (fixedPoint (averageDamp (\x -> (log 1000) / (log x))) 1.5)

   -- Exercise 1.37
   print (contFrac (\i -> 1) (\i -> 1) 11)
   print (contFracIter (\i -> 1) (\i -> 1) 11)

   -- Exercise 1.38
   print (
      contFrac
         (\i -> 1)
         (\i ->
            if (i+1) `mod` 3 == 0
               then 2 * ((fromIntegral i :: Double) + 1) / 3
               else 1)
         10)

   print (tanCf (degreesToRadians 30) 1000)

-- Half-interval method
closeEnough x y =
   abs (x - y) < 0.001

positive x = (x >= 0)
negative x = not (positive x)

search f negPoint posPoint =
   let
      midpoint = average negPoint posPoint
   in
      if closeEnough negPoint posPoint
         then midpoint
         else
            let
               testValue = f midpoint
            in
               if positive testValue
                  then search f negPoint midpoint
                  else
                     if negative testValue
                        then search f midpoint posPoint
                        else midpoint

halfIntervalMethod f a b =
   let
      aValue = f a
      bValue = f b
   in
      if ((negative aValue) && (positive bValue))
         then search f a b
         else
            if ((negative bValue) && (positive aValue))
               then search f b a
               else error ("Values are not of opposite sign" ++ (show a) ++ " " ++ (show b))

-- Fixed points
tolerance = 0.00001

fixedPoint f firstGuess =
   let
      closeEnough v1 v2 =
         abs (v1 - v2) < tolerance
      try guess =
         let
            next = f guess
         in
            if (closeEnough guess next)
               then next
               else try next
   in
      try firstGuess

-- note: this function does not converge
sqrt_4 x =
   fixedPoint (\y -> x / y) 1

sqrt_5 x =
   fixedPoint (\y -> average y (x / y)) 1

-- Exercise 1.35
goldenRatio = fixedPoint (\x -> 1 + 1/x) 1

-- Exercise 1.37
contFrac n d k =
   let
      frac i =
         (n i) / ((d i) + if i == k then 0 else frac (i+1))
   in
      frac 1

contFracIter n d k =
   let
      fracIter i result =
         if i == 0
            then result
            else fracIter (i-1) ((n i)/ ((d i) + result))
   in
      fracIter k 0

-- Exercise 1.39
tanCf x k =
   let
      n i =
         if i == 1
            then x
            else -(x*x)
      d i =
         (fromIntegral i :: Double)*2 - 1

   in
      contFrac n d k

degreesToRadians d = (d/360) * 2 * pi


-- 1.3.4 Formulating Abstractions with Higher-Order Procedures - Procedures as Returned Values

section_1_3_4 = do
   print (averageDamp square 10)
   print (sqrt_6 25)
   print (cubeRoot 27)
   print ((deriv cube) 5)
   print (sqrt_7 25)
   print (sqrt_8 25)
   print (sqrt_9 25)

   -- Exercise 1.40
   print (newtonsMethod (cubic 5 3 2.5) 1)

   -- Exercise 1.41
   print (double' inc 5)
   print (double' double' inc 5)
   print (double' double' double' inc 5)

   -- Exercise 1.42
   print (compose square inc 6)

   -- Exercise 1.43
   print (repeated square 2 5)
   print (repeated' square 2 5)

   -- Exercise 1.44
   print (fixedPoint (smooth (\x -> (log 1000) / (log x))) 1.5)

   -- Exercise 1.45
   print (repeatedDampenRoot 625 4 2)

   -- Exercise 1.46
   print (sqrt_10 25)
   print (fixedPoint' (averageDamp (\x -> (log 1000) / (log x))) 1.5)

averageDamp f =
   \x -> average x (f x)

sqrt_6 x =
   fixedPoint (averageDamp (\y -> x / y)) 1

cubeRoot x =
   fixedPoint (averageDamp (\y -> x / (square y))) 1

-- Newton's method
dx = 0.00001
deriv g =
   \x -> (g (x + dx) - g (x)) / dx

-- same as before
-- cube x = x * x * x

newtonTransform g =
   \x -> x - ((g x) / ((deriv g) x))

newtonsMethod g guess =
   fixedPoint (newtonTransform g) guess

sqrt_7 x =
   newtonsMethod (\y -> (square y) - x) 1

-- Fixed point of transformed function
fixedPointOfTransform g transform guess =
   fixedPoint (transform g) guess

sqrt_8 x =
   fixedPointOfTransform (\y -> x / y) averageDamp 1

sqrt_9 x =
   fixedPointOfTransform (\y -> (square y) - x) newtonTransform 1

-- Exercise 1.40
cubic a b c =
   \x -> x*x*x + a*x*x + b*x + c

-- Exercise 1.41
double' f = \x -> f (f x)

-- Exercise 1.42
compose f g =
   \x -> f (g x)

-- Exercise 1.43
repeated f n =
   if n == 0
      then identity
      else compose f (repeated f (n-1))

-- another implementation
repeated' f n =
   let
      iter arg i =
         if i > n
            then arg
            else iter (f arg) (i + 1)
   in
      \x -> iter x 1

-- Exercise 1.44
smooth f =
   let
      dx = 0.00001
   in
      \x -> (f (x-dx) + (f x) + (f x+dx)) / 3
nFoldSmooth f n =
   repeated (smooth f) n

-- Exercise 1.45
repeatedDampenRoot x nroot nrepeat =
   fixedPointOfTransform
      (\y -> average y (x / (y ^ (nroot-1))))
      (repeated averageDamp nrepeat)
      1

-- Exercise 1.46
iterativeImprove goodEnough improve =
   let
      iter guess =
         let
            next = improve guess
         in
            if goodEnough guess next
               then next
               else iter next
   in
      \x -> iter x

sqrt_10 x =
   let
      tolerance = 0.00001
   in
      (
         iterativeImprove
            (\g -> \n -> abs (n*n - x) < tolerance)
            (\g -> (g + x/g) / 2)
         1
      )

fixedPoint' f firstGuess =
   let
      tolerance = 0.00001
      goodEnough v1 v2 =
         abs (v1 - v2) < tolerance
   in
      iterativeImprove goodEnough f firstGuess

