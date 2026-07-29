-- I used the book solution for this one
-- Even with the book solution, it doesn't work right
-- Oh.  You have to enter:
-- 22
-- +
-- 7
-- Ctrl+D
-- That works
sampleInput :: [String]
sampleInput = ["21","+","123"]

calc :: [String] -> Int
calc (val1:"+":val2:rest) = read val1 + read val2
calc (val1:"*":val2:rest) = read val1 * read val2
calc o = error ("Invalid input: " ++ show o)

main :: IO ()
main = do
  userInput <- getContents
  let values = lines userInput
  print (calc values)
