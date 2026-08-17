module Exercises (
  square,
  myLines,
  myLines',
  myLines'',
  myWords,
  myWords',
  myUnlines,
  myUnwords,
  myUnwords',
  myUnlines',
  myUnlines'',
  myPad,
  myPadLeft,
  myPadRight,
  myPadCenter,
  myZip,
  myZipWith,
  myZip',
  myMapM,
  myMapM_,
)
where

square :: Int -> Int
square x = x * x

myLines :: String -> [String]
myLines "" = []
myLines text =
  let go "" "" = []
      go line "" = [line]
      go line (x : xs)
        | x == '\n' = line : go "" xs
        | otherwise = go (line ++ [x]) xs
   in go "" text

-- making it tail recursive
myLines' :: String -> [String]
myLines' text =
  let go :: String -> String -> [String] -> [String]
      go "" "" res = reverse res
      go line "" res = reverse (reverse line : res)
      go line (x : xs) res
        | x == '\n' = go "" xs (reverse line : res)
        | otherwise = go (x : line) xs res
   in go "" text []

-- smart version cooked up by AI with no reverse calls
myLines'' :: String -> [String]
myLines'' text = go id id text
 where
  go line acc "" =
    let final = line ""
     in if null final then acc [] else acc [final]
  go line acc (x : xs)
    | x == '\n' = go id (acc . (line "" :)) xs
    | otherwise = go (line . (x :)) acc xs

myWords :: String -> [String]
myWords "" = []
myWords text =
  let go :: String -> String -> [String]
      go "" "" = []
      go acc "" = [acc]
      go acc (x : xs)
        | x == ' ' = if acc == "" then go "" xs else acc : go "" xs
        | otherwise = go (acc ++ [x]) xs
   in go "" text

myWords' :: String -> [String]
myWords' "" = []
myWords' text =
  let go :: String -> String -> [String] -> [String]
      go "" "" words = reverse words
      go acc "" words = reverse (reverse acc : words)
      go acc (x : xs) words
        | x == ' ' =
            if acc == "" then go "" xs words else go "" xs (reverse acc : words)
        | otherwise = go (x : acc) xs words
   in go "" text []

myUnwords :: [String] -> String
myUnwords [] = []
myUnwords ([x]) = x
myUnwords (x : xs) = x ++ " " ++ myUnwords xs

myUnwords' :: [String] -> String
myUnwords' words =
  let go :: [String] -> String -> String
      go [] acc = acc
      go (x : xs) "" = go xs x
      go (x : xs) acc = go xs (acc ++ " " ++ x)
   in go words ""

myUnlines :: [String] -> String
myUnlines [] = []
myUnlines (x : xs) = x ++ "\n" ++ myUnlines xs

myUnlines' :: [String] -> String
myUnlines' lines =
  let go :: [String] -> String -> String
      go [] "" = ""
      go [] acc = acc ++ "\n"
      go (x : xs) "" = go xs x
      go (x : xs) acc = go xs (acc ++ '\n' : x)
   in go lines ""

-- This avoids using (++) with the acc, which can get big
myUnlines'' :: [String] -> String
myUnlines'' lines =
  let go :: [String] -> [String] -> String
      go [] acc = concat (reverse acc)
      go (x : xs) acc = go xs ((x ++ "\n") : acc)
   in go lines []

-- eta reduction was done in ch02 folder, changing the original caesar project.

data MyPadMode = PadLeft | PadRight | PadCenter

myPad :: MyPadMode -> Int -> String -> String
myPad mode n str =
  let diff = n - length str
      padding = replicate diff ' '
      halfPadding = replicate (diff `div` 2) ' '
   in case mode of
        PadLeft -> padding ++ str
        PadRight -> str ++ padding
        PadCenter -> halfPadding ++ str ++ halfPadding

myPadLeft :: String -> String
myPadLeft = myPad PadLeft 10

myPadRight :: String -> String
myPadRight = myPad PadRight 10

myPadCenter :: String -> String
myPadCenter = myPad PadCenter 10

myZip :: [a] -> [b] -> [(a, b)]
myZip [] [] = []
myZip [] _ = []
myZip _ [] = []
myZip (x : xs) (y : ys) = (x, y) : myZip xs ys

myZipWith :: (a -> b -> c) -> [a] -> [b] -> [c]
myZipWith _ [] [] = []
myZipWith _ [] _ = []
myZipWith _ _ [] = []
myZipWith f (x : xs) (y : ys) = f x y : myZipWith f xs ys

myZip' :: [a] -> [b] -> [(a, b)]
myZip' = myZipWith (\x y -> (x, y))

myMapM :: (a -> IO b) -> [a] -> IO [b]
myMapM _ [] = return []
myMapM f (x : xs) = do
  res <- f x
  rest <- myMapM f xs
  return (res : rest)

myMapM_ :: (a -> IO b) -> [a] -> IO ()
myMapM_ _ [] = return ()
myMapM_ f (x : xs) = do
  _ <- f x
  myMapM_ f xs
