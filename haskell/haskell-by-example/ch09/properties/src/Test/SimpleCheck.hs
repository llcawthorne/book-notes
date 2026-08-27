module Test.SimpleCheck
  ( RandomState
  , randomInt
  , randomIntList
  , sorts
  , randomListN
  , randomList
  , randomList'
  , randomListIO
  , applyGlobalStdGen
  , propertyTestSorts
  , RandomIO (..)
  , one
  , some
  , replicateIO
  , suchThat
  , nonNegative
  , nonEmpty
  , asciiChar
  , letterChar
  , elements
  , asciiChar'
  , letterChar'
  , asciiString'
  , letterString'
  , manyOf
  , asciiString
  , letterString
  , propertyTest
  )
where

import Data.Char
import qualified Data.List as L
import System.Random
import System.Random.Stateful

-- doing it ourselves without Random
newtype RandomState = RandomState Int
  deriving (Eq, Show)

randomInt :: RandomState -> (Int, RandomState)
randomInt (RandomState rs) = (newRs, RandomState newRs)
  where
    newRs = (1103515245 * rs + 12345) `mod` (2 ^ 31)

randomIntList :: RandomState -> Int -> [Int]
randomIntList rs n
  | n <= 0 = []
  | otherwise =
    let (v, rs') = randomInt rs
     in v : randomIntList rs' (n - 1)

sorted :: Ord a => [a] -> Bool
sorted [] = True
sorted [_] = True
sorted (x : y : xs) = x <= y && sorted (y : xs)

sorts :: Ord a => ([a] -> [a]) -> [a] -> Bool
sorts f input = sorted $ f input

randomListN :: (Random a) => StdGen -> Int -> ([a], StdGen)
randomListN gen n
  | n <= 0 = ([], gen)
  | otherwise =
    let (v, gen') = random gen
        (xs, gen'') = randomListN gen' (n-1)
     in (v : xs, gen'')

randomList :: (Random a) => StdGen -> Int -> ([a], StdGen)
randomList gen maxVal = randomListN gen' n
  where
    (n, gen') = uniformR (0, maxVal) gen

randomList' :: (Random a) => StdGen -> ([a], StdGen)
randomList' = flip randomList 100

randomListIO :: (Random a) => IO [a]
randomListIO = do
  g <- getStdGen
  let (xs, g') = randomList' g
  setStdGen g'
  return xs

applyGlobalStdGen :: (StdGen -> (a, StdGen)) -> IO a
applyGlobalStdGen f = applyAtomicGen f globalStdGen

propertyTestSorts :: ([Int] -> [Int]) -> Int -> IO ()
propertyTestSorts f n
  | n <= 0 = putStrLn "Tests successful!"
  | otherwise = do
    xs <- applyGlobalStdGen randomList'
    if f `sorts` xs
      then propertyTestSorts f $ n - 1
      else putStrLn $ "Test failed on: " <> show xs

newtype RandomIO a = RandomIO {runRandomIO :: IO a}

one :: Random a => RandomIO a
one = RandomIO $ applyGlobalStdGen random

some :: Random a => RandomIO [a]
some = RandomIO $ do
  n <- applyGlobalStdGen $ uniformR (0, 100)
  replicateIO n $ runRandomIO one

replicateIO :: Int -> IO a -> IO [a]
replicateIO n act
  | n <= 0 = return []
  | otherwise = do
    x <- act
    xs <- replicateIO (n - 1) act
    return $ x : xs

suchThat :: RandomIO a -> (a -> Bool) -> RandomIO a
suchThat rand pred = RandomIO $ do
  val <- runRandomIO rand
  if pred val
    then return val
    else runRandomIO $ suchThat rand pred

nonNegative :: (Num a, Ord a, Random a) => RandomIO a
nonNegative = one `suchThat` (> 0)

nonEmpty :: Random a => RandomIO [a]
nonEmpty = some `suchThat` (not . null)

instance Functor RandomIO where
  fmap f rio = RandomIO $ fmap f (runRandomIO rio)

asciiChar :: RandomIO Char
asciiChar = one `suchThat` (\c -> isAscii c && not (isControl c))

letterChar :: RandomIO Char
letterChar = asciiChar `suchThat` isLetter

elements :: [a] -> RandomIO a
elements [] = error "elements cannot work with an empty list!"
elements xs = RandomIO $ do
  i <- applyGlobalStdGen $ uniformR (0, length xs - 1)
  return $ xs !! i

asciiChar' :: RandomIO Char
asciiChar' = elements ['\x20' .. '\x7e'] -- ASCII codes given directly as hex-values; see https://theasciicode.com.ar

letterChar' :: RandomIO Char
letterChar' =
  elements "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"

asciiString' :: RandomIO String
asciiString' = manyOf asciiChar'

letterString' :: RandomIO String
letterString' = manyOf letterChar'

manyOf :: RandomIO a -> RandomIO [a]
manyOf rio = RandomIO $ do
  n <- applyGlobalStdGen $ uniformR (0, 100)
  replicateIO n (runRandomIO rio)

asciiString :: RandomIO String
asciiString = manyOf asciiChar

letterString :: RandomIO String
letterString = manyOf letterChar

propertyTest :: Show a => (a -> Bool) -> RandomIO a -> Int -> IO ()
propertyTest predicate random n
  | n <= 0 = putStrLn "Tests successful!"
  | otherwise = do
    testCase <- runRandomIO random
    if predicate testCase
      then propertyTest predicate random $ n - 1
      else putStrLn $ "Test failed on: " <> show testCase
