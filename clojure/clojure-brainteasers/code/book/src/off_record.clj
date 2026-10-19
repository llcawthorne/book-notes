;---
; Excerpted from "Clojure Brain Teasers",
; published by The Pragmatic Bookshelf.
; Copyrights apply to this code. It may not be used to create training material,
; courses, books, articles, and the like. Contact us if you are in doubt.
; We make no guarantees that this code is fit for any purpose.
; Visit https://pragprog.com/titles/mmclobrain for more book information.
;---
(defrecord Album [name artist])

(def news-of-the-world
  (->Album "News of the World" "Queen"))

(instance? Album (dissoc news-of-the-world :artist))
