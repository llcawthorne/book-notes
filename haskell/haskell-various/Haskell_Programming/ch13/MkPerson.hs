module MkPerson where

type Name = String
type Age  = Integer

data Person = Person Name Age deriving Show

data PersonInvalid = NameEmpty
                   | AgeTooLow
                   | PersonInvalidUnknown String
                   deriving (Eq, Show)

mkPerson :: Name -> Age -> Either PersonInvalid Person
mkPerson name age
  | name /= "" && age > 0 = Right $ Person name age
  | name == ""            = Left NameEmpty
  | not (age > 0)         = Left AgeTooLow
  | otherwise             = Left $ PersonInvalidUnknown
                          $ "Name was: " ++ show name 
                         ++ " Age was: " ++ show age

gimmePerson :: IO ()
gimmePerson = do
  putStr "Enter a name: "
  name <- getLine
  putStr "Enter an age: "
  sAge <- getLine
  let age = (read sAge :: Integer)
      ePerson = mkPerson name age
  case ePerson of
    Left e  -> 
      putStrLn $ "An error occurred: " ++ show e
    Right p -> 
      putStrLn $ "Yay! Successfully got a person: " ++ show p
