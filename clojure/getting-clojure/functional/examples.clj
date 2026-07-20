;---
; Excerpted from "Getting Clojure",
; published by The Pragmatic Bookshelf.
; Copyrights apply to this code. It may not be used to create training material,
; courses, books, articles, and the like. Contact us if you are in doubt.
; We make no guarantees that this code is fit for any purpose.
; Visit http://www.pragmaticprogrammer.com/titles/roclojure for more book information.
;---
;; Functional Things

(ns user
  (:require [testsupport :refer :all]))

;
(def dracula {:title "Dracula"
              :author "Stoker"
              :price 1.99
              :genre :horror})
;

(def book-cheap-adv {:title "adventure" :price 0.01 :genre :adventure})
(def book-exp-adv {:title "adventure" :price 10.00 :genre :adventure})
(def book-cheap-hr {:title "adventure" :price 0.01 :genre :horror})
(def book-exp-hr {:title "adventure" :price 10.00 :genre :horror})

(should-result [_ _ _t _f]
  ;
  (defn cheap? [book]
    (when (<= (:price book) 9.99)
      book))

  (defn pricey? [book]
    (when (> (:price book) 9.99)
      book))

  (cheap? dracula)        ; Yes!
  (pricey? dracula)       ; No!
  ;
)

(should-result [_ _ _t _f]
;
(defn horror? [book]
  (when (= (:genre book) :horror)
    book))

(defn adventure? [book]
  (when (= (:genre book) :adventure)
    book))

(horror? dracula)       ; Yes!
(adventure? dracula)    ; Nope!
;
)

;
(defn cheap-horror? [book]
  (when (and (cheap? book)
             (horror? book))
    book))

(defn pricy-adventure? [book]
  (when (and (pricey? book)
             (adventure? book))
    book))
;

(should (cheap-horror? dracula))
(should (pricy-adventure? {:price 10.00 :genre :adventure}))
(should (not (pricy-adventure? {:price 10.00 :genre :qqq})))
(should (not (pricy-adventure? {:price 9.99 :genre :adventure})))

;
cheap?
;

;
(def reasonably-priced? cheap?)
;

(should (reasonably-priced? dracula))
(should (reasonably-priced? book-cheap-hr))
(should (reasonably-priced? book-cheap-adv))

(should
  ;
  (reasonably-priced? dracula)        ; Yes!
  ;
)

(should-result [_ _f _t]
  ;
  (defn run-with-dracula [f]
    (f dracula))
  ;

  ;
  (run-with-dracula pricey?)      ; Nope.

  (run-with-dracula horror?)      ; Yes!
  ;
)

(should-result [_ _t _f]
  ;
  (defn both? [first-predicate-f second-predicate-f book]
    (when (and (first-predicate-f book)
               (second-predicate-f book))
      book))

  (both? cheap? horror? dracula)     ; Yup!

  (both? pricey? adventure? dracula) ; Nope!
  ;
)

(def ff
  ;
  (fn [n] (* 2 n))
  ;
)

(should= 8 (ff 4))

;
(println "A function:" (fn [n] (* 2 n)))
;

;
(def double-it (fn [n] (* 2 n)))
;

(should= 8 (double-it 4))

(should-result [20 20]
;
(double-it 10)          ; Gives you 20.

((fn [n] (* 2 n)) 10)   ; Also gives you 20.
;
)

(def ff
;
  (fn [book]
    (when (<= (:price book) 9.99)
      book))
;
)

(should (ff dracula))

;
(defn cheaper-f [max-price]
  (fn [book]
    (when (<= (:price book) max-price)
      book)))
;

(should ((cheaper-f 5) dracula))
(should ((cheaper-f 2) dracula))
(should ((cheaper-f 1.99) dracula))
(should (not ((cheaper-f 1.98) dracula)))

(should-result [_ _ _ _f _t _t]
  ;
  ;; Define some helpful functions.

  (def real-cheap? (cheaper-f 1.00))
  (def kind-of-cheap? (cheaper-f 1.99))
  (def marginally-cheap? (cheaper-f 5.99))

  ;; And use them.

  (real-cheap? dracula)          ; Nope.
  (kind-of-cheap? dracula)       ; Yes.
  (marginally-cheap? dracula)    ; Indeed.
  ;
)


;
(defn both-f [predicate-f-1 predicate-f-2]
  (fn [book]
    (when (and (predicate-f-1 book) (predicate-f-2 book))
      book)))
;

;
(def cheap-horror? (both-f cheap? horror?))

(def real-cheap-adventure? (both-f real-cheap? adventure?))

(def real-cheap-horror? (both-f real-cheap? horror?))
;

(should (cheap-horror? dracula))
(should (real-cheap-adventure? {:price 0.01 :genre :adventure}))
(should (not (real-cheap-adventure? {:price 99.01 :genre :adventure})))
(should (not (real-cheap-adventure? {:price 0.01 :genre :qqq})))
(should (not (real-cheap-horror? {:price 0.01 :genre :adventure})))

