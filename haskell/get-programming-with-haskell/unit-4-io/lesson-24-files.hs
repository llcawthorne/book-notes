import Data.Char

-- first example in lesson-24-hello_file.hs

-- QC 24.1
-- openFile "stuff.txt" ReadMode

-- QC 24.2
-- using book answer
-- hasSecondLine <- hIsEOF helloFile
-- secondLine <- if not hasSecondLine
--               then hGetLine helloFile
--               else return ""

-- next example in lesson-24-file_counts.hs

-- QC 24.3
-- There's also an unwords for Text, unlike ++

-- QC 24.4
-- readFile doesn't close the handle because of lazy evaluation

-- Q24.1
cp :: FilePath -> FilePath -> IO ()
cp inFile outFile = do
  input <- readFile inFile
  writeFile outFile input
  return ()

-- Q24.2
-- this one should've been done strict so it could write back to the same file
-- we would've used TI.readFile and TI.writeFile and T.toUpper
capitalize inFile outFile = do
  input <- readFile inFile
  writeFile outFile (map toUpper input)
  return ()
