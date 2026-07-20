-- file: ch02/myDrop.hs
-- rewrite drop to demonstrate if
myDrop n xs = if n <= 0 || null xs
              then xs
              else myDrop (n - 1) (tail xs)

-- same thing, but I typed it myself
myDrop' n xs = if n <= 0 || null xs
               then xs
               else myDrop (n-1) (tail xs)

-- with guards
myDrop'' n xs | n <= 0 || null xs = xs
              | otherwise         = myDrop'' (n-1) (tail xs)
