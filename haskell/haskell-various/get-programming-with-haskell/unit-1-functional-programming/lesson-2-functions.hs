
-- Q2.2
inc x = x + 1

double x = 2 * x

square x = x * x

-- Q2.3
mathIt n = if even n then n - 2 else 3 * n + 1

mathGuards n
  | even n = n - 2
  | otherwise = 3 * n + 1
