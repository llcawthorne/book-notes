-- broken?
module SICP02() where

import System.IO
import Control.Concurrent.MVar (MVar, newMVar, takeMVar, putMVar)

main = do
   section_2_1_1
   section_2_1_2
   section_2_1_3
   section_2_1_4
   section_2_2_1
   section_2_2_2
   section_2_2_3
   section_2_2_4
   section_2_3_1
   section_2_3_2
   section_2_3_3
   section_2_3_4
   section_2_4_1
   section_2_4_2

-- Functions defined in previous chapters
gcd' a 0 = a
gcd' a b = gcd' b (a `mod` b)

fib 0 = 0
fib 1 = 1
fib n = fib (n - 1) + fib (n - 2)

identity x = x

square x = x * x


-- 2 Building Abstractions with Data

linearCombination a b x y =
   a*x + b*y

mul a b = a * b

linearCombination' a b x y =
   (mul a x) + (mul b y)


-- 2.1.1 Introduction to Data Abstraction - Example: Arithmetic Operations for Rational Numbers

section_2_1_1 = do
   print (car x)
   print (cdr x)
   print (car (car z))
   print (car (cdr z))

   printRat (oneHalf)

   printRat (addRat oneHalf oneThird)
   printRat (mulRat oneHalf oneThird)
   printRat (addRat oneThird oneThird)

   printRat (addRatGcd oneThird oneThird)

   where
      x = cons 1 [2]
      y = cons 3 [4]
      z = cons x [y]

      oneHalf = makeRat 1 2
      oneThird = makeRat 1 3

makeRat n d = (n, d)
numer x = fst x
denom x = snd x

addRat x y =
   makeRat (numer x * denom y + numer y * denom x)
           (denom x * denom y)
subRat x y =
   makeRat (numer x * denom y - numer y * denom x)
           (denom x * denom y)
mulRat x y =
   makeRat (numer x * numer y)
           (denom x * denom y)
divRat x y =
   makeRat (numer x * denom y)
           (denom x * numer y)
equalRat x y =
   numer x * denom y == numer y * denom x

cons x y = x : y
car = head
cdr = tail
cadr = car . cdr
cadr' x = car (cdr x)

-- footnote - alternative definitions
makeRatFn = cons
numerFn = car
denomFn = car . cdr

printRat x =
   print ((show (numer x)) ++ "/" ++ (show (denom x)))

-- reducing to lowest terms in constructor
makeRatGcd n d =
   (n `div` g, d `div` g)
   where g = gcd n d

addRatGcd x y =
   makeRatGcd (numer x * denom y + numer y * denom x)
              (denom x * denom y)

-- Exercise 2.1
makeRat' n d =
   if (d < 0 && n < 0) || n < 0
      then (-1 * d, -1 * n)
      else (d, n)


-- 2.1.2 Introduction to Data Abstraction - Abstraction barriers

section_2_1_2 = do
   print (numerx r)
   print (denomx r)

   -- Exercise 2.2
   printPoint (midpointSegment (makeSegment (makePoint 4 6) (makePoint 9 15)))

   -- Exercise 2.3
   print ((show (rectPerimeter rx)) ++ " " ++ (show (rectArea rx)))
   print ((show (rectPerimeter ry)) ++ " " ++ (show (rectArea ry)))

   where
      r = makeRatx 6 9

      -- Exercise 2.3
      rx = ptsMakeRectangle (makePoint 10 15) (makePoint 30 40)
      ry = pwhMakeRectangle (makePoint 10 15) 20 25

-- reducing to lowest terms in selectors
makeRatx n d = (n, d)

numerx x = (fst x) `div` g
   where g = gcd (fst x) (snd x)

denomx x = (snd x) `div` g
   where g = gcd (fst x) (snd x)

-- Exercise 2.2
makePoint x y = (x, y)
xPoint point = fst point
yPoint point = snd point
makeSegment startSegment endSegment = (startSegment, endSegment)
startSegment' segment = fst segment
endSegment' segment = snd segment
midpointSegment segment =
   makePoint ((xPoint s + xPoint e) / 2)
             ((yPoint s + yPoint e) / 2)
   where
      s = startSegment' segment
      e = endSegment' segment
printPoint p =
   print  ("(" ++ (show (xPoint p)) ++ "," ++ (show (yPoint p)) ++ ")")

-- Exercise 2.3
-- High-level procedures are quarantined from representation / implementation details
rectArea rect =
   (rectWidth rect) * (rectHeight rect)
rectPerimeter rect =
   2*(rectWidth rect) + 2*(rectHeight rect)

-- Constructors create tagged type
data Rectangle a = Pts {rp1::(a, a), rp2::(a, a)}
                 | Pwh {p::(a, a), rwidth::a, rheight::a}

-- Representation 1: stores the two opposing points p1 and p2
ptsMakeRectangle p1 p2 = Pts {rp1=p1, rp2=p2}
ptsRectWidth  (Pts {rp1=p1, rp2=p2}) = abs (xPoint p1 - xPoint p2)
ptsRectHeight (Pts {rp1=p1, rp2=p2}) = abs (yPoint p1 - yPoint p2)

-- Representation 2: stores the achor point and width/height
pwhMakeRectangle p width height = Pwh {p=p, rwidth=width, rheight=height}
pwhRectWidth  (Pwh {rwidth=width}) = width
pwhRectHeight (Pwh {rheight=height}) = height

rectWidth (rect @ (Pts {})) = ptsRectWidth rect
rectWidth (rect @ (Pwh {})) = pwhRectWidth rect

rectHeight (rect @ (Pts {})) = ptsRectHeight rect
rectHeight (rect @ (Pwh {})) = pwhRectHeight rect


-- 2.1.3 Introduction to Data Abstraction - What is meant by data?

section_2_1_3 = do
   -- Exercise 2.5
   print (cons3 1 2)
   print (car3 (cons3 1 2))
   print (cdr3 (cons3 1 2))

data Dispatch = Car | Cdr
data Pair a b = Lft a | Rgt b

cons1 x y =
   let
      dispatch Car = Lft x
      dispatch Cdr = Rgt y
   in
      dispatch

car1 z =
   case z Car of
      Lft c -> c
      _ -> error "Domain"
cdr1 z =
   case z Cdr of
      Rgt c -> c
      _ -> error "Domain"

-- Exercise 2.4
cons2 x y =
   \m -> m x y
car2 z =
   z (\p -> \q -> p)
cdr2 z =
   z (\p -> \q -> q)

-- Exercise 2.5
countPowers n d =
   let
      iter i pow =
         if i `mod` d == 0
            then iter (i `div` d) (pow+1)
            else pow
   in
      iter n 0
cons3 x y = (2^x) * (3^y)
car3 z = countPowers z 2
cdr3 z = countPowers z 3

-- Exercise 2.6
zero f x = x
add1 n f x = f (n f x)


-- 2.1.4 Introduction to Data Abstraction - Extended Exercise: Interval Arithmetic

section_2_1_4 = do
   -- Exercise 2.9
   print (width i + width j)

   -- width of the sum (or difference) of two intervals *is* a function only of the widths of the intervals being added (or subtracted)
   print (width (addInterval i j))
   print (width (subInterval i j))

   -- width of the product (or quotient) of two intervals *is not* a function only of the widths of the intervals being multiplied (or divided)
   print (width (mulInterval i j))
   print (width (divInterval i j))

   -- Exercise 2.14
   print (par1 r1 r2)
   print (par2 r1 r2)

   where
      i = makeInterval 5 10
      j = makeInterval 15 25

      r1 = makeCenterWidth 5 0.1
      r2 = makeCenterWidth 10 0.1

makeInterval a b = (a, b)
lowerBound (a, b) = a
upperBound (a, b) = b

addInterval x y =
   makeInterval (lowerBound x + lowerBound y)
                 (upperBound x + upperBound y)

mulInterval x y =
   let
      p1 = lowerBound x * lowerBound y
      p2 = lowerBound x * upperBound y
      p3 = upperBound x * lowerBound y
      p4 = upperBound x * upperBound y
   in
      makeInterval (min (min p1 p2) (min p3 p4))
                    (max (max p1 p2) (max p3 p4))

divInterval x y =
   let
      z = makeInterval (1 / (upperBound y))
                       (1 / (lowerBound y))
   in
      mulInterval x z

makeCenterWidth c w =
   makeInterval (c-w) (c+w)

center i =
   (lowerBound i + upperBound i) / 2

width i =
   (upperBound i - lowerBound i) / 2

