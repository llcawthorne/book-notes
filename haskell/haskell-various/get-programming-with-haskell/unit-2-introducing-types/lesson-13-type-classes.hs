
-- QC 13.1
-- [[Char]]

class Describable a where
  describe :: a -> String

-- QC 13.3
data Icecream = Chocolate | Vanilla deriving (Show, Eq, Ord)

-- Q13.1
-- Word is another bounded class.  It seems like Int, but it doesn't support
-- negative values thus allowing it to have double the positive value.

-- Q13.2
-- succ is just like inc for Int.
-- The book points out that succ and inc work different at the maxBound.
-- succ throws an error, where inc wraps around

-- Q13.3
cycleSucc :: (Bounded a, Enum a, Eq a) => a -> a
cycleSucc n 
  | n == maxBound = minBound
  | otherwise     = succ n
