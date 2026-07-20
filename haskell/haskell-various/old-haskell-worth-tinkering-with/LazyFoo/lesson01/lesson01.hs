#!/usr/bin/runhaskell
module Main where

import Graphics.UI.SDL as SDL

main = withInit [InitEverything] $ do --withInit calls quit for us.

  screen <- setVideoMode 640 480 32 [SWSurface]
  hello  <- loadBMP "hello.bmp"

  blitSurface hello Nothing screen Nothing

  SDL.flip screen
  
  delay 2000
