
sigma f a inc b | a > b     = 0
                | otherwise = f a + sigma f (inc a) inc b

-- special cases
sigma1    f a b = sigma     f                        a ((+) 1) b
intsum      a b = sigma1   id                        a         b
constsum  c a b = sigma1 (\x->c)                     a         b
sum_squares a b = sigma1 (flip (**) 2)               a         b
pi_sum      a b = sigma  (\i->(1.0 / (i * (i + 2)))) a ((+) 4) b      * 8

-- or using foldl
sigma' f a inc b  = foldl (+) 0 (map f [a, inc a..b])
sigma1'    f a b  = sigma'    f                        a ((+) 1) b
intsum'      a b  = sigma1'  id                        a         b
constsum'  c a b  = sigma1' (\x->c)                    a         b
sum_squares' a b  = sigma1' (flip (**) 2)              a         b
pi_sum'      a b  = sigma' (\i->(1.0 / (i * (i + 2)))) a ((+) 4) b      * 8
