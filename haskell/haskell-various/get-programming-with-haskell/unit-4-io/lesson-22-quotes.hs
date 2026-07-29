-- I preferred the book solution to mine
-- Mine wasn't using lazy IO well
-- This one is properly lazy

quotes :: [String]
quotes =
  [ "You can lead a horse to water, but you can't make him drink"
  , "What goes around comes around"
  , "Cash me outside now, how 'bout dat?"
  , "The water cooler knows"
  , "Eat my shorts"
  , "Invalid input"]

lookupQuote :: [String] -> [String]
lookupQuote [] = []
lookupQuote ("n":xs) = []
lookupQuote (x:xs) = quote : (lookupQuote xs)
  where quote = quotes !! (read x - 1)

main :: IO ()
main = do
  putStrLn "Enter numbers between 1 and 5, n to quit:"
  userInput <- getContents
  mapM_ putStrLn (lookupQuote (lines userInput))
