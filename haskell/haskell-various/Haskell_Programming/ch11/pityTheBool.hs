-- pityTheBool.hs
module PityTheBool where

import Data.Int

data BigSmall = Big Bool 
              | Small Bool
              deriving (Eq, Show)

-- 1) cardinality 4 = 2 + 2

data NumberOrBool = Numba Int8
                  | BoolyBool Bool
                  deriving (Eq, Show)

-- 2) cardinality 258 = 256 + 2
