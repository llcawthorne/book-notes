;---
; Excerpted from "Getting Clojure",
; published by The Pragmatic Bookshelf.
; Copyrights apply to this code. It may not be used to create training material,
; courses, books, articles, and the like. Contact us if you are in doubt.
; We make no guarantees that this code is fit for any purpose.
; Visit http://www.pragmaticprogrammer.com/titles/roclojure for more book information.
;---
;; Hello Clojure

(ns user
  (:require [testsupport :refer :all]))

(should-print "Hello, world!\n"
  ;
  (println "Hello, world!")   ; Say hi.
  ;
)

(should-print "Hello, world!\n"
  ;
  ;; Do two semicolons add up to a whole colon?

  (println "Hello, world!")   ; Say hi
  ;
)

(should-result ["Clojure" "Hello, world!" "3 2 1 Blast off!"]
  ;
  (str "Clo" "jure")                 ; Returns "Clojure".

  (str "Hello," " " "world" "!")     ; Returns the string "Hello, world!"

  (str 3 " " 2 " " 1 " Blast off!")  ; Fly me to the Moon!
  ;
)

(should-result [12 5 0]
  ;
  (count "Hello, world") ; Returns 12.

  (count "Hello")        ; Returns 5.

  (count "")             ; Returns 0.
  ;
)

(should-print "true\nfalse\n"
  ;
  (println true)     ; Prints true...

  (println false)    ; ...and prints false.
  ;
)

(should-print "Nobody's home: nil\n"
  ;
  (println "Nobody's home:" nil)   ; Prints Nobody's home: nil
  ;
)

(should-print "We can print many things: true false nil\n"
  ;
  (println "We can print many things:" true false nil)
  ;
)

(should= 1984
  ;
  (+ 1900 84)
  ;
)

(should-result [1984 1984 1984]
  ;
  (* 16 124)   ; Gives you 1984.
  (- 2000 16)  ; 1984 again.
  (/ 25792 13) ; 1984 yet again!
  ;
)

(should= 1997
  ;
  (/ (+ 1984 2010) 2)
  ;
)

(should= 2001
  ;
  (+ 1000 500 500 1)  ; Evaluates to 2001.
  ;
)

(should= 1984
  ;
  (- 2000 10 4 2)     ; Evaluates to 1984;
  ;
)

(should= 1997.0
  ;
  (/ (+ 1984.0 2010.0) 2.0)
  ;
)

;
(def first-name "Russ")
;

(assert= first-name "Russ")


;
(def the-average (/ (+ 20 40.0) 2.0))
;

(assert= the-average 30.0)

;
(defn hello-world [] (println "Hello, world!"))
;

(should-print "Hello, world!\n"
  ;
  (hello-world)
  ;
)

;
(defn hello-world []
  (println "Hello, world!"))
;

(should-print "Hello, world!\n" (hello-world))

;
(defn say-welcome [what]
  (println "Welcome to" what))
;

(should-print "Welcome to Clojure\n"
  ;
  (say-welcome "Clojure")
  ;
)

(should-result [_ 7.5]
  ;
  ;; Define the average function.

  (defn average [a b]
    (/ (+ a b) 2.0))

  ;; Call average to find the mean of 5.0 & 10.0.

  (average 5.0 10.0)     ; Returns 7.5
  ;
)

;
(defn chatty-average [a b]
  (println "chatty-average function called")
  (println "** first argument:" a)
  (println "** second argument:" b)
  (/ (+ a b) 2.0))
;

(should= 15.0
  ;
  (chatty-average 10 20)
  ;
)

;
(def author "Dickens")

(defn author [name]
  (println "Hey," name "is writing a book!"))
;

(assert (fn? author))

(comment
  ;
  (/ 100 0)
  ;
)

;
chatty-average
;
