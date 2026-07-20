-- file: ch03/BookStore.hs
-- new data types are introduced with 'data'
-- data Typename = Constructor Comp1 Comp2 Comp3 ...
data BookInfo = Book Int String [String]
                deriving (Show)
-- new data types are convenient to collect things
-- (ie a 'BookInfo' contains an id number, 
--  a String (book title), and a list of Strings (authors)

-- some functions that pattern match on BookInfo data type
bookID      (Book id title authors) = id
bookTitle   (Book id title authors) = title
bookAuthors (Book id title authors) = authors

-- same with wildcards
nicerID      (Book id _     _      ) = id
nicerTitle   (Book _  title _      ) = title
nicerAuthors (Book _  _     authors) = authors

-- a different data type entirely
data MagazineInfo = Magazine Int String [String]
                    deriving (Show)

-- declare a new Book (of type BookInfo)
myInfo = Book 9780135072455 "Algebra of Programming"
         ["Richard Bird", "Oege de Moor"]

-- another data types.  constructor and data type can share a name,
-- (in fact, it is recommended to do so):
data BookReview = BookReview BookInfo CustomerID String
-- CustomerId is a 'type synonym' rather than a new data type
type CustomerID = Int

-- we could also do:
type ReviewText = [String]
data BetterReview = BetterReview BookInfo CustomerID ReviewText
-- synonyms are convenient to describe things 
-- (ie that Int is a CustomerId, that String is the ReviewText)

-- let's re-do BookInfo w/ synonyms
type BookISBN   = Int
type BookTitle  = String
type Authors    = [String]
data BetterInfo = BetterInfo BookISBN BookTitle Authors

-- we can also synonym new types, like this tuple of complex data types
type BookRecord = (BetterInfo, BetterReview)

-- here's a way we could represent billing info
type CardHolder = String
type CardNumber = String
type Address    = [String]

-- we can use | (or) in our data types for multiple constructors
-- a multiple constructor data type is called an "algebraic data type"
-- even an empty constructor is legal, like 'CashOnDelivery'
data BillingInfo = CreditCard CardNumber CardHolder Address
                 | CashOnDelivery
                 | Invoice CustomerID
                   deriving (Show)

-- wildcard accessors and data type declarations can be combined
-- into a single statement:
data Customer = Customer {
      customerID      :: CustomerID
    , customerName    :: String
    , customerAddress :: Address
    } deriving (Show)
-- now our Customer data type has customerID accessors function for CustomerId,
-- and matching accessor functions for its other member components also

-- The previous statement is equivalent to:
-- data Customer = Customer Int String [String]
--                 deriving (Show)
--
-- customerID :: Customer -> Int
-- customerID (Customer id _ _) = id
--
-- customerName :: Customer -> String
-- customerName (Customer _ name _) = name
--
-- customerAddress :: Customer -> [String]
-- customerAddress (Customer _ _ address) = address

-- you can make a customer using the constructor:
customer1 = Customer 271828 "J.R. Hacker"
            ["255 Syntax Ct",
             "Milpitas, CA 95134",
             "USA"]

-- or you can use the more verbose record syntax (which is more readable):
customer2 = Customer {
              customerID = 271828
            , customerAddress = ["1048576 Disk Drive",
                                 "Milpitas, CA 95134",
                                 "USA"]
            , customerName = "Jane Q. Citizen"
            }
