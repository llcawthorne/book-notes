;---
; Excerpted from "Getting Clojure",
; published by The Pragmatic Bookshelf.
; Copyrights apply to this code. It may not be used to create training material,
; courses, books, articles, and the like. Contact us if you are in doubt.
; We make no guarantees that this code is fit for any purpose.
; Visit http://www.pragmaticprogrammer.com/titles/roclojure for more book information.
;---
;; Vectors And Lists

(ns user
    (:require [testsupport :refer :all]))

;
[1 2 3 4]
;

;
[1 "two" 3 "four"]
;

;
[true 3 "four" 5]
;

;
[1 [true 3 "four" 5] 6]
;

;
[0 [1 [true 3 "four" 5] 6] 7]
;


(should-result [[true 3 "four" 5] []]
  ;
  ;; The same as [true 3 "four" 5]

  (vector true 3 "four" 5)

  ;; The same as []

  (vector)
  ;
)

(should-result [_ 3]
  ;
  (def novels ["Emma" "Coma" "War and Peace"])

  (count novels)       ; Returns 3.
  ;
)

(should= "Emma"
  ;
  (first novels)
  ;
 )

(should= '("Coma" "War and Peace")
  ;
  (rest novels)
  ;
)

;
["Coma" "War and Peace"]
;

(comment
  ;
  ("Coma" "War and Peace")
  ;
)

(should= ["War and Peace"]
  ;
  (rest (rest novels))
  ;
 )

(should= '()
  ;
  (rest ["Ready Player One"])    ; Returns an empty collection.
  ;
 )


(should= '()
  ;
  (rest [])                      ; Also an empty collection.
  ;
)

;
(def year-books ["1491" "April 1865", "1984", "2001"])

(def third-book (first (rest (rest year-books))))    ; "1984".
;

(should= third-book "1984")

(should= "1984"
  ;
  (nth year-books 2)   ; Returns "1984".
  ;
)

(should= "1984"
  ;
  (year-books 2)       ; Also returns "1984".
  ;
)

(def actual
  ;
  (conj novels "Carrie")  ; Adds "Carrie" to our list of novels.
  ;
)

(should= actual
  ;
  ["Emma" "Coma" "War and Peace" "Carrie"]
  ;
 )

(should= '("Carrie" "Emma" "Coma" "War and Peace")
  ;
  (cons "Carrie" novels)
  ;
)

(comment
;
("Carrie" "Emma" "Coma" "War and Peace")
;
)

;
'(1 2 3)
;

;
'(1 2 3 "four" 5 "six")
'(1 2.0 2.9999 "four" 5.001 "six")
'([1 2 ("a" "list" "inside a" "vector")] "inside" "a" "list")
;

(should= '(1 2 3 "four" 5 "six")
  ;
  ;; More or less the same as '(1 2 3 "four" 5 "six")

  (list 1 2 3 "four" 5 "six")
  ;
)

(should-result [_ 3 "Iliad" '("Odyssey" "Now We Are Six") "Now We Are Six"]
  ;
  (def poems '("Iliad" "Odyssey" "Now We Are Six"))

  (count poems)   ; Returns 3.
  (first poems)   ; "Iliad".
  (rest poems)    ; ("Odyssey" "Now We Are Six")
  (nth poems 2)   ; "Now We Are Six".
  ;
)

(should-result [_ '("Jabberwocky" "Iliad" "Odyssey" "Now We Are Six")]
  ;
  (def poems '("Iliad" "Odyssey" "Now We Are Six"))

  (conj poems "Jabberwocky")
  ;
)

(def result (do
  ;
  (def vector-poems ["Iliad" "Odyssey" "Now We Are Six"])

  (conj vector-poems "Jabberwocky")
  ;
))

(should= result
  ;
  ["Iliad" "Odyssey" "Now We Are Six" "Jabberwocky"]
  ;
)

;
(def novels ["Emma" "Coma" "War and Peace"])
;

;
(conj novels "Jaws")
;

;
(def more-novels (conj novels "Jaws"))
;

;
;; Create a list.

(def novels '("Emma" "Coma" "War and Peace"))

;; Just making the room warmer!

(conj novels "Jaws")
;

(comment
;
  (defn escape-html [string]
    (replace-all string [["&" "&amp;"]
                         ["\"" "&quot;"]
                         ["<" "&lt;"]
                         [">" "&gt;"]]))
  ;
)

(comment
  ;
  (defroutes routes
    [[["/" {:get home-page} ^:interceptors [bootstrap/html-body]
       ["/hiccup" {:get hiccup-page}]
       ["/enlive"  {:get enlive-page}]
       ["/mustache"  {:get mustache-page}]
       ["/stringtemplate"  {:get stringtemplate-page}]
       ["/comb" {:get comb-page}]]]])
  ;
)
