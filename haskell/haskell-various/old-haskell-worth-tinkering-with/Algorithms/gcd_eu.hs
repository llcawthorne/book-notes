
-- Euler GCD
gcd_eu :: Int -> Int -> Int
gcd_eu 0 0 = error "Undefined for m=0, n=0"
gcd_eu m 0 = m
gcd_eu m n = gcd n (m `mod` n)
