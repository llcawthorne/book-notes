module CipherSpec where

import Cipher (caesar, uncaesar, vigenere, unvigenere)
import Test.Hspec
import Test.QuickCheck

main :: IO ()
main = hspec $ do
    describe "Caesar cipher" $ do
      it "should encrypt 'Meet at Dawn' as 'Rjjy fy Ifbs' with shift 5" $ do
        caesar 5 "Meet at Dawn" `shouldBe` "Rjjy fy Ifbs"
      it "should return plaintext with shift of 0" $ do
        property $ testCaesar0
      it "should return plaintext if you shift 13 twice" $ do
        property $ testCaesar13
      it "uncaesar n . caesar n should be identity" $ do 
        property $ testCaesarN
    describe "Vigenere cipher" $ do
      it "should encrypt 'Meet at Dawn' as 'Mppr ae Oywy' with key 'ALLY'" $ do
        vigenere "ALLY" "Meet at Dawn" `shouldBe` "Mppr ae Oywy"
      it "should return plaintext with key of 'a'" $ do
        property $ testVigenereA
      it "unvigenere 'ALLY' . vigenere 'ALLY' should be identity" $ do
        property $ testVigenereALLY
      it "unvigenere key . vigenere key should be identity" $ do 
        property $ testVigenereAny

testCaesar0 :: SafeString -> Bool
testCaesar0 (SafeString s) = caesar 0 s == s

testCaesar13 :: SafeString -> Bool
testCaesar13 (SafeString s) = (caesar 13 . caesar 13) s == s

testCaesarN :: Int -> SafeString -> Bool
testCaesarN n (SafeString s) = (uncaesar n . caesar n) s == s

testVigenereA :: SafeString -> Bool
testVigenereA (SafeString s) = vigenere "a" s == s

testVigenereALLY :: SafeString -> Bool
testVigenereALLY (SafeString s) = (unvigenere "ALLY" . vigenere "ALLY") s == s

testVigenereAny :: AlphaString -> SafeString -> Bool
testVigenereAny (AlphaString key) (SafeString s) = 
  (unvigenere key . vigenere key) s == s

genAlphaChar :: Gen Char
genAlphaChar = elements (['A'..'Z'] ++ ['a'..'z'])

genAlphaString :: Gen String
genAlphaString = listOf1 genAlphaChar

newtype AlphaString = AlphaString { unwrapAlphaString :: String }
  deriving (Eq, Show)

instance Arbitrary AlphaString where
  arbitrary = AlphaString <$> genAlphaString

genSafeChar :: Gen Char
genSafeChar = elements (['A'..'Z'] ++ ['a'..'z'] ++ ['.', '!', ' '])

genSafeString :: Gen String
genSafeString = listOf genSafeChar

newtype SafeString = SafeString { unwrapSafeString :: String }
  deriving (Eq, Show)

instance Arbitrary SafeString where
  arbitrary = SafeString <$> genSafeString
