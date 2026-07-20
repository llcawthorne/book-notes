module Matrix (Matrix(),matrix,matrixTranspose) where

import Data.List (transpose)

data Matrix a = Matrix {matrixN :: Int, 
                        matrixM :: Int,
                        matrixElems :: [[a]]}
                deriving (Show, Eq)

matrix :: Int -> Int -> [[a]] -> Matrix a
matrix n m vals
  | length vals /= m            = error "Wrong number of rows"
  | any (/=n) $ map length vals = error "Column length mismatch"
  | otherwise = Matrix n m vals

matrixTranspose (Matrix m n vals) = matrix n m (transpose vals)

mmult (Matrix m n vals) (Matrix n' p vals')
    | n/=n' = error "Matrix dimension mismatch in multiplication"
    | otherwise = let tvals' = transpose vals'
                      dot x y = sum $ zipWith (*) x y
                      result = map (\col -> map (dot col) tvals') vals
                  in Matrix m p result

a = matrix 3 2 [[1,2,3],[4,5,6]]
b = mmult a (matrixTranspose a)
