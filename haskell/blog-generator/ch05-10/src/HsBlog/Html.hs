-- src/HsBlog/Html.hs

module HsBlog.Html
  ( -- * HTML EDSL
    Html
  , html_

    -- ** Combinators used to construct the @\<head\>@ section
  , Head
  , Title
  , title_
  , stylesheet_
  , meta_

    -- ** Combinators used to construct the @\<body\>@ section
  , p_
  , h_
  , ul_
  , ol_
  , code_
 
    -- ** Render HTML to String
  , render

    -- ** Structure
  , Structure

    -- ** Content
  , Content
  , txt_
  , img_
  , link_
  , b_
  , i_
  )
where

import Prelude hiding (head)
import HsBlog.Html.Internal
