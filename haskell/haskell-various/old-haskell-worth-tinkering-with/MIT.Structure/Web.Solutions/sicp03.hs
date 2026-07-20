-- broken?
module SICP03 where

import Control.Exception (catch)
import Data.IORef (newIORef, readIORef, writeIORef)
import System.IO.Unsafe (unsafePerformIO)

main = do
   section_3_1_1

-- Functions defined in previous chapters
gcd' a 0 = a
gcd' a b = gcd' b (a `mod` b)


[edit]
-- 3.1.1 - Assignment and Local State - Local State Variables

data Account a b = Account {accountWithdraw :: a -> b,
                            accountDeposit :: a -> b,
                            accountBalance :: b}

section_3_1_1 = do

   withdraw 25
   withdraw 25
   Control.Exception.catch (withdraw 60 >>= print) print
   withdraw 15
   readIORef balance >>= print

   newWithdraw' <- newWithdraw
   newWithdraw' 25
   newWithdraw' 25
   Control.Exception.catch (newWithdraw' 60 >>= print) print
   newWithdraw' 15 >>= print

   b1 <- newIORef 100
   let w1 = makeWithdraw b1
   b2 <- newIORef 100
   let w2 = makeWithdraw b2
   w1 50
   w2 70
   Control.Exception.catch (w2 40 >>= print) print
   w1 40
   readIORef b1 >>= print
   readIORef b2 >>= print

   acc <- makeAccount 100
   accountWithdraw acc 50
   Control.Exception.catch (accountWithdraw acc 60 >>= print) print
   accountDeposit acc 40
   accountWithdraw acc 60
   accountBalance acc >>= print

   acc2 <- makeAccount 100

   -- Exercise 3.1
   a <- makeAccumulator 5
   a 10 >>= print
   a 10 >>= print

   -- Exercise 3,2
   (sqrtMonitored, howManyCalls, resetCount) <- makeMonitored sqrt
   sqrtMonitored 100 >>= print
   sqrtMonitored 25 >>= print
   howManyCalls >>= print

   -- Exercise 3,3
   acc <- makePasswordAccount "secret-password" 100
   passwordAccountWithdraw acc "secret-password" 40
   Control.Exception.catch (passwordAccountWithdraw acc "some-other-password" 50 >>= print) print
   passwordAccountBalance acc "secret-password" >>= print

   print ""

-- Note: this is a hack, but Haskell discourages globals at the module level
balance = unsafePerformIO (newIORef 100)

withdraw amount = do
   b <- readIORef balance
   if b >= amount
      then writeIORef balance (b - amount)
      else error ("Insufficient Funds: " ++ (show b))
   readIORef balance

newWithdraw =do
   balance <- newIORef 100
   let
      withdraw amount = do
         b <- readIORef balance
         if b >= amount
            then writeIORef balance (b - amount)
            else error ("Insufficient Funds: " ++ (show b))
         readIORef balance >>= return
   return withdraw

makeWithdraw balance amount = do
   b <- readIORef balance
   if b >= amount
      then writeIORef balance (b - amount)
      else error ("Insufficient Funds: " ++ (show b))
   readIORef balance >>= return

makeAccount initBalance = do
   balance <- newIORef initBalance
   let
      withdraw amount = do
         b <- getBalance
         if b >= amount
            then writeIORef balance (b - amount)
            else error ("Insufficient Funds: " ++ show b)
         getBalance
      deposit amount = do
         b <- getBalance
         writeIORef balance (b + amount)
         getBalance
      getBalance = readIORef balance
   return $ Account {accountWithdraw=withdraw, accountDeposit=deposit, accountBalance=getBalance}

-- Exercise 3.1
makeAccumulator initial = do
   accumulator <- newIORef initial
   let
      setAccumulator x = do
         a <- readIORef accumulator
         writeIORef accumulator (a + x)
         readIORef accumulator >>= return
   return setAccumulator

-- Exercise 3.2
makeMonitored proc = do
   callCount <- newIORef 0
   let
      monitored m = do
         n <- readIORef callCount
         writeIORef callCount (n + 1)
         return (proc m)
      howManyCalls = readIORef callCount
      resetCount = do
         writeIORef callCount 0

   return (monitored, howManyCalls, resetCount)

-- Exercise 3.3
data PasswordAccount a b = PasswordAccount {passwordAccountWithdraw :: String -> a -> b,
                                            passwordAccountDeposit :: String -> a -> b,
                                            passwordAccountBalance :: String -> b}

makePasswordAccount secretPassword initBalance = do
   balance <- newIORef initBalance
   let
      password = secretPassword
      withdraw amount = do
         b <- getBalance
         if b >= amount
            then writeIORef balance (b - amount)
            else error ("Insufficient Funds: " ++ show b)
         getBalance
      deposit amount = do
         b <- getBalance
         writeIORef balance (b + amount)
         getBalance
      getBalance = readIORef balance
      wrapPassword m password =
         if password == secretPassword
            then m
            else error "Invalid Password"
   return $ PasswordAccount {passwordAccountWithdraw=wrapPassword withdraw,
                             passwordAccountDeposit=wrapPassword deposit,
                             passwordAccountBalance=wrapPassword getBalance}

-- Exercise 3.4
-- Note: I am having problems getting this correct.  The result is an IO monad wrapping an IO monad.
-- makePoliceAccount secretPassword initBalance = do
--    balance <- newIORef initBalance
--    badPasswordCount <- newIORef 0
--    let
--       password = secretPassword
--       withdraw amount = do
--          b <- getBalance
--          if b >= amount
--             then writeIORef balance (b - amount)
--             else error ("Insufficient Funds: " ++ show b)
--          getBalance
--       deposit amount = do
--          b <- getBalance
--          writeIORef balance (b + amount)
--          getBalance
--       getBalance = readIORef balance
--       wrapPassword m password =
--          if password == secretPassword
--             then do
--                writeIORef badPasswordCount 0
--                m >>= return
--             else do
--                n <- readIORef badPasswordCount
--                writeIORef badPasswordCount (n+1)
--                n <- readIORef badPasswordCount
--                if n > 7
--                   then error "Call the cops"
--                   else error "Invalid Password"
--    return $ PasswordAccount {passwordAccountWithdraw=wrapPassword withdraw,
--                              passwordAccountDeposit=wrapPassword deposit,
--                              passwordAccountBalance=wrapPassword getBalance}

