-- src/HsBlog.hs

module HsBlog 
  ( convertSingle
  , convertDirectory
  , process
  , buildIndex
  )
where

import HsBlog.Env (defaultEnv)
import qualified HsBlog.Markup as Markup
import qualified HsBlog.Html as Html
import HsBlog.Convert (convert)
import HsBlog.Directory (convertDirectory, buildIndex)

import System.IO

convertSingle :: String -> Handle -> Handle -> IO ()
convertSingle title input output = do
  content <- hGetContents input
  hPutStrLn output (process title content)

process :: Html.Title -> String -> String
process title = Html.render . convert defaultEnv title . Markup.parse
