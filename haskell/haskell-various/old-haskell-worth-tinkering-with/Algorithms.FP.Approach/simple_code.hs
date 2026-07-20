
-- area of a circle
area r     = pi * r * r
-- log base 2 point free w/ ceiling
log2       = ceiling . logBase 2
-- value of e
e          = exp 1
-- stirling approximation of the factorial
stirling n = (n/e)**n * sqrt(2*pi*n)
-- volume of a sphere with where clause
volume r   = 4.0 / 3.0 * pi * (cube r)
    where
    cube x = x * x * x
-- recursive factorial with pattern matching
fact 0 = 1
fact n = n * fact (n-1)
-- distance from tuples of points
distance (x1, y1) (x2, y2)
    = sqrt (dx * dx + dy * dy)
      where
      dx = x2 - x1
      dy = y2 - y1
-- roots finds the roots of a polynomial ax**2+bx+c
-- it returns a tuple with the results
roots (a, b, c) = (r1, r2)
    where
    r1          = (-b + r) / f
    r2          = (-b - r) / f
    f           = 2 * a
    r | d >= 0  = sqrt d
      | d <  0  = error "Imaginary roots"
    d           = b * b - 4 * a * c
-- simple tripartite tuple functions
fst3 (x, _, _) = x
snd3 (_, x, _) = x
thd3 (_, _, x) = x
-- Lists
il :: [Int]
il = [-3, 12, -14, 56, 0, 121]
bl :: [Bool]
bl = [True, True, False]
t1 :: [(Char, Bool)]
t1 = [('a',False),('1',True),('d',True),('y',False)]
firstTen = [1..10]
evensTo100 = [2,4..100]
someSquares = [ x*x | x <- [1..10], even x]
-- remove all consecutive duplicates from a list
removeDups []        = []
removeDups [x]       = [x]
removeDups (x:y:ys)  | x == y    = removeDups (y:ys)
                     | otherwise = x : removeDups (y:ys)
-- an easy quicksort implementation                                                                                                                                  
quick               :: (Ord a) => [a] -> [a]
quick []             = []
quick (x:xs)         = 
        quick  [ y | y <- xs, y < x] ++ [x] ++  quick  [ y | y <- xs, y > x]
-- remove all duplicates from a list
removeADups []       = []
removeADups [x]      = [x]
removeADups (x:xs)   = removeDups . quick $ (x:xs)
-- perms generates all the permutations of a list
perms []    = [[]]
perms xs    = [x:p | x <- xs, p <- perms (removeFirst x xs)]
    where
    removeFirst x []        = []
    removeFirst x (y:ys)    | x == y    = ys
                            | otherwise = y : removeFirst x ys
