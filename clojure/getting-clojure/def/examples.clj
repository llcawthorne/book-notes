;---
; Excerpted from "Getting Clojure",
; published by The Pragmatic Bookshelf.
; Copyrights apply to this code. It may not be used to create training material,
; courses, books, articles, and the like. Contact us if you are in doubt.
; We make no guarantees that this code is fit for any purpose.
; Visit http://www.pragmaticprogrammer.com/titles/roclojure for more book information.
;---
;; Def, Symbols and Vars

(ns user
  (:require [testsupport :refer :all]))

;
(def title "Emma")
;


;
;; Everyone's favorite universal constant.

(def PI 3.14)

;; Length of a standard book ID.

(def ISBN-LENGTH 13)

;; Company names are more or less constant.

(def COMPANY-NAME "Blotts Books")
;

;
(defn book-description [book]
  (str (:title book)
       " Written by "
       (:author book)))
;

(should-match #"TTT.*Written.*AAA"
  (book-description {:title "TTT" :author "AAA"}))

;
(def book-description
  (fn [book]
    (str (:title book)
         " Written by "
         (:author book))))
;

(should-match #"TTT.*Written.*AAA"
  (book-description {:title "TTT" :author "AAA"}))

;
;; Length of a standard book ID.

(def ISBN-LENGTH 13)

;; Before 2007 ISBNs were 10 characters long.

(def OLD-ISBN-LENGTH 10)
;

;
(def isbn-lengths [OLD-ISBN-LENGTH ISBN-LENGTH])
;

;
(defn valid-isbn [isbn]
  (or (= (count isbn) OLD-ISBN-LENGTH)
      (= (count isbn) ISBN-LENGTH)))
;

(should (valid-isbn "1234567890123"))
(should (valid-isbn "1234567890"))
(should (not (valid-isbn "1234567890x")))
(should (not (valid-isbn "1234567890xxxx")))

;
(def author "Austen")
;

(def the-syms [
  ;
  'author    ; The symbol author, not the string "Austen"
  'title     ; A symbol that starts with a 't'.
  ;
])

(should (every? symbol? the-syms))

(should= "author"
  ;
  (str 'author)  ; The string "author".
  ;
)

(should-result [false true]
  ;
  (= 'author 'some-other-symbol)  ; Nope.
  (= 'title 'title)               ; Yup.
  ;
)


(mdef [_ a-var]
  ;
  (def author "Austen")  ; Make a var.

  #'author               ; Get at the var for author -> "Austen".
  ;
)

(should (var? a-var))
(should= 'author (.sym a-var))


;
(def the-var #'author) ; Grab the var.
;

(should (var? the-var))
(should= 'author (.sym the-var))


(should-result ["Austen" 'author]
  ;
  (.get the-var)         ; Get the value of the var: "Austen"
  (.-sym the-var)        ; Get the symbol of the var: author
  ;
)


;
;; First cut at debugging, needs some work.

(def debug-enabled false)

(defn debug [msg]
  (if debug-enabled
    (println msg)))
;


;; Put this earlier so that the binding example has the dynamic var.

;
;; Make debug-enabled a dynamic var.

(def ^:dynamic debug-enabled false)
;

(defn some-troublesome-function-that-needs-logging []
    (println "enabled" debug-enabled))

(should-print #"true"
  ;

  (binding [debug-enabled true]
    (debug "Calling that darned function")
    (some-troublesome-function-that-needs-logging)
    (debug "Back from that darned function"))
  ;
)


(should-print #"false"
  (binding [debug-enabled false]
    (some-troublesome-function-that-needs-logging)))


(def ^:dynamic *debug-enabled* false)
(defn some-troublesome-function-that-needs-logging []
    (println "enabled" *debug-enabled*))

(should-print #"(?s)Calling.*true.*Back"
  ;
  (def ^:dynamic *debug-enabled* false)

  (defn debug [msg]
    (if *debug-enabled*
      (println msg)))

  (binding [*debug-enabled* true]
    (debug "Calling that darned function")
    (some-troublesome-function-that-needs-logging)
    (debug "Back from that darned function"))
  ;
)


(should-print #"false"
  (binding [*debug-enabled* false]
    (some-troublesome-function-that-needs-logging)))


;; The following code is derived from the Clojure source.

(comment
  ;
  (def ^:dynamic
     ^{:doc "*print-length* controls how many items of each collection the
      printer will print. If it is bound to logical false, there is no
      limit. Otherwise, it must be bound to an integer indicating the maximum
      number of items of each collection to print. If a collection contains
      more items, the printer will print items up to the limit followed by
      '...' to represent the remaining items. The root binding is nil
      indicating no limit."
       :added "1.0"}
     *print-length* nil)
    ;
  )

(defn run-your-code [] (str "it is " *print-length*))


(should= "it is "
  ;
  (binding [*print-length* nil]
    (run-your-code))
  ;
)
