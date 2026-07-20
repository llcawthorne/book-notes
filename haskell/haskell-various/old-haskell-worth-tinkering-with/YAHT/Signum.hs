module Signum
    where

-- A signum function return -1 for negative values, 0 for 0, and 1 for
-- positive values of x
signum x =
    if x < 0
        then -1
        else if x > 0
            then 1
            else 0
