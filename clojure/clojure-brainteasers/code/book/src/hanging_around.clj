;---
; Excerpted from "Clojure Brain Teasers",
; published by The Pragmatic Bookshelf.
; Copyrights apply to this code. It may not be used to create training material,
; courses, books, articles, and the like. Contact us if you are in doubt.
; We make no guarantees that this code is fit for any purpose.
; Visit https://pragprog.com/titles/mmclobrain for more book information.
;---
(require '[clojure.java.io :as jio]
         '[clojure.string :as str])

(defn grep
  "Return lazy sequence of matches to substring
   in the file at path"
  [substring path]
  (with-open [reader (jio/reader path)]
    (->> reader
         (line-seq)
         (filter #(str/includes? % substring)))))

(grep "defn" "book/src/hanging_around.clj")
