-- A better prime sieve that the one in sieve_erat.hs
--
-- For example: It takes me 14 seconds or to find the 10000th
-- prime with sieve_erat.hs.  It takes 0.045 seconds with this formulation
-- Granted, the traditional sieve takes 0.110 seconds in Python
--
-- diff and merge are helper functions for our primes list
-- diff removes a second infinite list from the first
diff :: (Ord a) => [a] -> [a] -> [a]
diff xs@(x:xt) ys@(y:yt) = 
  case compare x y of
    LT -> x : (diff xt ys)
    EQ -> diff xt yt
    GT -> diff xs yt

-- merge combines two infinite sorted lists, without duplicates
merge :: (Ord a) => [a] -> [a] -> [a]
merge xs@(x:xt) ys@(y:yt) = 
  case compare x y of
    LT -> x : (merge xt ys)
    EQ -> x : (merge xt yt)
    GT -> y : (merge xs yt)

-- primes is the list of primes plus the list of odds with nonprimes removed
-- nonprimes are simple multiples of primes
primes, nonprimes :: [Integer]
primes    = [2, 3, 5] ++ (diff [7, 9 ..] nonprimes)
nonprimes = foldr1 f . map g . tail $ primes
  where 
      -- f merges the 'multiples of primes' lists
      f (x:xt) ys = x : (merge xt ys)
      -- g p finds multiples of primes
      g p         = [ n * p | n <- [p, p + 2 ..]]

main :: IO ()
main = do
  print $ show (primes !! 1000000)