-- Exercise 2.7
makeInterval' a b = [a, b]
lowerBound' [a, b] = a
upperBound' [a, b] = b

-- Exercise 2.8
subInterval x y =
   makeInterval (lowerBound x - upperBound y)
                (upperBound x - lowerBound y)
-- Exercise 2.10
isZeroInterval i =
   (lowerBound i == 0) || (upperBound i == 0)
divIntervalZeroCheck x y =
   if not (isZeroInterval y)
      then divInterval x y
      else error ("zero interval divisor")

-- Exercise 2.11
optMulInterval x y =
   let
      upperX = upperBound x
      lowerX = lowerBound x
      upperY = upperBound y
      lowerY = lowerBound y
   in
      case (upperX >= 0, lowerX >= 0, upperY >= 0, lowerY >= 0) of
         (True ,True ,True ,True ) -> makeInterval (lowerX*lowerY) (upperX*upperY)
         (True ,True ,True ,False) -> makeInterval (upperX*lowerY) (upperX*upperY)
         (True ,True ,False,False) -> makeInterval (upperX*lowerY) (lowerX*upperY)
         (True ,False,True ,True ) -> makeInterval (upperY*lowerX) (upperY*upperX)
         (True ,False,False,False) -> makeInterval (upperX*lowerY) (lowerX*lowerY)
         (False,False,True ,True ) -> makeInterval (lowerX*upperY) (lowerY*upperX)
         (False,False,True ,False) -> makeInterval (lowerX*upperY) (lowerY*lowerX)
         (False,False,False,False) -> makeInterval (upperX*upperY) (lowerY*lowerX)
         (True ,False,True ,False) ->
            let
               p1 = lowerBound x * lowerBound y
               p2 = lowerBound x * upperBound y
               p3 = upperBound x * lowerBound y
               p4 = upperBound x * upperBound y
            in
               makeInterval (min (min p1 p2) (min p3 p4))
                             (max (max p1 p2) (max p3 p4))

-- Exercise 2.12
makeCenterPercent c p =
   makeCenterWidth c (abs (p * c) / 100)
percent i =
   100 * width i / abs (center i)

-- Exercise 2.14
-- parallel resistors
par1 r1 r2 =
   divInterval (mulInterval r1 r2)
               (addInterval r1 r2)

par2 r1 r2 =
   let
      one = makeInterval 1 1
   in
      divInterval
         one
         (addInterval (divInterval one r1)
                      (divInterval one r2))


-- 2.2.1 Hierarchical Data and the Closure Property - Representing Sequences

