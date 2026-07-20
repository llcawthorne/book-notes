{-# OPTIONS -fth #-}
import Primes
 
main = print $( let x = nthPrime 1000000000 in [| x |] )

