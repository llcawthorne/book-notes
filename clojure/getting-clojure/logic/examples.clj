;---
; Excerpted from "Getting Clojure",
; published by The Pragmatic Bookshelf.
; Copyrights apply to this code. It may not be used to create training material,
; courses, books, articles, and the like. Contact us if you are in doubt.
; We make no guarantees that this code is fit for any purpose.
; Visit http://www.pragmaticprogrammer.com/titles/roclojure for more book information.
;---
;; Logic

(ns user
    (:require [testsupport :refer :all]))

;
(defn print-greeting [preferred-customer]
  (if preferred-customer
    (println "Welcome back to Blotts Books!")))
;

(should-print "Welcome back to Blotts Books!\n" (print-greeting true))
(should-print "" (print-greeting false))


;
(defn print-greeting [preferred-customer]
 (if preferred-customer
   (println "Welcome back to Blotts Books!")
   (println "Welcome to Blotts Books!")))
;

(should-print "Welcome back to Blotts Books!\n" (print-greeting true))
(should-print "Welcome to Blotts Books!\n" (print-greeting false))

;
(defn shipping-charge [preferred-customer order-amount]
  (if preferred-customer
    0.00
    (* order-amount 0.10)))
;

(should= (shipping-charge true 100) 0.0)

(def preferred-customer true)
(should= "So nice to have you back!"
  ;
  (if preferred-customer
    "So nice to have you back!")
  ;
)


(should= "So nice to have you back!"
  ;
  (if preferred-customer "So nice to have you back!")
  ;
)

(should-result [true true false true]
  ;
  (= 1 1)                           ; True!

  (= 2 (+ 1 1))                     ; True again!

  (= "Anna Karenina" "Jane Eyre")   ; Nope.

  (= "Emma" "Emma")                 ; Yes!
  ;
)

(should-result [true false]
  ;
  (= (+ 2 2) 4 (/ 40 10) (* 2 2) (- 5 1))  ; True!

  (= 2 2 2 2 3 2 2 2 2 2) ; False! There's a 3 in there.
  ;
)

(should-result [true false]
  ;
  (not= "Anna Karenina" "Jane Eyre")     ; Yes!
  (not= "Anna Karenina" "Anna Karenina") ; No!
  ;
)


(def a 10)
(def b 11)
(def c 22)

(should-print "b is smaller than c\n"
  ;
  (if (> a b)
    (println "a is bigger than b"))

  (if (< b c)
    (println "b is smaller than c"))
  ;
)

(should-result [true false true false true false true false true]
  ;
  (number? 1984)             ; Yes!
  (number? "Anna Karenina")  ; "Anna Karenina" isn't a number.
  (string? "Anna Karenina")  ; Yes, it is a string.
  (keyword? "Anna Karenina") ; Not a keyword.
  (keyword? :anna-karenina)  ; Yes a keyword.
  (map? :anna-karenina)      ; Not a map.
  (map? {:title 1984})       ; Yes!
  (vector? 1984)             ; Nope.
  (vector? [1984])           ; Yes!
  ;
)

;
;; Charge extra if it's an express order or oversized
;; and they are not a preferred customer.

(defn shipping-surcharge? [preferred-customer express oversized]
  (and (not preferred-customer) (or express oversized)))
;

(should  (shipping-surcharge? false true true))
(should  (shipping-surcharge? false true false))
(should  (shipping-surcharge? false false true))
(should  (not(shipping-surcharge? false false false)))
(should (not (shipping-surcharge? true true true)))
(should (not (shipping-surcharge? true true false)))
(should (not (shipping-surcharge? true false true)))
(should (not (shipping-surcharge? true false false)))

(should= "I like science fiction!"
  ;
  (if 1
    "I like science fiction!"
    "I like mysteries!")
  ;
)

(should= "I like science fiction!"
  ;
  (if "hello"
    "I like science fiction!"
    "I like mysteries!")
  ;
)

(should= "I like science fiction!"
  ;
  (if [1 2 3]
    "I like science fiction!"
    "I like mysteries!")
  ;
)

