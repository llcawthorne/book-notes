
-- Euler GCD
gcd_eu :: Int -> Int -> Int -> Int
gcd_eu 0 0 _ = error "Undefined for m=0, n=0"
gcd_eu m 0 c = c
gcd_eu m n c = gcd_eu n (m `mod` n) (c+1)

longway :: Int -> Int -> Int
longway 0 0 = error "Undefined for m=0, n=0"
longway m n = longway' m n (min m n) 0
    where longway' m n t c = if mod m t == 0 && mod n t == 0 then c
                             else if mod m t == 0 then longway' m n (t-1) (c+2)
                             else longway' m n (t-1) (c+1)
