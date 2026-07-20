;---
; Excerpted from "Getting Clojure",
; published by The Pragmatic Bookshelf.
; Copyrights apply to this code. It may not be used to create training material,
; courses, books, articles, and the like. Contact us if you are in doubt.
; We make no guarantees that this code is fit for any purpose.
; Visit http://www.pragmaticprogrammer.com/titles/roclojure for more book information.
;---
;; Sequences

(ns user
  (:require [testsupport :refer :all]))


(defn list-specific-count [c] :list)
(defn vector-specific-count [c] :vector)
(defn set-specific-count [c] :set)
(defn map-specific-count [c] :map)

;
;; Is this how count is implemented?

(defn flavor [x]
  (cond
    (list? x) :list
    (vector? x) :vector
    (set? x) :set
    (map? x) :map
    (string? x) :string
    :else :unknown))

(defmulti my-count flavor)

(defmethod my-count :list [x] (list-specific-count x))

(defmethod my-count :vector [x] (vector-specific-count x))

;; And so on...
;

(should= :list (my-count '(1 2 3)))
(should= :vector (my-count [1]))

;
(def title-seq (seq ["Emma" "Oliver Twist" "Robinson Crusoe"]))
;

(should (seq? title-seq))
(should= 3 (count title-seq))


(def result
  ;
  (seq '("Emma" "Oliver Twist" "Robinson Crusoe"))
  ;
 )

(should (seq? result))
(should= 3 (count result))

(def result
  ;
  (seq {:title "Emma", :author "Austen", :published 1815})
  ;
)

(should (seq? result))
(should= 3 (count result))

(def the-seq (quote
  ;
  ([:title "Emma"] [:author "Austen"] [:published 1815])
  ;
))

(should= the-seq result)

(def result
  ;
  ;; Calling seq on a sequence is a noop.

  (seq (seq ["Red Queen" "The Nightingale" "Uprooted"]))
  ;
)

(should (seq? result))
(should= 3 (count result))


(should-result [nil nil nil]
  ;
  (seq [])   ; Gives you nil.
  (seq '())  ; Also nil.
  (seq {})   ; Nil again.
  ;
)


(should= "Emma"
  ;
  ;; Returns "Emma".

  (first (seq '("Emma" "Oliver Twist" "Robinson Crusoe")))
  ;
)

(should= '("Oliver Twist" "Robinson Crusoe")
  ;
  ;; Returns the sequence ("Oliver Twist" "Robinson Crusoe")

  (rest  (seq '("Emma" "Oliver Twist" "Robinson Crusoe")))
  ;
)

;
(cons "Emma" (seq '("Oliver Twist" "Robinson Crusoe")))
;

;
(defn my-count [col]
  (let [the-seq (seq col)]
    (loop [n 0 s the-seq]
      (if (seq s)
        (recur (inc n) (rest s))
        n))))
;

(should= 0 (my-count nil))

(should= 0 (my-count []))
(should= 1 (my-count [1]))
(should= 3 (my-count [1 2 3]))

(should= 0 (my-count ()))
(should= 1 (my-count '(1)))
(should= 3 (my-count '(1 2 3)))

(should= 0 (my-count {}))
(should= 1 (my-count {:aa 1}))
(should= 3 (my-count {:aa 1 :bb 2 :cc 3}))

(should= 0 (my-count #{}))
(should= 2 (my-count #{:aa :bb}))

(def result [
  ;
  (rest [1 2 3])                          ; A sequence!
  (rest {:fname "Jane" :lname "Austen"})  ; Another sequence.
  (next {:fname "Jane" :lname "Austen"})  ; Yet another sequence.

  ;
  ;
  (cons 0 [1 2 3])                        ; Still another.
  (cons 0 #{1 2 3})                       ; And another.
  ;
])

(should (every? seq? result))

(should-result [_ '("2001" "Dracula" "Emma" "Jaws")]
  ;
  (def titles ["Jaws" "Emma" "2001" "Dracula"])

  (sort titles) ; Sequence: ("2001" "Dracula" "Emma" "Jaws")
  ;
)

(should= '("Dracula" "2001" "Emma" "Jaws")
  ;
  ;; A Sequence: ("Dracula" "2001" "Emma" "Jaws")

  (reverse titles)
  ;
)

(should= '("Jaws" "Emma" "Dracula" "2001")
  ;
  ;; A Sequence: ("Jaws" "Emma" "Dracula" "2001")

  (reverse (sort titles)) ;
  ;
)

(def the-result (quote
  ;
  (("Jaws" "Benchley") ("2001" "Clarke"))
  ;
))

(should-result [_ the-result]
  ;
  (def titles-and-authors ["Jaws" "Benchley" "2001" "Clarke"])

  (partition 2 titles-and-authors)
  ;
)



(should-result [_ _ '("Jaws" "Benchley" "2001" "Clarke")]
  ;
  ;; A vector of titles and a list of authors.

  (def titles  ["Jaws" "2001"])
  (def authors '("Benchley" "Clarke"))

  ;; Combine the authors and titles into a single sequence
  ;; ("Jaws" "Benchley" "2001" "Clarke")

  (interleave titles authors)
  ;
)

(should-result [_ '("Lions" "and" "Tigers" "and" "Bears")]
  ;
  ;; Gives us ("Lions" "and" "Tigers" "and" "Bears")
  ;; Oh my!

  (def scary-animals ["Lions" "Tigers" "Bears"])

  (interpose "and" scary-animals)
  ;
)

(should= '(-22 -99 -77)
  ;
  ;; Returns the sequence (-22 -99 -77)

  (filter neg? '(1 -22 3 -99 4 5 6 -77))
  ;
)


;
(def books
  [{:title "Deep Six" :price 13.99 :genre :sci-fi :rating 6}
   {:title "Dracula" :price 1.99 :genre :horror :rating 7}
   {:title "Emma" :price 7.99 :genre :comedy :rating 9}
   {:title "2001" :price 10.50 :genre :sci-fi :rating 5}])
;

;
(defn cheap? [book]
  (when (<= (:price book) 9.99)
    book))
;

(should (cheap? {:price 9.00}))
(should (cheap? {:price 9.99}))

(should (not (cheap? {:price 10.00})))

(def cheap-1
  ;
  (filter cheap? books)
  ;
)

(def cheap-2 (quote
  ;
  ({:genre :horror, :title "Dracula", :price 1.99 :rating 7}
   {:genre :comedy, :title "Emma", :price 7.99 :rating 9})
  ;
))

(should= cheap-1 cheap-2)

(should
  ;
  (some cheap? books)
  ;
)

(should-print #"cheap books for sale"
  ;
  (if (some cheap? books)
    (println "We have cheap books for sale!"))
  ;
)

;
(def some-numbers [1, 53, 811])
;

;
(def doubled (map #(* 2 %) some-numbers))
;

(should= doubled '(2 106 1622))

(should= ["Deep Six"  "Dracula" "Emma" "2001" ]
  ;
  (map (fn [book] (:title book)) books)
  ;
)

(should= ["Deep Six"  "Dracula" "Emma" "2001" ]
  ;
  ;; Turn the collection of books into a collection of titles.
  ;; The easy way!

  (map :title books)
  ;
)

(should= [8 7 4 4]
  ;
  (map (fn [book] (count (:title book))) books)
  ;
)

(should= [8 7 4 4]
  ;
  (map (comp count :title) books)
  ;
)


(should= [8 7 4 4]
  ;
  (for [b books]
    (count (:title b)))
  ;
)

;
(def numbers [10 20 30 40 50])
;

(should-result [_ 150]
  ;
  (defn add2 [a b]
    (+ a b))

  (reduce add2 0 numbers)
  ;
)

(should-result [_ 150]
  ;
  (reduce + 0 numbers)
  ;
)

(should-result [_ 150]
  ;
  (reduce + numbers)
  ;
)

(should-result [_ 13.99]
  ;
  (defn hi-price [hi book]
    (if (> (:price book) hi)
      (:price book)
      hi))

  (reduce hi-price 0 books)
  ;
)

(def top-titles-s
  ;
  "Emma // Dracula // Deep Six"
  ;
)

;
(sort-by :rating books)
;

;
(reverse (sort-by :rating books))
;

;
(take 3 (reverse (sort-by :rating books)))
;

;
(map :title (take 3 (reverse (sort-by :rating books))))
;

(should= '("Emma" " // " "Dracula" " // " "Deep Six")
  ;
  (interpose
    " // "
    (map :title (take 3 (reverse (sort-by :rating books)))))
  ;
)

;
(defn format-top-titles [books]
  (apply
    str
    (interpose
      " // "
      (map :title (take 3 (reverse (sort-by :rating books)))))))
;

(should= top-titles-s (format-top-titles books))

;
(require '[clojure.java.io :as io])

(defn listed-author? [author]
  (with-open [r (io/reader "authors.txt")]
    (some (partial = author) (line-seq r))))
;

(should (listed-author? "King"))
(should (not (listed-author? "XXXX")))


(should-print #"classic"
  ;
  ;; A regular expression that matches Pride and Prejudice followed by anything.

  (def re #"Pride and Prejudice.*")

  ;; A string that may or may not match.

  (def title "Pride and Prejudice and Zombies")

  ;; And we have a classic!
  (if (re-matches  re title)
      (println "We have a classic!"))
  ;
)

(should= '("Pride" "and" "Prejudice" "and" "Zombies")
  ;
  (re-seq #"\w+" title)
  ;
)

(def level 1)
(def sustain 2)
(def bias 100)

(should= [100 100 101 102 100]
  ;
  (map #(+ %1 bias) [0 0 level (* level sustain) 0])
  ;
)

(should= [100 100 101 102 100]
  ;
  (for [v [0 0 level (* level sustain) 0]] (+ v bias))
  ;
)

;
(defn seq->js-array [v]
  (str "[" (apply str (interpose ", " (map pr-str v))) "]"))
;

(should= "[1, 2, 3]" (seq->js-array [1 2 3]))

;
(defn format-top-titles [books]
  (->>
    books
    (sort-by :rating)
    reverse
    (take 3)
    (map :title)
    (interpose " // ")
    (apply str)))
;

(should= top-titles-s (format-top-titles books))

;
(defn total-sales [books]
  "Total up book sales. Books maps must have :sales key."
  (loop [books books total 0]
    (if (empty? books)
      total
      (recur (next books)
             (+ total (:sales (first books)))))))
;

(def the-sales [{:sales 100} {:sales 200} {:sales 300}])

(should= 600 (total-sales the-sales))
(should= 0 (total-sales []))

;
(defn total-sales [books] (apply + (map :sales books)))
;

(should= 600 (total-sales the-sales))
(should= 0 (total-sales []))

(should-result [_ "Dashner" nil]
  ;
  (def maze-runner {:title "The Maze Runner" :author "Dashner"})

  ; Gives you back "Dashner"

  (:author maze-runner)

  ; But this give you a nil - a seq is not a map!

  (:author (seq maze-runner))
  ;
)

(should= nil
  ;
  (:author (rest maze-runner)) ; Also nil: rest returns a seq.
  ;
)

(def l-starts-jaws '("Jaws" "Emma" "1984" "The Maze Runner"))

(should-result [["Emma" "1984" "The Maze Runner" "Jaws"]
                l-starts-jaws]
  ;
  ;; A *vector* ending with "Jaws".

  (conj ["Emma" "1984" "The Maze Runner"] "Jaws")

  ;; A *list* starting with "Jaws".

  (conj '("Emma" "1984" "The Maze Runner") "Jaws")
  ;
)

(mdef [s1 s2]
  ;
  ;; A *seq* starting with "Jaws".

  (cons "Jaws" ["Emma" "1984" "The Maze Runner"])

  ;; A *seq* starting with "Jaws".

  (cons "Jaws" '("Emma" "1984" "The Maze Runner"))
  ;
)

(should= l-starts-jaws s1)
(should (seq? s1))

(should= l-starts-jaws s2)
(should (seq? s2))