(should= "I like mysteries!"
  ;
  (if false "I like scifi!" "I like mysteries!")  ; Mysteries!
  ;
)

(should= "I like mysteries!"
  ;
  (if nil "I like scifi!" "I like mysteries!")    ; Mysteries!
  ;
)

(should-result ["yes" "yes" "yes" "yes" "yes" "yes" "yes" "yes"])
  ;
  (if 0 "yes" "no")       ; Zero's not nil or false so "yes".
  (if 1 "yes" "no")       ; 1 isn't nil or false so "yes".
  (if 1.0 "yes" "no")     ; 1.0 isn't false nor nil: "yes".
  (if :russ "yes" "no")   ; Keywords aren't false or nil so "yes".
  (if "Russ" "yes" "no")  ; "yes" again.
  (if "true" "yes" "no")  ; String contents don't matter: "yes".
  (if "false" "yes" "no") ; The string "false" isn't false: "yes".
  (if "nil" "yes" "no")   ; And the string "nil" ain't nil: "yes".
  ;


(def result (with-out-str
  ;
  (if [] (println "An empty vector is true!"))
  (if [1 2 3] (println "So is a populated vector!"))

  (if {} (println "An empty map is true!"))
  (if {:title "Make Room! Make Room!" }
    (println "So is a full map!"))

  (if () (println "An empty list is true!"))
  (if '(:full :list) (println "So is a full list!"))
  ;
))

(should-match #"(s?)empty vector" result)

(should= 44
  ;
  (do
    (println "This is four expressions.")
    (println "All grouped together as one")
    (println "That prints some stuff and then evaluates to 44")
    44)
  ;
)


;
(defn shipping-charge[preferred-customer order-amount]
 (if preferred-customer
   (do
     (println "Preferred customer, free shipping!")
     0.0)
   (do
     (println "Regular customer, charge them for shipping.")
     (* order-amount 0.10))))
;

(should-print #"Preferred" (shipping-charge true 1.00))
(should-print #"Regular" (shipping-charge false 1.00))

(should= (shipping-charge true 1.00) 0.0)
(should= (shipping-charge false 1.00) 0.10)

(let [prefered-customer true]
  (should-print #"(?s)Hello.*Welcome"
    ;
    (when preferred-customer
      (println "Hello returning customer!")
      (println "Welcome back to Blotts Books!"))
    ;
))

;
(defn shipping-charge [preferred-customer order-amount]
  (if preferred-customer
    0.0
    (if (< order-amount 50.0)
      5.0
      (if (< order-amount 100.0)
        10.0
        (* 0.1 order-amount)))))
;

(should= (shipping-charge true 1000) 0.0)
(should= (shipping-charge nil 1) 5.0)
(should= (shipping-charge nil 90) 10.0)
(should= (shipping-charge nil 2000) 200.0)

;
(defn shipping-charge [preferred-customer order-amount]
  (cond
    preferred-customer 0.0
    (< order-amount 50.0) 5.0
    (< order-amount 100.0) 10.0))
;

(should= (shipping-charge true 1000) 0.0)
(should= (shipping-charge nil 1) 5.0)
(should= (shipping-charge nil 90) 10.0)


;
(defn shipping-charge [preferred-customer order-amount]
  (cond
    preferred-customer 0.0
    (< order-amount 50.0) 5.0
    (< order-amount 100.0) 10.0
    (>= order-amount 100.0) (* 0.1 order-amount)))
;

(should= (shipping-charge true 1000) 0.0)
(should= (shipping-charge nil 1) 5.0)
(should= (shipping-charge nil 90) 10.0)
(should=  (shipping-charge nil 2000) 200.0)

;
(defn shipping-charge [preferred-customer order-amount]
  (cond
    preferred-customer 0.0
    (< order-amount 50.0) 5.0
    (< order-amount 100.0) 10.0
    :else (* 0.1 order-amount)))
;

(should= (shipping-charge true 1000) 0.0)
(should= (shipping-charge nil 1) 5.0)
(should= (shipping-charge nil 90) 10.0)
(should= (shipping-charge nil 2000) 200.0)


;
(defn customer-greeting [status]
  (case status
    :gold       "Welcome, welcome, welcome back!!!"
    :preferred  "Welcome back!"
                "Welcome to Blotts Books"))
;

(should-match #"Wel.*wel" (customer-greeting :gold))
(should-match #"Welcome back!" (customer-greeting :preferred))
(should-match #"Welcome to" (customer-greeting :anybody))

(defn publish-book [b] (/ 0 0))

(def book {:title "Emma"})

;
(try
  (publish-book book)
  (catch ArithmeticException e (println "Math problem."))
  (catch StackOverflowError e (println "Unable to publish..")))
;


;
(defn publish-book [book]
  (when (not (:title book))
    (throw
      (ex-info "A book needs a title!" {:book book})))

  ;; Lots of publishing stuff...
  )
;

(should-throw (publish-book {}))

(comment
    ;
    (when (real-directory? f)
      (doseq [child (.listFiles f)]
        (delete-file-recursively child silently)))
    ;
)

(comment
  ;
  (if (.isDirectory entry)
    (.mkdirs f)
    (do (.mkdirs (.getParentFile f))
        (io/copy (.getInputStream jar entry) f)))
  ;
)

(comment
  ;
  (if (vector? task) task [task])
  ;
)

(def task 1)

;
(def task-vector (if (vector? task) task [task]))
;

(should= task-vector [1])

;
(defn ensure-task-is-a-vector [task]
  (if (vector? task) task [task]))
;

(should= (ensure-task-is-a-vector 33) [33])
(should= (ensure-task-is-a-vector [:foo]) [:foo])

(defn map-val [x] "map")
(defn field-str [x] "fld")
(defn coll-str [x] "col")
(defn parameterize [x] "parm")

;
(defn str-value [v]
  (cond
    (map? v) (map-val v)
    (keyword? v) (field-str v)
    (nil? v) "NULL"
    (coll? v) (coll-str v)
    :else (parameterize v)))
;

(should= "map" (str-value {}))
(should= "fld" (str-value :keywd))
(should= "col" (str-value '(1 2 3)))
(should= "NULL" (str-value nil))
(should= "parm" (str-value 1.23))

(comment
  ;
  (case (:type query)
    :insert (update-in query [:values] #(map prep-fn %))
    :update (update-in query [:set-fields] prep-fn)
    query)
  ;
)

(should-result [1984 "Emma" nil]
  ;
  (and true 1984)         ; Evaluates to 1984, which is truthy.
  (and 2001 "Emma")       ; Evaluates to "Emma", again truthy.
  (and 2001 nil "Emma")   ; Evaluates to nil, which is falsy.
  ;
)

  (def some-predicate? even?)
  (def some-argument 44)
  (defn some-other-function [] 888)

(should= 888
  ;
  (if (= (some-predicate? some-argument) true)
    (some-other-function))
  ;
)


;
(defn shipping-charge [preferred-customer order-amount]
  (cond
    preferred-customer 0.0
    (< order-amount 50.0) 5.0
    (< order-amount 100.0) 10.0
    :else (* 0.1 order-amount)))  ; Close, close, close.
;

(should= (shipping-charge true 1000) 0.0)
(should= (shipping-charge nil 1) 5.0)
(should= (shipping-charge nil 90) 10.0)
(should= (shipping-charge nil 2000) 200.0)


;
(defn shipping-charge [preferred-customer order-amount]
  (cond
    preferred-customer 0.0
    (< order-amount 50.0) 5.0
    (< order-amount 100.0) 10.0
    :else (* 0.1 order-amount)   ; No.
  )                              ; No.
)                                ; No!
;

(should= (shipping-charge true 1000) 0.0)
(should= (shipping-charge nil 1) 5.0)
(should= (shipping-charge nil 90) 10.0)
(should= (shipping-charge nil 2000) 200.0)
