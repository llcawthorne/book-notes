;---
; Excerpted from "Getting Clojure",
; published by The Pragmatic Bookshelf.
; Copyrights apply to this code. It may not be used to create training material,
; courses, books, articles, and the like. Contact us if you are in doubt.
; We make no guarantees that this code is fit for any purpose.
; Visit http://www.pragmaticprogrammer.com/titles/roclojure for more book information.
;---
;; Interoperating with Java

(ns user
  (:require [testsupport :refer :all]))

;
(def authors (java.io.File. "authors.txt"))
;

(should-print #"Our authors"
  ;
  (if (.exists authors)
    (println "Our authors file is there.")
    (println "Our authors file is missing."))
  ;
)

(should-print #"We can"
  ;
  (if (.canRead authors)
    (println "We can read it!"))
  ;
)

;
(.setReadable authors true)
;

;
(def rect (java.awt.Rectangle. 0 0 10 20))
;

(should-print #"(?s)10.*20"
  ;
  (println "Width:" (.-width rect))
  (println "Height:" (.-height rect))
  ;
)

;
;; In the REPL.

(import java.io.File)
;

;
(ns read-authors
  (:import java.io.File))
;

;
(def authors (File. "authors.txt"))
;

;
;; Do this in a .clj file:

(ns read-authors
  (:import (java.io File InputStream)))
;

File
InputStream

;
;; In the REPL.

(import '(java.io File InputStream))
;

;
;; Create a temporary file in the standard temp directory, a file
;; with a name like authors_list8240847420696232491.txt

(def temp-authors-file (File/createTempFile "authors_list" ".txt"))
;

(testsupport/should-match #"authors_list.*txt" (str temp-authors-file))


(comment
  ;
  (defproject exploregson "0.1.0-SNAPSHOT"
    :description "FIXME: write description"
    :url "http://example.com/FIXME"
    :license {:name "Eclipse Public License"
              :url "http://www.eclipse.org/legal/epl-v10.html"}
    :dependencies [[org.clojure/clojure "1.8.0"]
                   [com.google.code.gson/gson "2.8.0"]])
  ;
)

(testsupport/should-result [_ 3]
  ;
  ;; Make a Clojure value which is also a Java object.

  (def v [1 2 3])

  ;; Call a Java method on our Clojure value/Java object.

  (.count v)
  ;
)


(testsupport/should-result [_ _ "Dickens" 'author]
  ;
  (def author "Dickens") ; Make a var.

  (def the-var #'author) ; Grab the var.

  (.get the-var)         ; Pull the value out of the var: "Dickens"
  (.-sym the-var)        ; Pull the symbol out of the var: author
  ;
)

;
(def c (cons 99 [1 2 3]))
;

(testsupport/should= clojure.lang.Cons
  ;
  (class c)     ; clojure.lang.Cons
  ;
)

(testsupport/should-result [99 '(1 2 3)]
  ;
  ;; And call into the Java.

  (.first c)     ; 99
  (.more c)      ; (1 2 3)
  ;
)

(comment
  ;
  ;; Nope. Nope. Nope.

  (def count-method .count)
  ;
)

;
(def files [(File. "authors.txt") (File. "titles.txt")])
;

(testsupport/should-result [[true false]]
  ;
  (map (memfn exists) files)
  ;
)

;
(defn file-exists?
  "Wrap the exists method cause I hate that dot."
  [f]
  (.exists f))

(defn readable?
  "Wrap the canRead method cause I hate camel case."
  [f]
  (.canRead f))
;

(testsupport/should (file-exists? (File. "authors.txt")))
(testsupport/should (not (file-exists? (File. "fkldlj"))))
(testsupport/should (readable? (File. "authors.txt")))
(testsupport/should (not (readable? (File. "fkldlj"))))

;
(def jv-favorite-books (java.util.Vector.))
;

;
(.addElement jv-favorite-books "Emma")
(.addElement jv-favorite-books "Andromeda Strain")
(.addElement jv-favorite-books "2001")
;


;
;; Back in the immutable world!

(def thankfully-immutable-books (vec jv-favorite-books))
;

(testsupport/should=
  thankfully-immutable-books
  ["Emma" "Andromeda Strain" "2001"])
