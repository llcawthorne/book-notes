;---
; Excerpted from "Getting Clojure",
; published by The Pragmatic Bookshelf.
; Copyrights apply to this code. It may not be used to create training material,
; courses, books, articles, and the like. Contact us if you are in doubt.
; We make no guarantees that this code is fit for any purpose.
; Visit http://www.pragmaticprogrammer.com/titles/roclojure for more book information.
;---
;; Read and Eval

(ns user
  (:require [testsupport :refer :all]))

;
;; Just some data: Note the quote.

'(helvetica times-roman [comic-sans]
  (futura gil-sans
    (courier "All the fonts I have loved!")))
;

;
;; Still just data -- note the quote.

'(defn print-greeting [preferred-customer]
  (if preferred-customer
    (println "Welcome back!")))
;

;
;; Now this is code!

(defn print-greeting [preferred-customer]
  (if preferred-customer
    (println "Welcome back!")))
;

(should-print #"Welcome" (print-greeting true))
(should-print "" (print-greeting false))

(should-result [_ 4]
  ;
  ;; A three element list.
  (def a-data-structure '(+ 2 2))

  ;; The number 4.

  (eval a-data-structure)
  ;
)

(should (list? a-data-structure))
(should= 3 (count a-data-structure))

(ns-unmap *ns* 'print-greeting)


;
;; Bind some-data to a list

(def some-data
  '(defn print-greeting [preferred-customer]
    (if preferred-customer (println "Welcome back!"))))

;; At this point we have some-data defined,
;; but not the print-greeting function.
;; Now let's eval some-data...

(eval some-data)

;; And now print-greeting is defined!

(print-greeting true)
;


(should-print "" (print-greeting nil))
(should-print #"Welcome" (print-greeting true))


(should-result [55 :hello "hello"]
  ;
  (eval 55)      ; Returns the number after 54.
  (eval :hello)  ; Returns the keyword :hello
  (eval "hello") ; And a string.
  ;
)

(should-result [_ _ "For Whom the Bell Tolls" 23]
  ;
  (def title "For Whom the Bell Tolls")

  ;; Get hold of the unevaluated symbol 'title...

  (def the-symbol 'title)

  ;; ...and evaluate it.

  (eval the-symbol)

  ;; While a list gets evaluated as a function call.

  (eval '(count title))
  ;
)

(should-print #"Welcome back!"
  ;
  (def fn-name 'print-greeting)
  (def args (vector 'preferred-customer))
  (def the-println (list 'println "Welcome back!"))
  (def body (list 'if 'preferred-customer the-println))

  (eval (list 'defn fn-name args body))

  (eval (list 'print-greeting true))
  ;
)

;
(ns codetool.core
  (:require [clojure.java.io :as io]))

(defn read-source [path]
  (with-open [r (java.io.PushbackReader. (io/reader path))]
    (loop [result []]
      (let [expr (read r false :eof)]
        (if (= expr :eof)
          result
          (recur (conj result expr)))))))
;

(ns user)

(should= '[(def x 42) (def y 43)]
          (codetool.core/read-source "source.clj"))

;
(defn russ-repl []
  (loop []
    (println (eval (read)))
    (recur)))
;


;
(defn reval [expr]
  (cond
    (string? expr) expr
    (keyword? expr) expr
    (number? expr) expr
    :else :completely-confused))
;

(should= (reval "hello") "hello")
(should= (reval 10) 10)
(should= (reval :foo) :foo)
(should= (reval true) :completely-confused)

(declare eval-symbol eval-vector eval-list)
;
(defn reval [expr]
  (cond
    (string? expr) expr
    (keyword? expr) expr
    (number? expr) expr
    (symbol? expr) (eval-symbol expr)
    (vector? expr) (eval-vector expr)
    (list? expr) (eval-list expr)
    :else :completely-confused))
;

;
(defn eval-symbol [expr]
  (.get (ns-resolve *ns* expr)))
;

;
(defn eval-vector [expr]
  (vec (map reval expr)))
;

;
(defn eval-list [expr]
  (let [evaled-items (map reval expr)
        f (first evaled-items)
        args (rest evaled-items)]
    (apply f args)))
;

(def something 888)

(should= (reval "hello") "hello")
(should= (reval 10) 10)
(should= (reval :foo) :foo)
(should= (reval true) :completely-confused)
(should= (reval 'something) 888)
(should= (reval [1 2 'something]) [1 2 888])
(should= (reval (list '+ 2 2 2)) 6)

;
(defn add2
  "Return the sum of two numbers"
  [a b]
  (+ a b))
;

(should= 6 (add2 1 5))

(def the-meta
  ;
  (meta #'add2)
  ;
)

(should (:doc the-meta))
(should (:name the-meta))
(should (:arglists the-meta))

;
(def books1 (with-meta ["Emma" "1984"] {:favorite-books true}))
;

(should= (meta books1) {:favorite-books true})

;
(def books1 ^:favorite-books ["Emma" "1984"])
;

(should= (meta books1) {:favorite-books true})


;
;; Gives you the {:favorite-books true} map.

(meta books1)
;


;
(def ^:dynamic *print-length* nil)
;


(should-result [_ _ true]
  ;
  ;; Otherwise identical vectors with different metadata...

  (def books2 (with-meta ["Emma" "1984"] {:favorite-books true}))

  (def books3 (with-meta ["Emma" "1984"] {:favorite-books false}))

  ;; Are still equal.

  (= books2 books3)   ; True!
  ;
)

;
(def md (meta books3))
;

(should-result [1 '(false)]
  ;
  ;; Do mapish things to the metadata

  (count md) ; Returns 1
  (vals md)  ; Returns (false)
  ;
)

(should= 2
  ;
  (+ 1 1)
  ;
)

(should= 2
  ;
  (eval '(+ 1 1))
  ;
)

(should-result [_ 2]
  ;
  (def x 1)

  (let [x 10000000]
    (eval '(+ x 1)))
  ;
)

(should-print #"All your bases"
  ;
  (def s "#=(println \"All your bases...\")")

  (read-string s)
  ;
)

(comment
  ;
  (require '[clojure.edn :as edn])

  ;; Read some data that I don't necessarily trust.

  (def untrusted (edn/read))
;
)
