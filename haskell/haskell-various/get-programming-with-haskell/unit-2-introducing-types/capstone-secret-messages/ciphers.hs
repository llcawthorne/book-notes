
-- first, a simple ROT13 rotation based cipher
data FourLetterAlphabet = L1 | L2 | L3 | L4 deriving (Show,Enum,Bounded)

rotN :: (Bounded a, Enum a) => Int -> a -> a
rotN alphabetSize c = toEnum rotation
  where halfAlphabet = alphabetSize `div` 2
        offset = fromEnum c + halfAlphabet
        rotation = offset `mod` alphabetSize

fourLetterEncoder :: [FourLetterAlphabet] -> [FourLetterAlphabet]
fourLetterEncoder vals = map rot4l vals
  where alphaSize = 1 + fromEnum (maxBound :: FourLetterAlphabet)
        rot4l = rotN alphaSize

fourLetterDecoder :: [FourLetterAlphabet] -> [FourLetterAlphabet]
fourLetterDecoder vals = map rot4ldecoder vals
  where alphaSize = 1 + fromEnum (maxBound :: FourLetterAlphabet)
        rot4ldecoder = rotNdecoder alphaSize

-- the total number of items is maxBound+1, since it starts at 0
largestCharNumber :: Int
largestCharNumber  = fromEnum (maxBound :: Char)

-- Char is even size, so you can rotate back and forth with rotChar
rotChar :: Char -> Char
rotChar charToEncrypt = rotN sizeOfAlphabet charToEncrypt
  where sizeOfAlphabet = 1 + fromEnum (maxBound :: Char)

rotCharDecoder :: Char -> Char
rotCharDecoder = rotChar

rotEncoder :: String -> String
rotEncoder text = map rotChar text
  where alphaSize = 1 + fromEnum (maxBound :: Char)
        rotChar = rotN alphaSize

rotDecoder :: String -> String
rotDecoder text = map rotCharDecoder text
  where alphaSize = 1 + fromEnum (maxBound :: Char)
        rotCharDecoder = rotNdecoder alphaSize

-- for an odd sized alphabet, we'ld need a special decoder
-- this will work for odd and even sized alphabets
rotNdecoder :: (Bounded a, Enum a) => Int -> a -> a
rotNdecoder n c = toEnum rotation
  where halfN = n `div` 2
        offset = if even n
                 then fromEnum c + halfN
                 else 1 + fromEnum c + halfN
        rotation = offset `mod` n

data ThreeLetterAlphabet = Alpha
                          | Beta
                          | Kappa deriving (Show, Enum, Bounded)

threeLetterMessage :: [ThreeLetterAlphabet]
threeLetterMessage = [Alpha, Alpha, Beta, Alpha, Kappa]

threeLetterEncoder :: [ThreeLetterAlphabet] -> [ThreeLetterAlphabet]
threeLetterEncoder vals = map rot3l vals
  where alphaSize = 1 + fromEnum (maxBound :: ThreeLetterAlphabet)
        rot3l = rotN alphaSize

threeLetterDecoder :: [ThreeLetterAlphabet] -> [ThreeLetterAlphabet]
threeLetterDecoder vals = map rot31decoder vals
  where alphaSize = 1 + fromEnum (maxBound :: ThreeLetterAlphabet)
        rot31decoder = rotNdecoder alphaSize

-- we're finished with simple rotations
-- now let's try xor with a one-time pad
xorBool :: Bool -> Bool -> Bool
xorBool value1 value2 = (value1 || value2) && (not (value1 && value2))

xorPair :: (Bool,Bool) -> Bool
xorPair (v1,v2) = xorBool v1 v2

xor :: [Bool] -> [Bool] -> [Bool]
xor list1 list2 = map xorPair (zip list1 list2)

type Bits = [Bool]

intToBits' :: Int -> Bits
intToBits' 0 = [False]
intToBits' 1 = [True]
intToBits' n = if (remainder == 0)
               then False : intToBits' nextVal
               else True : intToBits' nextVal
  where remainder = n `mod` 2
        nextVal = n `div` 2

maxBits :: Int
maxBits = length (intToBits' maxBound)

intToBits :: Int -> Bits
intToBits n = leadingFalses ++ reversedBits
  where reversedBits = reverse (intToBits' n)
        missingBits = maxBits - (length reversedBits)
        leadingFalses = take missingBits (cycle [False])

charToBits :: Char -> Bits
charToBits char = intToBits (fromEnum char)

bitsToInt :: Bits -> Int
bitsToInt bits = sum (map (\x -> 2^(snd x)) trueLocations)
  where size = length bits
        indices = [size-1, size-2 .. 0]
        trueLocations = filter (\x -> fst x == True)
                        (zip bits indices)

bitsToChar :: Bits -> Char
bitsToChar bits = toEnum (bitsToInt bits)

-- a pretty bad choice for one-time pad
myPad :: String
myPad = "Shhhhhh"

myPlainText :: String
myPlainText = "Haskell"

applyOTP' :: String -> String -> [Bits]
applyOTP' pad plaintext = map (\pair ->
                                (fst pair) `xor` (snd pair))
                          (zip padBits plaintextBits)
  where padBits = map charToBits pad
        plaintextBits = map charToBits plaintext

applyOTP :: String -> String -> String
applyOTP pad plaintext = map bitsToChar bitList
  where bitList = applyOTP' pad plaintext

-- this will encode anything shorter than myPad, but it does re-use myPad
encoderDecoder :: String -> String
encoderDecoder = applyOTP myPad

-- ok, so let's try both above with a type class for ciphers
class Cipher a where
  encode :: a -> String -> String
  decode :: a -> String -> String

data Rot = Rot

instance Cipher Rot where
  encode Rot text = rotEncoder text
  decode Rot text = rotDecoder text

-- *Main> encode Rot "test"
-- "\557172\557157\557171\557172"
-- *Main> decode Rot (encode Rot "test")
-- "test"

data OneTimePad = OTP String

instance Cipher OneTimePad where
  encode (OTP pad) text = applyOTP pad text
  decode (OTP pad) text = applyOTP pad text

-- Main> encode (OTP myPad) "test"
-- "'\r\ESC\FS"
-- *Main> decode (OTP myPad) (encode (OTP myPad) "test")
-- "test"

-- large but still predictable
bigOTP :: OneTimePad
bigOTP = OTP (cycle [minBound .. maxBound])

-- *Main> encode bigOTP "Hakuna matada"
-- "H`ivjd&ji}kom"
-- *Main> decode bigOTP (encode bigOTP "Hakuna matada")
-- "Hakuna matada"
