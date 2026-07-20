-- dogTypes.hs
module DogTypes where

data Doggies a =
    Husky a
  | Mastiff a
  deriving (Eq, Show)

-- 1) Doggies is a type constructor
-- 2) Doggies :: * -> *
-- 3) Doggies String :: *
-- 4) Husky 10 :: Num a => Doggies a
-- 5) Husky (10 :: Integer) :: Doggies Integer
-- 6) Mastiff "Scooby Doo" :: Doggies String
data DogueDeBordeaux doge =
    DogueDeBordeaux doge
-- 7) Both
-- 8) doge -> DogueDeBordeaux doge
-- 9) DogueDeBordeaux "doggie!" :: DogueDeBordeaux String
