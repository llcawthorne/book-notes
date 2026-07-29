import System.Environment
import Control.Monad

main :: IO ()
main = do
  args <- getArgs
  let linesToRead = if length args > 0
                    then read (head args)
                    else 0 :: Int
  putStrLn ("Enter " ++ show linesToRead ++ " numbers:")
  numbers <- replicateM linesToRead getLine
  let ints = map read numbers :: [Int]
  putStrLn ("The sum is: " ++ show (sum ints))
