;---
; Excerpted from "Clojure Brain Teasers",
; published by The Pragmatic Bookshelf.
; Copyrights apply to this code. It may not be used to create training material,
; courses, books, articles, and the like. Contact us if you are in doubt.
; We make no guarantees that this code is fit for any purpose.
; Visit https://pragprog.com/titles/mmclobrain for more book information.
;---
(def flip {:head :tail, :tail :head})

(let [empty {}

      left nil, right nil
      {:keys [left right] :or {left :head, right (flip left)}} empty
      right-1 right
            
      left nil, right nil
      {:keys [right left] :or {left :head, right (flip left)}} empty
      right-2 right]
            
  (println "Results:" right-1 right-2)
  (= right-1 right-2))
