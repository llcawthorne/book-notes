{-
 
Sort 10M floats efficiently in pure Haskell.
Uses uvector and uvector-algorithms.
 
-}
 
import Control.Monad.ST
import Data.Array.Vector
import Data.Array.Vector.Algorithms.Merge
 
main = do
    let e = runST (do
                v <- newMU (10^7) :: ST s (MUArr Float s)
                sort v
                readMU v 0)
    print e
