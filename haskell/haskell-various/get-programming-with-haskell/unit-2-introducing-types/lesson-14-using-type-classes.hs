
data SixSidedDie = S1 | S2 | S3 | S4 | S5 | S6
  deriving (Ord, Enum)

instance Show SixSidedDie where
  show S1 = "one"
  show S2 = "two"
  show S3 = "three"
  show S4 = "four"
  show S5 = "five"
  show S6 = "six"

-- QC 14.1
-- instance Show SixSidedDie where
--   show S1 = "1"
--   show S1 = "2"
--   show S1 = "3"
--   show S1 = "4"
--   show S1 = "5"
--   show S1 = "6"

instance Eq SixSidedDie where
  (==) S6 S6 = True
  (==) S5 S5 = True
  (==) S4 S4 = True
  (==) S3 S3 = True
  (==) S2 S2 = True
  (==) S1 S1 = True
  (==) _  _  = False

-- QC 14.2
-- Minimal complete definition of RealFrac is properFraction

--instance Ord SixSidedDie where
--  compare S6 S6 = EQ
--  compare S6 _  = GT
--  compare _  S6 = LT
--  compare S5 S5 = EQ
--  compare S5 _  = GT
--  compare _  S5 = LT
--  compare S4 S4 = EQ
--  compare S4 _  = GT
--  compare _  S4 = LT
--  ...
  
-- Q14.1
data Nickname = Pugs | Boopsie | Tots
  deriving Enum

instance Eq Nickname where
  (==) n1 n2 = fromEnum n1 == fromEnum n2

instance Ord Nickname where
  compare n1 n2 = compare (fromEnum n1) (fromEnum n2)

-- Q14.2
data FiveSidedDie = Side1 | Side2 | Side3 | Side4 | Side5
  deriving (Eq, Ord, Show, Enum)

class (Eq a, Enum a) => Die a where
  roll :: Int -> a

instance Die FiveSidedDie where
  roll n = toEnum (n `mod` 5)
