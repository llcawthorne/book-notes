module LearnParsers where

import Control.Applicative
import Text.Trifecta
import Text.Parser.Combinators

-- a Parser takes a String and returns a Maybe - either Nothing on failure
-- or (a, String) where `a` is the value you want, and `String` is what is
-- left unparsed of the input. Here is the type declaration:
-- type Parser a = String -> Maybe (a, String)
stop :: Parser a
stop = unexpected "stop"

-- read a single character '1'
one = char '1' 

-- read a single character '1', then die
one' = one >> stop

oneTwo = char '1' >> char '2'
oneTwo' = oneTwo >> stop

p123 :: Parser String
p123 = string "123" <|> string "12" <|> string "1"

pNL s = putStrLn ('\n' : s)

testParse :: Parser Char -> IO ()
testParse p = print $ parseString p mempty "123"

runParse :: IO ()
runParse = do
  pNL "stop:"
  testParse stop

  pNL "one:"
  testParse one

  pNL "one':"
  testParse one'

  pNL "oneTwo:"
  testParse oneTwo

  pNL "oneTwo':"
  testParse oneTwo'

