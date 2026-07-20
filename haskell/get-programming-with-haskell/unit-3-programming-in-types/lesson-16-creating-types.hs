
-- Original pre-Creator Book:
--data Book = Book {
--    author :: AuthorName
--  , isbn :: String
--  , title :: String
--  , year :: Int
--  , price :: Double }
--  deriving (Eq, Show)

-- QC 16.1
data AuthorName = AuthorName {
    firstName :: String
  , lastName :: String } deriving (Eq,Show)

-- QC 16.2
-- A SportsCar is a Car with a Spoiler
-- data SportsCar = SportsCar Car Spoiler

type FirstName = String
type LastName = String
type MiddleName = String

data Name = Name FirstName LastName
          | NameWithMiddle FirstName MiddleName LastName
          | TwoInitialsWithLast Char Char LastName
  deriving (Eq, Show)

data Creator = AuthorCreator Author | ArtistCreator Artist
  deriving (Eq, Show)

data Author = Author Name 
  deriving (Eq, Show)

data Artist = Person Name | Band String
  deriving (Eq, Show)

hpLovecraft :: Creator
hpLovecraft = AuthorCreator
                (Author
                  (TwoInitialsWithLast 'H' 'P' "Lovecraft"))

data Book = Book {
    author    :: Creator
  , isbn      :: String
  , bookTitle :: String
  , bookYear  :: Int
  , bookPrice :: Double
  } deriving (Eq, Show)

data VinylRecord = VinylRecord {
    artist    :: Creator
  , recordTitle :: String
  , recordYear  :: Int
  , recordPrice :: Double
  } deriving (Eq, Show)

data CollectibleToy = CollectibleToy {
    name :: String
  , description :: String
  , toyPrice :: Double
  } deriving (Eq, Show)

-- we couldn't have a price field on both Book and VinylRecord, because
-- Haskell record syntax generates a getter for each record field, so we 
-- couldn't have two price fields.  This is a somewhat ridiculous limitation.
-- In an OOP language, we could easily have Book.getPrice or book.price and
-- VinylRecord.getPrice or vinylRecord.price.  This limitation will be 
-- discussed later in the book.

-- our store sells books, records, and collectible toys
data StoreItem = BookItem Book 
               | RecordItem VinylRecord
               | ToyItem CollectibleToy
               | PamphletItem Pamphlet

price :: StoreItem -> Double
price (BookItem book) = bookPrice book
price (RecordItem record) = recordPrice record
price (ToyItem toy) = toyPrice toy
price (PamphletItem p) = 0.00

-- QC 16.3 
madeBy :: StoreItem -> String
madeBy (BookItem book) = show (author book)
madeBy (RecordItem rec) = show (artist rec)
madeBy _ = "unknown"

-- Q16.1
data Pamphlet = Pamphlet {
    title :: String
  , pamphletDescription :: String
  , contact :: Name
  } deriving (Eq, Show)

-- Q16.2
-- I got this, but my solution was overly complicated compared to the book
-- answer, so I'm going to go mostly with the book answer.  I had record
-- syntax for each object, and was keeping track of points for center and
-- corners of objects, and ran in to difficulty not being able to call the
-- topLeft point topLeft for both Square and Rectangle.

type Radius = Double
type Height = Double
type Width = Double
type X = Double
type Y = Double

data Shape = Circle Radius
           | Square Height
           | Rectangle Height Width
  deriving (Eq, Show)

perimeter :: Shape -> Double
perimeter (Circle r) = 2*pi*r
perimeter (Square h) = 4*h
perimeter (Rectangle h w) = 2*h + 2 * w

area :: Shape -> Double
area (Circle r) = pi*r^2
area (Square h) = h^2
area (Rectangle h w) = h*w

unitCircle = Circle 1
bigSquare = Square 20
smallRectangle = Rectangle 2 3
