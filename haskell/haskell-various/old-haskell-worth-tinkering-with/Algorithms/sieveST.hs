
import Control.Monad
import Control.Monad.ST
import Data.Array.IArray
import Data.Array.MArray
import Data.Array.ST
import Data.Array.Unboxed
 
primesToNA :: Int -> UArray Int Bool
primesToNA n = runSTUArray sieve  where
  sieve = do
    a <- newArray (2,n) True :: ST s (STUArray s Int Bool)
    let sr = floor . (sqrt::Double->Double) . fromIntegral $ n+1
    forM_ [4,6..n] $ \j -> writeArray a j False
    forM_ [3,5..sr] $ \i -> do
      si <- readArray a i
      when si $
        forM_ [i*i,i*i+i+i..n] $ \j -> writeArray a j False
    return a
 
primesToN :: Int -> [Int]
primesToN n = [i | (i,e) <- assocs . primesToNA $n, e]

main = putStrLn (show (primesToN 16000000 !! 1000000))
