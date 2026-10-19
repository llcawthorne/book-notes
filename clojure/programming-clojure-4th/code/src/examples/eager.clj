;---
; Excerpted from "Programming Clojure, Fourth Edition",
; published by The Pragmatic Bookshelf.
; Copyrights apply to this code. It may not be used to create training material,
; courses, books, articles, and the like. Contact us if you are in doubt.
; We make no guarantees that this code is fit for any purpose.
; Visit https://pragprog.com/titles/shcloj4 for more book information.
;---
(ns examples.eager
  (:require [clojure.string]
            [clojure.java.io]))

;; eager transformation

(defn square [x] (* x x))

(defn squares-seq [n]
  (vec (map square (range n))))

(defn squares-into
  [n]
  (into [] (map square) (range n)))

(comment
  (dotimes [_ 20] (time (dotimes [_ 100] (squares-seq 10000))))
  ;; 22.8 ms
  (dotimes [_ 20] (time (dotimes [_ 100] (squares-into 10000))))
  ;; 12.0 ms
  )

;; performance

(defn preds-seq []
  (->> (all-ns)
    (map ns-publics)
    (mapcat vals)
    (filter #(clojure.string/ends-with? % "?"))
    (map #(str (.-sym %)))
    vec))

(defn preds []
  (into []
    (comp 
      (map ns-publics)
      (mapcat vals)
      (filter #(clojure.string/ends-with? % "?"))
      (map #(str (.-sym %))))
    (all-ns)))

(comment

  (= (preds) (preds-seq))
  (dotimes [_ 20] (time (dotimes [_ 50] (preds-seq))))
  ;; 151.599 msec
  (dotimes [_ 20] (time (dotimes [_ 50] (preds))))
  ;; 132.474 msecs
  )

;; external resources

(defn non-blank? [s]
  (not (clojure.string/blank? s)))

(defn non-blank-lines-seq [file-name]
  (let [reader (clojure.java.io/reader file-name)]
    (filter non-blank? (line-seq reader))))

(defn non-blank-lines [file-name]
  (with-open [reader (clojure.java.io/reader file-name)]
    (into [] (filter non-blank?) (line-seq reader))))

(defn non-blank-lines-eduction [reader]
  (eduction (filter non-blank?) (line-seq reader)))

(defn line-count [file-name]
  (with-open [reader (clojure.java.io/reader file-name)]
    (reduce (fn [cnt el] (inc cnt)) 0 (non-blank-lines-eduction reader))))

(comment
  (non-blank-lines-seq "project.clj")
  (non-blank-lines "project.clj")
  (line-count "/Users/alex/code/hangman/4000words.txt")
  )