section_2_2_1 = do
   print (1:2:3:4:[])
   print (oneThroughFour)
   print (head oneThroughFour)
   print (head (tail oneThroughFour))
   print (10 : oneThroughFour)
   print (5 : oneThroughFour)

   print (listRef squares 3)

   print (length' odds)
   print (length'' odds)

   print (append squares odds)
   print (append odds squares)

   print (scaleList 10 [1, 2, 3, 4, 5])
   print (map' abs [-10, 2.5, -11.6, 17])
   print (map' (\x -> x*x) [1, 2, 3, 4])
   print (scaleList' 10 [1, 2, 3, 4, 5])

   -- Exercise 2.17
   print (lastPair [23, 72, 149, 34])

   -- Exercise 2.18
   print (reverse_1 [1, 4, 9, 16, 25])
   print (reverse_2 [1, 4, 9, 16, 25])

   -- Exercise 2.19
   print (cc 100 usCoins)
   -- this one takes a while
   -- print (cc 100 ukCoins)

   -- Exercise 2.20
   print (sameParity [1, 2, 3, 4, 5, 6, 7])
   print (sameParity [2, 3, 4, 5, 6, 7])

   -- Exercise 2.21
   print (squareList_1 [1, 2, 3, 4])
   print (squareList_2 [1, 2, 3, 4])

   -- Exercise 2.22
   print (squareList_3 [1, 2, 3, 4])
   print (squareList_4 [1, 2, 3, 4])
   print (squareList_5 [1, 2, 3, 4])

   -- Exercise 2.23
   forEach [57, 321, 88] (\x -> print x)

   where
      oneThroughFour = [1, 2, 3, 4]
      squares = [1, 4, 9, 16, 25]
      odds = [1, 3, 5, 7]
      usCoins = [50, 25, 10, 5, 1]
      ukCoins = [100, 50, 20, 10, 5, 2, 1, 0.5]

listRef (x:xs) 0 = x
listRef (x:xs) n = listRef xs (n-1)

length' [] = 0
length' (x:xs) = 1 + length' xs

length'' items =
   let
      lengthIter [] count = count
      lengthIter (x:xs) count  = lengthIter xs (1+count)
   in
      lengthIter items 0

append [] list2 = list2
append (x:xs) list2 = x : (append xs list2)

-- Mapping over lists
scaleList factor [] = []
scaleList factor (x:xs) = (x * factor) : (scaleList factor xs)

map' proc [] = [];
map' proc (x:xs) = (proc x) : (map' proc xs)

scaleList' factor items =
   map' (\x -> x * factor) items

-- not sure how to translate these to Haskell?
--    (map + (list 1 2 3) (list 40 50 60) (list 700 800 900))
--    (map (lambda (x y) (+ x ( * 2 y))) (list 1 2 3) (list 4 5 6))
map (\(x,y) -> x + 2*y) $ zip [1,2,3] [4,5,6]

-- Exercise 2.17
lastPair [] = []
lastPair (xs @ [x]) = xs
lastPair (x:xs) = lastPair xs

-- Exercise 2.18
reverse_1 [] = []
reverse_1 (x:xs) = append (reverse_1 xs) [x]

reverse_2 items =
   let
      reverseIter [] accum    = accum
      reverseIter (x:xs) accum = reverseIter xs (x:accum)
   in
      reverseIter items []

-- Exercise 2.19
noMore [] = True
noMore coinValues = False

exceptFirstDenomination coinValues = tail coinValues

firstDenomination coinValues = head coinValues

cc 0 coinValues = 1
cc amount coinValues =
   if amount < 0 || noMore coinValues
      then 0
      else
         (cc amount (exceptFirstDenomination coinValues)) +
         (cc (amount - (firstDenomination coinValues)) coinValues)

-- Exercise 2.20
filter_1 predicate [] = []
filter_1 predicate (x:xs) =
   if predicate x
      then x : (filter_1 predicate xs)
      else filter_1 predicate xs
isOdd n = n `mod` 2 == 1
isEven n = not (isOdd n)
sameParity items =
   let
      predicate =
         if isOdd (head items)
            then isOdd
            else isEven
   in
      filter_1 predicate (tail items)

-- Exercise 2.21
squareList_1 [] = []
squareList_1 (x:xs) = (x*x):(squareList_1 xs)
squareList_2 (items) =
   map' (\x -> x*x) items

-- Exercise 2.22
squareList_3 items =
   let
      iter [] answer = answer
      iter (x:xs) answer = iter xs ((square x):answer)
   in
      iter items []
squareList_4 items =
   let
      iter [] answer = answer
      iter (x:xs) answer = iter xs (answer ++ [square x])
   in
      iter items []
squareList_5 items =
   let
      iter [] answer = answer
      iter (x:xs) answer = iter xs ((square x):answer)
   in
      reverse (iter items [])

-- Exercise 2.23
forEach [] f = do
   return ()
forEach (x:xs) f = do
   f x
   forEach xs f


-- 2.2.2 Hierarchical Data and the Closure Property - Hierarchical Structures

data NestedList a = Leaf a
                  | Node [NestedList a]
     deriving (Eq, Show)

section_2_2_2 = do
   print (x)
   print (lengthTree x)
   print (countLeaves x)

   print (Node [x, x])
   print (lengthTree (Node [x, x]))
   print (countLeaves (Node [x, x]))

   print (scaleTree 10 (Node [Leaf 1, Node [Leaf 2, Node [Leaf 3, Leaf 4], Leaf 5], Node [Leaf 6, Leaf 7]]))
   print (scaleTree' 10 (Node [Leaf 1, Node [Leaf 2, Node [Leaf 3, Leaf 4], Leaf 5], Node [Leaf 6, Leaf 7]]))

   -- Exercise 2.24
   print (Node [Leaf 1, Node [Leaf 2, Node [Leaf 3, Leaf 4]]])

   -- Exercise 2.25
   print (Node [Leaf 1, Leaf 3, Node [Leaf 5, Leaf 7], Leaf 9])
   print (Node [Node [Leaf 7]])
   print (Node [Leaf 1, Node [Leaf 2, Node [Leaf 3, Node [Leaf 4, Node [Leaf 5, Node [Leaf 6, Leaf 7]]]]]])

   -- Exercise 2.26
   print (appendTree x' y')
   print (Node [x', Node [y']])
   print (Node [x', y'])

   -- Exercise 2.27
   print (reverse' x)
   print (deepReverse x)

   -- Exercise 2.28
   print (fringe x)
   print (fringe (Node [x, x]))

   -- Exercise 2.29
   print ((show (totalWeight m1)) ++ " " ++ (show (totalWeight m2)))
   print ((show (isMobileBalanced m1)) ++ " " ++ (show (isMobileBalanced m2)))

   -- Exercise 2.30
   print (squareTree
            (Node [Leaf 1,
               Node [Leaf 2, Node [Leaf 3, Leaf 4], Leaf 5],
               Node [Leaf 6, Leaf 7]]))
   print (squareTree'
            (Node [Leaf 1,
               Node [Leaf 2, Node [Leaf 3, Leaf 4], Leaf 5],
               Node [Leaf 6, Leaf 7]]))

   -- Exercise 2.31
   print (squareTree''
            (Node [Leaf 1,
               Node [Leaf 2, Node [Leaf 3, Leaf 4], Leaf 5],
               Node [Leaf 6, Leaf 7]]))

   -- Exercise 2.32
   print (subsets [1, 2, 3])

   where
      x = Node [Node [Leaf 1, Leaf 2], Node [Leaf 3, Leaf 4]]
      x' = Node [Leaf 1, Leaf 2, Leaf 3]
      y' = Node [Leaf 4, Leaf 5, Leaf 6]

      m1 = makeMobile (makeBranch 10 (makeWeight 100))
                      (makeBranch 10 (makeMobile (makeBranch 40 (makeWeight 20))
                                                 (makeBranch 10 (makeWeight 80))))

      m2 = Mobile {mleft =Branch {mlen=10, mstruct=Weight {mweight=100}},
                   mright=Branch {mlen=10, mstruct=Mobile {mleft =Branch {mlen=40, mstruct=Weight {mweight=20}},
                                                           mright=Branch {mlen=10, mstruct=Weight {mweight=80}}}}}

lengthTree (Node x) = length x
lengthTree (Leaf x) = 1

countLeaves (Leaf x)  = 1
countLeaves (Node []) = 0
countLeaves (Node (x:xs)) = countLeaves x + countLeaves (Node xs)

-- Mapping over trees
scaleTree factor (Leaf x)  = Leaf (x * factor)
scaleTree factor (Node []) = Node []
scaleTree factor (Node (x:xs)) =
  let
     a = scaleTree factor (Node xs)
     b = case a of
            Node c -> c
            Leaf c -> [Leaf c]
  in
     Node ((scaleTree factor x) : b)

scaleTree' factor (Leaf x) = Leaf (x * factor)
scaleTree' factor (Node x) =
  Node (map' (\a -> scaleTree' factor a) x)

-- Exercise 2.26
appendTree (Node x) (Leaf y) = Node (x ++ [Leaf y])
appendTree (Leaf x) (Node y) = Node (Leaf x:y)
appendTree (Node x) (Node y) = Node (x ++ y)
appendTree (Leaf x) (Leaf y) = Node [Leaf x, Leaf y]

-- Exercise 2.27
reverse' (Leaf x)  = Leaf x
reverse' (Node xs) = Node (reverse xs)
deepReverse (Leaf x)  = Leaf x
deepReverse (Node xs) = Node (reverse (map' deepReverse xs))

-- Exercise 2.28
fringe (Leaf x)  = [x]
fringe (Node []) = []
fringe (Node (x:xs)) = fringe x ++ fringe (Node xs)

-- Exercise 2.29

data Mobile a = Mobile {mleft::Mobile a, mright::Mobile a}
              | Branch {mlen::Int, mstruct::Mobile a}
              | Weight {mweight::a}
     deriving (Eq, Show)

-- Record-based representation
-- a.
makeMobile left right = Mobile {mleft=left, mright=right}
makeBranch len struct = Branch {mlen=len, mstruct=struct}
makeWeight weight = Weight {mweight=weight}

leftBranch (Mobile {mleft=left, mright=right}) = left
rightBranch (Mobile {mleft=left, mright=right}) = right
branchLength (Branch {mlen=len, mstruct=struct}) = len
brancStruct (Branch {mlen=len, mstruct=struct}) = struct

-- helpers for b. and c.
branchWeight (Mobile {mleft=left, mright=right}) = branchWeight left + branchWeight right
branchWeight (Branch {mlen=len, mstruct=struct}) = branchWeight struct
branchWeight (Weight {mweight=weight}) = weight

-- b.
totalWeight mobile =
   branchWeight mobile

-- c.
isMobileBalanced (Mobile {mleft=left, mright=right}) =
   let
      lmwl = branchLength left * branchWeight left
      rmwl = branchLength right * branchWeight right
   in
      lmwl == rmwl &&  isMobileBalanced left && isMobileBalanced right
isMobileBalanced (Branch {mlen=_, mstruct=struct}) = isMobileBalanced struct
isMobileBalanced _ = True

-- Exercise 2.30
nodeList (Node xs) = xs
squareTree (Leaf x)  = Leaf (x*x)
squareTree (Node []) = Node []
squareTree (Node (x:xs)) = Node ((squareTree' x) : nodeList (squareTree' (Node xs)))

squareTree' (Leaf x)  = Leaf (x*x)
squareTree' (Node xs) = Node (map' squareTree' xs);

-- Exercise 2.31
treeMap proc (Leaf x)  = Leaf (proc x)
treeMap proc (Node xs) = Node (map' (treeMap proc) xs)
squareTree'' tree = treeMap square tree

-- Exercise 2.32
subsets [] = [[]]
subsets (x:xs) =
  let
     rest = subsets xs
  in
     rest ++ map' (\y -> x:y) rest


-- 2.2.3 Hierarchical Data and the Closure Property - Sequences as Conventional Interfaces

data EmployeeData = Employee {name::String, jobtitle::String, salary::Int}

section_2_2_3 = do
   print (sumOddSquares (Node [Leaf 1, Node [Leaf 2, Node [Leaf 3, Leaf 4, Leaf 5]]]))

   -- Sequence operations
   print (map' square [1,2,3,4,5])

   print (filter isOdd [1,2,3,4,5])
   print (filter isOdd [1,2,3,4,5])

   print (accumulate (+) 0 [1,2,3,4,5])
   print (accumulate (*) 1 [1,2,3,4,5])
   print (accumulate (:) [] [1,2,3,4,5])

   print (enumerateInterval 2 7)
   print (enumerateTree (Node [Leaf 1, Node [Leaf 2, Node [Leaf 3, Leaf 4], Leaf 5]]))
   print (sumOddSquares' (Node [Leaf 1, Node [Leaf 2, Node [Leaf 3, Leaf 4], Leaf 5]]))
   print (evenFibs' 10)
   print (listFibSquares 10)
   print (productOfSquaresOfOddElements [1,2,3,4,5])

   print (salaryOfHighestPaidProgrammer recs)

   -- Nested mappings
   print (
      accumulate
         (++)
         []
         (map'
            (\i -> map'
               (\j -> [i, j])
               (enumerateInterval 1 (i-1)))
            (enumerateInterval 1 n)))

   -- Exercise 2.34
   print (hornerEval 2 [1,3,0,5,0,1])

   -- Exercise 2.35
   print (countLeaves' x)

   -- Exercise 2.36
   print (accumulateN (+) 0 [[1,2,3],[4,5,6],[7,8,9],[10,11,12]])

   -- Exercise 2.37
   -- To Be Done???
   -- print (extendedMap (+) ([1 2 3],[40 50 60],[700 800 900]))
   -- print (dotProduct [[1,2,3,4],[4,5,6,6],[6,7,8,9]],[1,1,1,1])

   -- Exercise 2.38
   print (foldRight (/) 1 [1,2,3])
   print (foldLeft  (/) 1 [1,2,3])
   print (foldRight (:) [] [1,2,3])
   -- CMR Error - won't compile - Scheme result = (((() 1) 2) 3)
   -- print (foldLeft (:) [] [1,2,3])

   -- Exercise 2.39
   print (reverseR [1,2,3,4])
   print (reverseL [1,2,3,4])

   -- Exercise 2.41
   print (triplesSums 10 5)

   -- Exercise 2.42
   print (queens 4)

   -- Exercise 2.43
   print (queens' 4)

   where
      x = Node [Node [Leaf 1, Leaf 2], Node [Leaf 3, Leaf 4]]
      recs = [Employee {name="Fred", jobtitle="Programmer", salary=180},
              Employee {name="Hank", jobtitle="Programmer", salary=150}]
      n = 10      -- book doesn't define n

-- same as above
-- isOdd n = n `mod` 2 == 1
-- isEven n = not (isOdd n)
-- square x = x * x

sumOddSquares (Node []) = 0
sumOddSquares (Node (x:xs)) =
  sumOddSquares x + sumOddSquares (Node xs)
sumOddSquares (Leaf x) =
  if isOdd x
     then square x
     else 0

evenFibs n =
   let
      next k =
         if k > n
            then []
            else
               let
                  f = fib k
               in
                  if isEven f
                     then f:next (k+1)
                     else next (k+1)
   in
      next 0

-- Sequence operations
filter' predicate [] = []
filter' predicate (x:xs) =
  if predicate x
     then x : filter' predicate xs
     else filter' predicate xs

accumulate oper initial [] = initial
accumulate oper initial (x:xs) =
  oper x (accumulate oper initial xs)

enumerateInterval low high =
   if low > high
      then []
      else low : (enumerateInterval (low+1) high)

enumerateTree (Node []) = []
enumerateTree (Leaf x)  = [x]
enumerateTree (Node (x:xs)) =
  enumerateTree x ++ enumerateTree (Node xs)

sumOddSquares' tree =
   accumulate (+) 0 (map' square (filter' isOdd (enumerateTree tree)))

evenFibs' n =
   accumulate (:) [] (filter' isEven (map' fib (enumerateInterval 0 n)))

listFibSquares n =
   accumulate (:) [] (map' square (map' fib (enumerateInterval 0 n)))

productOfSquaresOfOddElements seqs =
   accumulate (*) 1 (map' square (filter' isOdd seqs))

isProgrammer (Employee {name=_, jobtitle=jobtitle, salary=_}) = (jobtitle == "Programmer")
empsalary (Employee {name=_, jobtitle=_, salary=salary}) = salary
salaryOfHighestPaidProgrammer records =
   accumulate max 0 (map' empsalary (filter' isProgrammer records))

-- Nested mappings
flatmap proc seqs =
   accumulate (++) [] (map' proc seqs)

hasNoDivisors n 1 = True
hasNoDivisors n c =
  if n `mod` c == 0
     then False
     else hasNoDivisors n (c-1)

isPrime n = hasNoDivisors n (n-1)

primeSum (x, y) = isPrime (x + y)

makePairSum x y = (x, y, x+y)

primeSumPairs n =
   map'
      makePairSum
      (filter'
         primeSum
         (flatmap
            (\i -> map'
               (\j -> (i, j))
               (enumerateInterval 1 (i-1)))
            (enumerateInterval 1 n)))

remove item seqs =
   filter' (\x -> not (x == item)) seqs

permutations [] = [[]]
permutations s =
  flatmap
     (\x -> map'
        (\p -> x:p)
        (permutations (remove x s)))
     s

-- Exercise 2.33
map2 proc seqs =
   accumulate (\a -> \b -> (proc a) : b) [] seqs
append'' seq1 seq2 =
   accumulate (:) seq2 seq1
length''' seqs =
   accumulate (+) 0 seqs

-- Exercise 2.34
hornerEval c coefficientSequence =
   accumulate (\thisCoeff -> \higherTerms -> c*higherTerms + thisCoeff) 0 coefficientSequence

-- Exercise 2.35
countLeaves' tree =
   accumulate (+) 0 (map' (\x -> 1) (enumerateTree tree))

-- Exercise 2.36
accumulateN oper init ([]:_) = []
accumulateN oper init seqs =
   (accumulate oper init (map head seqs)) :
      (accumulateN oper init (map tail seqs))

-- Exercise 2.37
-- To Be Done???  (This is all wrong)
-- extendedMap proc (x:xs, y:ys) = (proc x y) : (extendedMap proc (xs, ys))
-- dotProduct v w =
--    accumulateN (map (\x -> extendedMap (*) (x, w)) v) 0
-- matrixTimesVector m v =
--    map (\row -> dotProduct row v) m
-- transpose m =
--    accumulateN (:) [] m
-- matrixTimesMatrix m n =
--    let
--       cols = transpose n
--    in
--       map (\row -> matrixTimesVector cols row) m

-- Exercise 2.38
foldRight = accumulate
foldLeft oper initial seqs =
   let
      iter result [] = result
      iter result (x:xs) = iter (oper result x) xs
   in
      iter initial seqs

-- Exercise 2.39
reverseR seq =
   foldRight (\x -> \y -> y ++ [x]) [] seq
reverseL seq =
   foldLeft (\x -> \y -> y : x) [] seq

-- Exercise 2.40
uniquePairs n =
   flatmap (\i -> map (\j -> (i, j)) (enumerateInterval 1 (i-1)))
           (enumerateInterval 1 n)
primeSumPairs' n =
   map makePairSum (filter primeSum (uniquePairs n))

-- Exercise 2.41
uniqueTriples n =
   flatmap
      (\i -> flatmap (\j -> map (\k -> [i, j, k]) (enumerateInterval 1 (j-1)))
                     (enumerateInterval 1 (i-1)))
      (enumerateInterval 1 n)
triplesSums sumsTo n =
   filter (\triple -> (accumulate (+) 0 triple) == sumsTo)
          (uniqueTriples n)

-- Exercise 2.42
queens boardSize =
   let
      queenCols 0 = [emptyBoard]
      queenCols k =
        filter'
           (\positions -> isSafe k positions)
           (flatmap
              (\restOfQueens -> map' (\newRow -> adjoinPosition newRow k restOfQueens)
                                     (enumerateInterval 1 boardSize))
              (queenCols (k-1)))
   in
      queenCols boardSize

emptyBoard = []

adjoinPosition newrow k [] = [(k, newrow)]
adjoinPosition newrow k restOfQueens = (k, newrow):restOfQueens

removeTargetColumn column board =
   filter' (\x -> fst x /= column) board

getTargetColumn column board =
   head (filter (\x -> fst x == column) board)

isCheck pos1 pos2 =
   let
      (h1, t1) = pos1
      (h2, t2) = pos2
   in
      if h1 == h2
         then True
         else
            if t1 == t2
               then True
               else
                  if abs (h1-h2) == abs (t1-t2)
                     then True
                     else False

boardChecks pos [] = True
boardChecks pos (x:xs) =
   if isCheck pos x
      then False
      else boardChecks pos xs

isSafe x y =
   boardChecks (getTargetColumn x y) (removeTargetColumn x y)

-- Exercise 2.43
queens' boardSize =
   let
      queenCols 0 = [emptyBoard]
      queenCols k =
        filter'
           (\positions -> isSafe k positions)
           (flatmap
              (\newRow -> map'
                 (\restOfQueens -> adjoinPosition newRow k restOfQueens)
                 (queenCols (k-1)))
              (enumerateInterval 1 boardSize))
   in
      queenCols boardSize


-- 2.2.4 Hierarchical Data and the Closure Property - Example: a picture language

section_2_2_4 = do
   dc <- dcInitialize "fred.txt"
   postscript dc (wave dc)
   postscript dc (wave2 dc)
   postscript dc (wave4 dc)
   postscript dc (wave4' dc)

   -- Exercise 2.44
   postscript dc (upSplit (wave dc) 4)

   -- Exercise 2.45
   postscript dc (upSplit' (wave dc) 4)
   postscript dc (rightSplit' (wave dc) 4)

   -- Exercise 2.49
   postscript dc (below (beside (outline dc) (xxx dc)) (beside (diamond dc) (wave dc)))

   -- Exercise 2.52
   postscript dc (squareLimit (wave dc) 4)

-- drawing primitives - output a postscript file
dcInitialize fname = do
   postscriptPageIndex <- newMVar (0::Int)
   inh <- openFile "/alice/picture-lang.ps" WriteMode
   hPutStrLn inh "%!PS-Adobe-3.0"
   hPutStrLn inh "%%Pages: 9\n"                   -- note: I'm hard coding the number of postscript pages (9) that are generated below.
   return (inh, postscriptPageIndex)

dcClose dc =
   hClose (dc dcGetHandle)

dcGetHandle (inh, _) =
   return inh

dcGetPostscriptPageIndex (_, postscriptPageIndex) =
   (takeMVar postscriptPageIndex) >>= return

dcSetPostscriptPageIndex (_, postscriptPageIndex) n =
   (putMVar postscriptPageIndex n) >>= return

dcIncPostscriptPageIndex dc = do
   n <- dcGetPostscriptPageIndex dc
   dcSetPostscriptPageIndex dc (n+1)
   return (n+1)

postscript dc wave = do
   n <- dcIncPostscriptPageIndex dc
   inh <- dcGetHandle dc
   hPutStr inh ("%%Page: ")
   hPutStr inh (show n)
   hPutStr inh " "
   hPutStr inh (show n)
   hPutStr inh "\n"
   hPutStr inh "/inch {72 8 mul mul} def\n"
   wave (makeFrame (makeVect 0.0 0.0)  (makeVect 1.0 0.0) (makeVect 0.0 1.0))
   hPutStr inh "showpage\n"
   hPutStr inh "\n"

drawLine dc x y = do
   inh <- dcGetHandle dc
   hPutStr inh "newpath\n"
   case (x, y) of
      (Vect {x=x0, y=y0}, Vect {x=x1, y=y1}) ->
         hPutStrLn inh ((show x0) ++ " inch " ++ (show y0) ++ " inch moveto") >>
         hPutStrLn inh ((show x1) ++ " inch " ++ (show y1) ++ " inch lineto")
   hPutStr inh "closepath\n"
   hPutStr inh "stroke\n"

wave dc xframe =
   let
      segs = [makeSegment'' (makeVect 0.40 1.00) (makeVect 0.35 0.80),
              makeSegment'' (makeVect 0.35 0.80) (makeVect 0.40 0.60),
              makeSegment'' (makeVect 0.40 0.60) (makeVect 0.30 0.60),
              makeSegment'' (makeVect 0.30 0.60) (makeVect 0.20 0.55),
              makeSegment'' (makeVect 0.20 0.55) (makeVect 0.00 0.80),
              makeSegment'' (makeVect 0.00 0.60) (makeVect 0.20 0.45),
              makeSegment'' (makeVect 0.20 0.45) (makeVect 0.30 0.55),
              makeSegment'' (makeVect 0.30 0.55) (makeVect 0.35 0.50),
              makeSegment'' (makeVect 0.35 0.50) (makeVect 0.25 0.00),
              makeSegment'' (makeVect 0.40 0.00) (makeVect 0.50 0.20),
              makeSegment'' (makeVect 0.50 0.20) (makeVect 0.60 0.00),
              makeSegment'' (makeVect 0.75 0.00) (makeVect 0.65 0.50),
              makeSegment'' (makeVect 0.65 0.50) (makeVect 1.00 0.20),
              makeSegment'' (makeVect 1.00 0.40) (makeVect 0.70 0.60),
              makeSegment'' (makeVect 0.70 0.60) (makeVect 0.60 0.60),
              makeSegment'' (makeVect 0.60 0.60) (makeVect 0.65 0.80),
              makeSegment'' (makeVect 0.65 0.80) (makeVect 0.60 1.00)]
   in
      (segmentsPainter dc segs) xframe

data Vector = Vect {x::Float, y::Float}
makeVect x y = Vect {x=x, y=y}
xcorVect (Vect {x=x, y=y}) = x
ycorVect (Vect {x=x, y=y}) = y
addVect v1 v2 = makeVect (xcorVect v1 + xcorVect v2) (ycorVect v1 + ycorVect v2)
subVect v1 v2 = makeVect (xcorVect v1 - xcorVect v2) (ycorVect v1 - ycorVect v2)
scaleVect s v = makeVect (s * xcorVect v) (s * ycorVect v)

data FrameData = Frame {origin::Vector, edge1::Vector, edge2::Vector}
makeFrame origin edge1 edge2 = Frame {origin=origin, edge1=edge1, edge2=edge2}
originFrame (Frame {origin=origin, edge1=edge1, edge2=edge2}) = origin
edge1Frame (Frame {origin=origin, edge1=edge1, edge2=edge2}) = edge1
edge2Frame (Frame {origin=origin, edge1=edge1, edge2=edge2}) = edge2
aFrame = makeFrame (makeVect 0 0) (makeVect 1 0) (makeVect 0 1)

data SegmentData a = Segment {xs::a, ys::a}
makeSegment'' startSegment endSegment = Segment {xs=startSegment, ys=endSegment}
startSegment'' (Segment {xs=xs, ys=ys}) = xs
endSegment'' (Segment {xs=xs, ys=ys}) = ys

-- Frames
frameCoordMap xframe v =
    addVect
      (originFrame xframe)
      (addVect (scaleVect (xcorVect v) (edge1Frame xframe))
               (scaleVect (ycorVect v) (edge2Frame xframe)))

_ = frameCoordMap aFrame (makeVect 0 0)
_ = originFrame aFrame

-- Painters
foreach f [] = do
   return ()
foreach f (x:xs) = do
   f x
   foreach f xs

-- a for loop for grins (via CTM)
for a b s f =
   let
      loopup c | c <= b = do
         f c
         loopup (c+s)
      loopup c = do
         return ()
      loopdown c | c >= b = do
         f c
         loopdown (c+s)
      loopdown c = do
         return ()
   in
      if s > 0
         then loopup a
         else
            if s < 0
               then loopdown a
               else return ()

segmentsPainter dc segmentList xframe = do
   foreach
      (\segment ->
         drawLine
            dc
            (frameCoordMap xframe (startSegment'' segment))
            (frameCoordMap xframe (endSegment'' segment)))
      segmentList

transformPainter painter origin corner1 corner2 xframe =
   let
      m = frameCoordMap xframe
      newOrigin = m origin
   in
      painter
         (makeFrame
            newOrigin
            (subVect (m corner1) newOrigin)
            (subVect (m corner2) newOrigin))

flipVert painter =
   transformPainter
      painter
      (makeVect 0 1)
      (makeVect 1 1)
      (makeVect 0 0)

shrinkToUpperRight painter =
   transformPainter
      painter
      (makeVect 0.5 0.5)
      (makeVect 1 0.5)
      (makeVect 0.5 1)

rotate90 painter =
   transformPainter
      painter
      (makeVect 1 0)
      (makeVect 1 1)
      (makeVect 0 0)

squashInwards painter =
   transformPainter
      painter
      (makeVect 0 0)
      (makeVect 0.65 0.35)
      (makeVect 0.35 0.65)

beside painter1 painter2 xframe =
   let
      splitPoint = makeVect 0.5 0
      paintLeft =
         transformPainter
            painter1
            (makeVect 0 0)
            splitPoint
            (makeVect 0 1)
      paintRight =
         transformPainter
            painter2
            splitPoint
            (makeVect 1 0)
            (makeVect 0.5 1)
   in do
      paintLeft xframe
      paintRight xframe

below painter1 painter2 xframe =
   let
      splitPoint = makeVect 0 0.5
      paintBelow =
         transformPainter
            painter1
            (makeVect 0 0)
            (makeVect 1 0)
            splitPoint
      paintAbove =
         transformPainter
            painter2
            splitPoint
            (makeVect 1 0.5)
            (makeVect 0 1)
   in do
      paintBelow xframe
      paintAbove xframe

wave2 dc = beside (wave dc) (flipVert (wave dc))

wave4 dc = below (wave2 dc) (wave dc)

flippedPairs painter =
   let
      painter2 = beside painter (flipVert painter)
   in
      below painter2 painter2

wave4' dc = flippedPairs (wave dc)

rightSplit painter n =
   if n == 0
      then painter
      else
         let
            smaller = rightSplit painter (n-1)
         in
            beside painter (below smaller smaller)

cornerSplit painter n =
   if n == 0
      then painter
      else
         let
            up = upSplit painter (n-1)
            right = rightSplit painter (n-1)
            topLeft = beside up up
            bottomRight = below right right
            corner = cornerSplit painter (n-1)
         in
            beside (below painter topLeft) (below bottomRight corner)

squareLimit painter n =
   let
      quarter = cornerSplit painter n
      half = beside (flipHoriz quarter) quarter
   in
      below (flipVert half) half

-- HigherOrder operations
squareOfFour tleft tright bleft bright =
   \painter ->
      let
         top = beside (tleft painter) (tright painter)
         bottom = beside (bleft painter) (bright painter)
      in
         below bottom top

flippedPairs' painter =
   let
      combine4 = squareOfFour identity flipVert identity flipVert
   in
      combine4 painter

-- footnote
-- ??? flippedPairs'' = squareOfFour identity flipVert identity flipVert

squareLimit' painter n =
   let
      combine4 = squareOfFour flipHoriz identity rotate180 flipVert
   in
      combine4 (cornerSplit painter n)

-- Exercise 2.44
upSplit painter n =
   if n == 0
      then painter
      else
         let
            smaller = upSplit painter (n-1)
         in
            below painter (beside smaller smaller)

-- Exercise 2.45
rightSplit' = split beside below
upSplit' = split below beside
split combineMain combineSmaller painter n =
   if n == 0
      then painter
      else
         let
            smaller = (split combineMain combineSmaller) painter (n-1)
         in
            combineMain painter (combineSmaller smaller smaller)

-- Exercise 2.46
makeVect' x y = (x, y)
xcorVect' v = fst v
ycorVect' v = snd v
addVect' v1 v2 = makeVect' (xcorVect' v1 + xcorVect' v2) (ycorVect' v1 + ycorVect' v2)
subVect' v1 v2 = makeVect' (xcorVect' v1 - xcorVect' v2) (ycorVect' v1 - ycorVect' v2)
scaleVect' s v = makeVect' (s * xcorVect' v) (s * ycorVect' v)

-- Exercise 2.47
makeFrame' origin edge1 edge2 = [origin, edge1, edge2]
makeFrame'' origin edge1 edge2 = [origin, [edge1, edge2]]
originFrame' f = head f
edge1Frame' f = head . tail $ f
edge2Frame' f = head . tail . tail $ f

originFrame'' f = head f
edge1Frame'' f = head . tail $ f
edge2Frame'' f = head . tail . tail $ f

-- Exercise 2.48
makeSegment''' vStart vEnd = (vStart, vEnd)
startSegment''' s = fst s
endSegment''' s = snd s

-- Exercise 2.49
outline dc xFrame =
   let
      segs = [makeSegment'' (makeVect 0 0) (makeVect 0 1),
              makeSegment'' (makeVect 0 0) (makeVect 1 0),
              makeSegment'' (makeVect 1 0) (makeVect 1 1),
              makeSegment'' (makeVect 0 1) (makeVect 1 1)]
   in
      (segmentsPainter dc  segs) xFrame

xxx dc xFrame =
   let
      segs = [makeSegment'' (makeVect 1.0 0.0) (makeVect 0.0 1.0),
              makeSegment'' (makeVect 0.0 0.0) (makeVect 1.0 1.0)]
   in
      (segmentsPainter dc segs) xFrame

diamond dc xFrame =
   let
      segs = [makeSegment'' (makeVect 0.5 0.0) (makeVect 1.0 0.5),
              makeSegment'' (makeVect 1.0 0.5) (makeVect 0.5 1.0),
              makeSegment'' (makeVect 0.0 0.5) (makeVect 0.5 0.0),
              makeSegment'' (makeVect 0.0 0.5) (makeVect 0.5 1.0)]
   in
      (segmentsPainter dc segs) xFrame

-- Exercise 2.50
flipHoriz painter =
   transformPainter
      painter
      (makeVect 1 0)
      (makeVect 0 0)
      (makeVect 1 1)

rotate180 painter =
   transformPainter
      painter
      (makeVect 1 1)
      (makeVect 0 1)
      (makeVect 1 0)

rotate270 painter =
   transformPainter
      painter
      (makeVect 1 0)
      (makeVect 1 1)
      (makeVect 0 1)

-- Exercise 2.51
belowRot painter1 painter2 =
   rotate90 (beside (rotate270 painter1) (rotate270 painter2))


-- 2.3.1 Symbolic Data - Quotation

-- To Be Done.
section_2_3_1 = do
   print ""


-- 2.3.2 Symbolic Data - Example: Symbolic Differentiation

data Term = Number Int
          | Variable Char
          | Sum (Term, Term)
          | Product (Term, Term)
          | Power (Term, Term)
     deriving (Eq, Show)

section_2_3_2 = do
   -- dx(x + 3) = 1
   print (deriv (Sum (Variable 'x', Number 3)) (Variable 'x'))

   -- dx(x*y) = y
   print (deriv (Product (Variable 'x', Variable 'y')) (Variable 'x'))

   -- dx(x*y + x + 3) = y + 1
   print (deriv (Sum (Sum (Product (Variable 'x', Variable 'y'), Variable 'x'), Number 3)) (Variable 'x'))

   -- dx(x + 3) = 1
   print (deriv' (Sum (Variable 'x', Number 3)) (Variable 'x'))

   -- dx(x*y) = y
   print (deriv' (Product (Variable 'x', Variable 'y')) (Variable 'x'))

   -- dx(x*y + x + 3) = y + 1
   print (deriv' (Sum (Sum (Product (Variable 'x', Variable 'y'), Variable 'x'), Number 3)) (Variable 'x'))

isNumber (Number x) = True
isNumber _ = False

isSameNumber (Number x) (Number y) = (x == y)
isSameNumber _ _ = False

isVariable (Variable x) = True
isVariable _ = False

isSameVariable (Variable x) (Variable y) = (x == y)
isSameVariable _ _ = False

isSum (Sum (x, y)) = True
isSum _ = False

isProduct (Product (x, y)) = True
isProduct _ = False

makeSum (Number x) (Number y) = Number (x + y)
makeSum x y = Sum (x, y)

makeProduct (Number x) (Number y) = Number (x * y)
makeProduct x y = Product (x, y)

addend (Sum (x, y)) = x
addend s = error ("a - Invalid pattern match " ++ (show s))

augend (Sum (x, y)) = y
augend s = error ("b - Invalid pattern match " ++ (show s))

multiplier (Product (x, y)) = x
multiplier s = error ("c - Invalid pattern match " ++ (show s))

multiplicand (Product (x, y)) = y
multiplicand s = error ("d - Invalid pattern match " ++ (show s))

deriv expx var =
   if isNumber expx
      then Number 0
      else
         if isVariable expx
            then
                if isSameVariable expx var
                   then Number 1
                   else Number 0
            else
               if isSum expx
                  then makeSum (deriv (addend expx) var) (deriv (augend expx) var)
                  else
                     if isProduct expx
                        then
                           makeSum (makeProduct (multiplier expx) (deriv (multiplicand expx) var))
                                   (makeProduct (deriv (multiplier expx) var) (multiplicand expx))
                        else error "Error"

-- With simplification
makeSum' (Number 0) y = y
makeSum' x (Number 0) = x
makeSum' (Number x) (Number y) = Number (x + y)
makeSum' x y = Sum (x, y)

makeProduct' (Number 0) y = Number 0
makeProduct' x (Number 0) = Number 0
makeProduct' (Number 1) y = y
makeProduct' x (Number 1) = x
makeProduct' (Number x) (Number y) = Number (x * y)
makeProduct' x y = Product (x, y)

deriv' (Number x) var = Number 0
deriv' (Variable x) (Variable y) | x == y = Number 1
deriv' (Variable x) _ = Number 0
deriv' (Sum (x, y)) var = makeSum' (deriv' x var) (deriv' y var)
deriv' (Product (x, y)) var = makeSum' (makeProduct' x (deriv' y var)) (makeProduct' (deriv' x var) y)

-- % Exercise 2.56
makeExponentiation base (Number 0) = Number 1
makeExponentiation base (Number 1) = base
makeExponentiation (Number x) (Number y) = Number ((x::Int) ^ y)
makeExponentiation base exp = Power (base, exp)

isExponentiation (Power (xx, y)) = True
isExponentiation _ = False

base (Power (x, y)) = x
base s = error ("e - Invalid pattern match " ++ (show s))

exponent (Power (x, y)) = y
exponent s = error ("f - Invalid pattern match " ++ (show s))

deriv'' (Number x) var = Number 0
deriv'' (Variable x) (Variable y) | x == y = Number 1
deriv'' (Variable x) _ = Number 0
deriv'' (Sum (x, y)) var = makeSum' (deriv'' x var) (deriv'' y var)
deriv'' (Product (x, y)) var = makeSum' (makeProduct' x (deriv'' y var)) (makeProduct' (deriv'' x var) y)
deriv'' (Power (x, y)) var = makeProduct' (makeProduct' y (makeExponentiation x (makeSum y (Number (-1)))))
                                          (deriv'' x var)

-- EXERCISE 2.57
-- dx(x*y*(x+3)) = dx(x*x*y + x*y*3) = 2xy + 3y
-- To Be Done

-- Exercise 2.58
-- To Be Done


-- 2.3.3 Symbolic Data - Example: Representing Sets

section_2_3_3 = do
   print (isElementOfSet 3 [1,2,3,4])

   print (adjoinSet' 3 (BTNode (4, BTNode (2, BTLeaf, BTLeaf), BTNode (6, BTLeaf, BTLeaf))))

   -- Exercise 2.59
   print (unionSet [3,1,2] [4,3,2,5])

   -- Exercise 2.60
   print (isElementOfMultiSet 3 [2,3,2,1,3,2,2])
   print (intersectionMultiSet [2,3,2,1,3,2,2] [4,2,3,2,5])
   print (adjoinMultiSet 5 [2,3,2,1,3,2,2])
   print (unionMultiSet [2,3,2,1,3,2,2] [4,2,3,2,5])

   -- Exercise 2.61
   print (adjoinSet'' 3 [2,4,6])

   -- Exercise 2.62
   print (unionSet' [1,2,3] [2,3,4,5])

   -- Exercise 2.63
   print (treeToList (BTNode (4, BTNode (2, BTLeaf, BTLeaf), BTNode (6, BTLeaf, BTLeaf))))
   print (treeToList' (BTNode (4, BTNode (2, BTLeaf, BTLeaf), BTNode (6, BTLeaf, BTLeaf))))

   -- Exercise 2.64
   print (listToTree [2,4,6])

-- unordered
isElementOfSet x [] = False
isElementOfSet x (y:ys) =
   if x == y
     then True
     else isElementOfSet x ys

adjoinSet x set =
   if isElementOfSet x set
      then set
      else x:set

intersectionSet [] set2 = []
intersectionSet set1 [] = []
intersectionSet (x:xs) set2 =
  if isElementOfSet x set2
     then x:intersectionSet xs set2
     else intersectionSet xs set2

-- ordered
isElementOfSet' x [] = False
isElementOfSet' x (y:ys) =
  if x == y
     then True
     else
        if x < y
           then False
           else isElementOfSet' x ys

intersectionSet' [] set2 = []
intersectionSet' set1 [] = []
intersectionSet' set1@(x:xs) set2@(y:ys) =
  if x == y
     then x:intersectionSet' xs ys
     else
        if x < y
           then intersectionSet' xs set2
           else intersectionSet' set1 ys

-- binary trees
data BTree a = BTLeaf
             | BTNode (a, BTree a, BTree a)
     deriving (Eq, Show)

isElementOfSetBtree x BTLeaf = False
isElementOfSetBtree x (BTNode (y, left, right)) =
  if x == y
     then True
     else
        if x < y
           then isElementOfSetBtree x left
           else isElementOfSetBtree x right

adjoinSet' x BTLeaf = BTNode (x, BTLeaf, BTLeaf)
adjoinSet' x set@(BTNode (y, left, right)) =
  if x == y
     then set
     else
        if x < y
           then BTNode (y, adjoinSet' x left, right)
           else BTNode (y, left, adjoinSet' x right)

-- information retrieval
data InformationData = Information {key::Int, namex::String, age::Int}

lookup' givenKey x@(Information {key=key, namex=namex, age=age}:xs) =
   if givenKey == key
      then x
      else lookup' givenKey xs
lookup' givenKey [] = error "Domain"

-- Exercise 2.59
unionSet set1 set2 =
   set1 ++ (filter (\x -> not (isElementOfSet x set1)) set2)

-- Exercise 2.60
isElementOfMultiSet x xs =
   isElementOfSet x xs

intersectionMultiSet (set1@(x:xs)) (set2@(y:ys)) =
   if isElementOfMultiSet x set2
      then x:(intersectionMultiSet xs set2)
      else intersectionMultiSet xs set2
intersectionMultiSet _ _ = []

adjoinMultiSet x set = x:set

unionMultiSet set1 set2 = set1 ++ set2

-- Exercise 2.61
adjoinSet'' x [] = [x]
adjoinSet'' x (set@(y:ys)) =
   if x == y
      then set
      else
         if x < y
            then x:set
            else y:(adjoinSet'' x ys)

-- Exercise 2.62
unionSet' set1 [] = set1
unionSet' [] set2 = set2
unionSet' (set1@(x:xs)) (set2@(y:ys)) =
   if x == y
      then x:(unionSet' xs ys)
      else
         if x < y
            then x:(unionSet' xs set2)
            else y:(unionSet' set1 ys)

-- Exercise 2.63
treeToList BTLeaf = []
treeToList (BTNode (y, left, right)) =
  (treeToList left) ++ (y:treeToList right)

treeToList' tree =
   let
      copyToList BTLeaf ys = ys
      copyToList (BTNode (x, left, right)) ys =
        copyToList left (x:copyToList right ys)
   in
      copyToList tree []

-- Exercise 2.64
partialTree elts 0 = (BTLeaf, elts)
partialTree elts n =
  let
     leftSize = (n - 1) `div` 2
     rightSize = n - (leftSize + 1)
     leftResult@(leftTree, nonLeftElts) = partialTree elts leftSize
     thisEntry = head nonLeftElts
     rightResult@(rightTree, remainingElts) = partialTree (tail nonLeftElts) rightSize
  in
     (BTNode (thisEntry, leftTree, rightTree), remainingElts)

listToTree elements =
   let
      (result, _) = partialTree elements (length elements)
   in
      result

-- Exercise 2.65
unionSetBinTree set1 set2 =
   listToTree (unionSet (treeToList' set1) (treeToList' set2))
intersectionSetBinTree set1 set2 =
   listToTree (intersectionSet (treeToList' set1) (treeToList' set2))

-- Exercise 2.66
-- To Be Done


-- 2.3.4 Symbolic Data - Example: Huffman Encoding Trees

section_2_3_4 = do
   -- Exercise 2.67
   print (decode sampleMessage sampleTree)

   -- Exercise 2.68
   print (decode (encode "ADABBCA" sampleTree) sampleTree)

   -- Exercise 2.69
   print (generateHuffmanTree [makeLeaf 'A' 8,
                               makeLeaf 'B' 3,
                               makeLeaf 'C' 1,
                               makeLeaf 'D' 1,
                               makeLeaf 'E' 1,
                               makeLeaf 'F' 1,
                               makeLeaf 'G' 1,
                               makeLeaf 'H' 1])

   -- Exercise 2.70
   print (length (encode ["get","a","job","sha","na","na","na","na","na","na","na","na",
                          "get","a","job","sha","na","na","na","na","na","na","na","na",
                          "wah","yip","yip","yip","yip","yip","yip","yip","yip","yip",
                          "sha","boom"]
                         rock50sTree))

   -- Exercise 2.71
   -- n = 5
   print (generateHuffmanTree [makeLeaf 'a' 1,
                               makeLeaf 'b' 2,
                               makeLeaf 'c' 4,
                               makeLeaf 'd' 8,
                               makeLeaf 'e' 16])
   -- n = 10
   print (generateHuffmanTree [makeLeaf 'a' 1,
                               makeLeaf 'b' 2,
                               makeLeaf 'c' 4,
                               makeLeaf 'd' 8,
                               makeLeaf 'e' 16,
                               makeLeaf 'f' 32,
                               makeLeaf 'g' 64,
                               makeLeaf 'h' 128,
                               makeLeaf 'i' 256,
                               makeLeaf 'j' 512])

-- representing
data HTreeData a b = HLeaf {hsymbol::a, hweight::b}
                   | HTree {hsymbols::[a], hweight::b, left::HTreeData a b, right::HTreeData a b}
     deriving (Eq, Show)

makeLeaf symbol weight = HLeaf {hsymbol=symbol, hweight=weight}

isLeaf (HLeaf {hsymbol=_, hweight=_}) = True
isLeaf _ = False

symbolLeaf (HLeaf {hsymbol=hsymbol, hweight=_}) = hsymbol
symbolLeaf _ = error "aDomain"

weightLeaf (HLeaf {hsymbol=_, hweight=hweight}) = hweight
weightLeaf _ = error "bDomain"

symbols (HLeaf {hsymbol=hsymbol, hweight=_}) = [hsymbol]
symbols (HTree {hsymbols=hsymbols, hweight=_, left=_, right=_}) = hsymbols

weight (HLeaf {hsymbol=_, hweight=hweight}) = hweight
weight (HTree {hsymbols=_, hweight=hweight, left=_, right=_}) = hweight

makeCodeTree left right =
   HTree {hsymbols=symbols left ++ symbols right, hweight=weight left + weight right, left=left, right=right}

leftNode (HTree {hsymbols=_, hweight=_, left=left, right=_}) = left
leftNode _ = error "cDomain"
rightNode (HTree {hsymbols=_, hweight=_, left=_, right=right}) = right
rightNode _ = error "dDomain"

chooseNode 0 node = leftNode node
chooseNode 1 node = rightNode node
chooseNode _ _ = error "eDomain"

-- decoding
decode bits tree =
   let
      decode_1 [] currentNode = []
      decode_1 (x:xs) currentNode =
        let
           nextNode = chooseNode x currentNode
        in
           if isLeaf nextNode
              then symbolLeaf nextNode:decode_1 xs tree
              else decode_1 xs nextNode
   in
      decode_1 bits tree

-- sets
adjoinSet''' x [] = [x]
adjoinSet''' x (set@(y:ys)) =
  if weight x < weight y
     then x:set
     else y:adjoinSet''' x ys

makeLeafSet (HLeaf {hsymbol=hsymbol, hweight=hweight}:pairs) =
  adjoinSet''' (makeLeaf hsymbol hweight) (makeLeafSet pairs)
makeLeafSet [] = []
makeLeafSet z = error "Domain"

-- Exercise 2.67
sampleTree =
   makeCodeTree
      (makeLeaf 'A' 4)
      (makeCodeTree
         (makeLeaf 'B' 2)
         (makeCodeTree
            (makeLeaf 'D' 1)
            (makeLeaf 'C' 1)))

sampleMessage = [0, 1, 1, 0, 0, 1, 0, 1, 0, 1, 1, 1, 0]

-- Exercise 2.68
encodeSymbol c tree =
   if isElementOfSet c (symbols tree)
      then
         let
            l = leftNode tree
            r = rightNode tree
         in
            if isLeaf l && c == (symbolLeaf l)
               then [0]
               else
                  if isLeaf r && c == symbolLeaf r
                     then [1]
                     else
                        if not (isLeaf l) && isElementOfSet c (symbols l)
                           then 0 : encodeSymbol c l
                           else
                              if not (isLeaf r) && isElementOfSet c (symbols r)
                                 then 1 : encodeSymbol c r
                                 else error "Encoding"
      else error "emcoding"

encode [] tree = []
encode (x:xs) tree =
   (encodeSymbol x tree) ++ (encode xs tree)

-- Exercise 2.69
generateHuffmanTree pairs =
   successiveMerge (makeLeafSet pairs)
successiveMerge (x:[]) = x
successiveMerge (x:x':xs) = successiveMerge (adjoinSet''' (makeCodeTree x x') xs)

-- Exercise 2.70
rock50sTree = generateHuffmanTree [makeLeaf "a" 2,
                                   makeLeaf "boom" 1,
                                   makeLeaf "get" 2,
                                   makeLeaf "job" 2,
                                   makeLeaf "na" 16,
                                   makeLeaf "sha" 3,
                                   makeLeaf "yip" 9,
                                   makeLeaf "wah" 1]


-- 2.4.1 Multiple Representations for Abstract Data - Representations for Complex Numbers

section_2_4_1 = do
   print (makeFromRealImag (realPart z) (imagPart z))
   print (makeFromMagAng (magnitude z) (angle z))
   where
      z = [1, 2]

-- Same as above
-- square x = x * x

-- Rectangular
realPartR z = head z
imagPartR z = head (tail z)

magnitudeR z =
   sqrt (square (realPartR z) + square (imagPartR z))

angleR z =
   atan2 (imagPartR z) (realPartR z)

makeFromRealImagR x y = [x, y]
makeFromMagAngR r a =
   [r * cos a,  r * sin a]

-- polar
magnitudeP z = head z
angleP z = head (tail z)

realPartP z =
   magnitudeP z * cos (angleP z)

imagPartP z =
   magnitudeP z * sin (angleP z)

makeFromRealImagP x y =
   [sqrt (square x + square y), atan2 y x]

makeFromMagAngP r a = [r, a]

-- using the abstract type
magnitude = magnitudeP
angle = angleP
realPart = realPartP
imagPart = imagPartP
makeFromRealImag = makeFromRealImagP
makeFromMagAng = makeFromMagAngP

addComplex z1 z2 =
   makeFromRealImag
      (realPart z1 + realPart z2)
      (imagPart z1 + imagPart z2)

subComplex z1 z2 =
   makeFromRealImag
      (realPart z1 - realPart z2)
      (imagPart z1 - imagPart z2)

mulComplex z1 z2 =
   makeFromMagAng
      (magnitude z1 * magnitude z2)
      (angle z1 + angle z2)

divComplex z1 z2 =
   makeFromMagAng
      (magnitude z1 / magnitude z2)
      (angle z1 - angle z2)


-- 2.4.2 Multiple Representations for Abstract Data - Tagged Data

section_2_4_2 = do
   print (addComplexG (makeFromRealImagG 3 4) (makeFromRealImagG 3 4))

data Tag a = Rectangular {tagRealPart::a, tagImagPart::a}
           | Polar {tagMagnitude::a, tagAngle::a}
     deriving (Eq, Show)

isRectangular (Rectangular {tagRealPart=_, tagImagPart=_}) = True
isRectangular _ = False

isPolar (Polar {tagMagnitude=_, tagAngle=_}) = True
isPolar _ = False

-- Rectangular
makeFromRealImagRectangular x y =
   Rectangular {tagRealPart=x, tagImagPart=y}
makeFromMagAngRectangular r a =
   Rectangular {tagRealPart=r * cos a, tagImagPart=r * sin a}

realPartRectangular (Rectangular {tagRealPart=x, tagImagPart=y}) = x
realPartRectangular _ = error "Domain"
imagPartRectangular (Rectangular {tagRealPart=x, tagImagPart=y}) = y
imagPartRectangular _ = error "Domain"

magnitudeRectangular z =
   sqrt (square (realPartRectangular z) +
         square (imagPartRectangular z))
angleRectangular z =
   atan2 (imagPartRectangular z) (realPartRectangular z)

-- Polar
makeFromRealImagPolar x y =
   Polar {tagMagnitude=sqrt (square x + square y), tagAngle=atan2 y x}
makeFromMagAngPolar r a =
   Polar {tagMagnitude=r, tagAngle=a}

magnitudePolar (Polar {tagMagnitude=x, tagAngle=_}) = x
magnitudePolar _ = error "Domain"
anglePolar (Polar {tagMagnitude=_, tagAngle=y}) = y
anglePolar _ = error "Domain"

realPartPolar z =
   magnitudePolar z * cos (anglePolar z)
imagPartPolar z =
   magnitudePolar z * sin (anglePolar z)

-- Generic selectors
realPartG z@(Rectangular {tagRealPart=_, tagImagPart=_}) = realPartRectangular z
realPartG z@(Polar {tagMagnitude=_, tagAngle=_}) = realPartPolar z
imagPartG z@(Rectangular {tagRealPart=_, tagImagPart=_}) = imagPartRectangular z
imagPartG z@(Polar {tagMagnitude=_, tagAngle=_}) = imagPartPolar z

magnitudeG z@(Rectangular {tagRealPart=_, tagImagPart=_}) = magnitudeRectangular z
magnitudeG z@(Polar {tagMagnitude=_, tagAngle=_}) = magnitudePolar z
angleG z@(Rectangular {tagRealPart=_, tagImagPart=_}) = angleRectangular z
angleG z@(Polar {tagMagnitude=_, tagAngle=_}) = anglePolar z

-- same as before
addComplexG z1 z2 =
   makeFromRealImagG (realPartG z1 + realPartG z2)
                     (imagPartG z1 + imagPartG z2)
subComplexG z1 z2 =
   makeFromRealImagG (realPartG z1 - realPartG z2)
                     (imagPartG z1 - imagPartG z2)
mulComplexG z1 z2 =
   makeFromMagAngG (magnitudeG z1 * magnitudeG z2)
                   (angleG z1 + angleG z2)
divComplexG z1 z2 =
   makeFromMagAngG (magnitudeG z1 / magnitudeG z2)
                   (angleG z1 - angleG z2)

-- Constructors for complex numbers
makeFromRealImagG x y =
   makeFromRealImagRectangular x y
makeFromMagAngG r a =
   makeFromMagAngPolar r a

