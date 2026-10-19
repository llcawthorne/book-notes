;---
; Excerpted from "Clojure Brain Teasers",
; published by The Pragmatic Bookshelf.
; Copyrights apply to this code. It may not be used to create training material,
; courses, books, articles, and the like. Contact us if you are in doubt.
; We make no guarantees that this code is fit for any purpose.
; Visit https://pragprog.com/titles/mmclobrain for more book information.
;---
(def names ["Scarlet" "Dandelion" "Cerulean"])
(def codes ["FD0E35" "FED85D" "02A4D3"])
(= (map #([%1 %2]) names codes)
   '(["Scarlet" "FD0E35"] ["Dandelion" "FED85D"] ["Cerulean" "02A4D3"]))