;
(def cheap-horror-possession?
  (both-f cheap-horror?
    (fn [book] (= (:title book) "Possession"))))
;

(should (not (cheap-horror-possession? {:title "ABC" :price 0.01 :genre :horror})))
(should (cheap-horror-possession? {:title "Possession" :price 0.01 :genre :horror}))
(should (not (cheap-horror-possession? {:title "Possession" :price 99.01 :genre :horror})))

(should= 10
  ;
  (+ 1 2 3 4)          ; Gives you 10.
  ;
)

;
(def the-function +)
(def args [1 2 3 4])
;

(should= 10
  ;
  (apply the-function args)   ; (the-function args0 args1 args2 ...)
  ;
)

;
(def v ["The number " 2 " best selling " "book."])
;

(should= "The number 2 best selling book."
  ;
  ;; More or less the same as:
  ;; (str "The number " 2 " best selling " "book.")

  (apply str v)
  ;
)

(should= (list "The number " 2 " best selling " "book.")
  ;
  ;; More or less the same as:
  ;; (list "The number " 2 " best selling " "book.")

  (apply list v)
  ;
)

(should= ["The number " 2 " best selling " "book."]
  ;
  (apply vector (apply list v))
  ;
)


;
(defn my-inc [n] (+ 1 n))
;


(should= (my-inc 3) 4)


;
(def my-inc (partial + 1))
;

(should= (my-inc 3) 4)

;
(defn cheaper-than [max-price book]
  (when (<= (:price book) max-price)
    book))

(def real-cheap? (partial cheaper-than 1.00))
(def kind-of-cheap? (partial cheaper-than 1.99))
(def marginally-cheap? (partial cheaper-than 5.99))
;

(should (not (real-cheap? dracula)))
(should (kind-of-cheap? dracula))
(should (marginally-cheap? dracula))
(should (real-cheap? book-cheap-hr))
(should (real-cheap? book-cheap-adv))


;
(defn adventure? [book]
  (when (= (:genre book) :adventure)
    book))
;

(should (adventure? book-cheap-adv))
(should (not (adventure? book-cheap-hr)))


;
(defn not-adventure? [book] (not (adventure? book)))
;

(should (not-adventure? book-cheap-hr))
(should (not (not-adventure? book-cheap-adv)))


;
(def not-adventure? (complement adventure?))
;

(should (not-adventure? book-cheap-hr))
(should (not (not-adventure? book-cheap-adv)))

;
(def cheap-horror? (every-pred cheap? horror?))
;

(should (cheap-horror? dracula))

;
(def cheap-horror-possession?
  (every-pred
    cheap?
    horror?
    (fn [book] (= (:title book) "Possession"))))
;

(should (not
  (cheap-horror-possession? {:title "ABC" :price 0.01 :genre :horror})))
(should
  (cheap-horror-possession? {:title "Possession" :price 0.01 :genre :horror}))
(should
  (not
    (cheap-horror-possession? {:title "Possession" :price 99.01 :genre :horror})))

(def ff
  ;
  #(when (= (:genre %1) :adventure) %1)
  ;
)

(should  (ff book-cheap-adv))

(def ff
  ;
  #(* 2 %1)
  ;
)

(should= 8 (ff 4))

(def ff
  ;
  #(+ %1 %2 %3)
  ;
)

(should= (ff 1 2 3) 6)

(def ff
  ;
  #(* 2 %11)
  ;
)

(should= 22 (ff 1 2 3 4 5 6 7 8 9 10 11))

(def ff
  ;
  #(* % 2)
  ;
)

(should= (ff 7) 14)

;
(defn say-welcome [what]
  (println "Welcome to" what "!"))
;

(should-print #"Welcome to Philly" (say-welcome "Philly"))

;
(def say-welcome
  (fn [what] (println "Welcome to" what "!")))
;

(should-print #"Welcome to Philly" (say-welcome "Philly"))


;
;; Start with 1,000 copies sold.

(def book {:title "Emma" :copies 1000})

;; Now we have 1,001.

(def new-book (update book :copies inc))
;

(should= (:copies new-book) 1001)

;
(def by-author
  {:name "Jane Austen"
   :book {:title "Emma" :copies 1000}})

(def new-by-author (update-in by-author [:book :copies] inc))
;

(should= (-> new-by-author :book :copies) 1001)


;
(defn execute-that-function-three-times [your-function]
  (your-function)
  (your-function)
  (your-function))
;

(def _count (atom 0))

(execute-that-function-three-times #(swap! _count inc))

(should= @_count 3)

;
(defn execute-that-function-later [your-function]
  (Thread/sleep 372)      ; Pause for 372 ms.
  (your-function))
;

(execute-that-function-later #(swap! _count inc))

(should= @_count 4)

;
(defn execute-that-function-never [your-function]
  (+ 2 2))
;

(execute-that-function-never #(swap! _count inc))

(should= @_count 4)
;
(defn some-odd-combination [your-function]
  (execute-that-function-three-times
    #(execute-that-function-later your-function)))
;

(some-odd-combination #(swap! _count inc))
(should= @_count 7)
