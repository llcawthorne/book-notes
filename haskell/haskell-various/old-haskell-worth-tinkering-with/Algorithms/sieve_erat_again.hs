import qualified Data.Array.MArray as A                                        
import Data.Array.ST (runSTUArray)                                             
import Data.Array.IArray (elems)                                               
import Control.Monad(forM_)                                                    
                                                                               
create n = A.newListArray (2,n) [2..n]                                         
                                                                               
nop :: Monad m => m ()                                                         
nop = return ()                                                                
                                                                               
msieve n = do                                                                  
   a <- create n                                                               
   go a                                                                        
   return a                                                                    
  where go a = [2..sqr n] `forM_` \i -> do                                     
                 val <- A.readArray a i                                        
                 if val == 0                                                   
                   then nop                                                    
                   else erase val a                                            
                                                                               
        erase v a = [(v*v)..n] `forM_` \i -> do                                
                      val <- A.readArray a i                                   
                      if val `mod` v == 0                                      
                        then A.writeArray a i 0                                
                        else nop                                               
                                                                               
        sqr n = ceiling . sqrt . toEnum $ n                                    
                                                                               
sieve n = filter (/= 0) . elems $ runSTUArray (msieve n)                       
                                                                               
main = print . length $ sieve 15485863   
