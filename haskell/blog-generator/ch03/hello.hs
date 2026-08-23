-- hello.hs

import Html

main :: IO ()
main = putStrLn (render myhtml)

myhtml =
  html_
    "My title"
    (append_
      (h1_ "Hello, world!")
      (append_
        (p_ "Let's learn about Haskell!")
        (ul_
          [ p_ "item 1"
          , p_ "item 2"
          , p_ "item 3"
          ]
        )
      )
    )

