;---
; Excerpted from "Getting Clojure",
; published by The Pragmatic Bookshelf.
; Copyrights apply to this code. It may not be used to create training material,
; courses, books, articles, and the like. Contact us if you are in doubt.
; We make no guarantees that this code is fit for any purpose.
; Visit http://www.pragmaticprogrammer.com/titles/roclojure for more book information.
;---
;; Lazy Sequences

(require '[testsupport :refer :all])


;
(def jack "All work and no play makes Jack a dull boy.")

(def text [jack jack jack jack jack jack jack jack jack jack])
;


;
;; Be careful with repeated-text in the REPL.
;; There's a surprise lurking...

(def repeated-text (repeat jack))
;

(should-result [jack jack jack]
  ;
  ;; Returns the "All work..." string.

  (first repeated-text)

  ;; So does this.

  (nth repeated-text 10)

  ;; And this.

  (nth repeated-text 10202)
  ;
)

(def j jack)

(should= [j j j j j j j j j j j j j j j j j j j j ]
  ;
  ;; Twenty dull boys.

  (take 20 repeated-text)
  ;
)

(should=  [1 2 3 1 2 3 1]
  ;
  (take 7 (cycle [1 2 3]))
  ;
)


;
(def numbers (iterate inc 1))
;

(should-result [1 1 2 100 [1 2 3 4 5]]
  ;
  (first numbers)
  ;

  ;
  (nth numbers 0)    ; Returns 1
  (nth numbers 1)    ; Returns 2
  (nth numbers 99)   ; Returns 100.

  (take 5 numbers)   ; Returns (1 2 3 4 5)
  ;
)


;
(def many-nums (take 1000000000 (iterate inc 1)))
;

(should-print "(1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20)\n"
  ;
  (println (take 20 (take 1000000000 (iterate inc 1))))
  ;
)

(should-result [_ [2 4 6 8 10 12 14 16 18 20 22 24 26 28 30 32 34 36 38 40]]
  ;
  (def evens (map #(* 2 %) (iterate inc 1)))

  (take 20 evens)
  ;
)

(should= '(1 2 2 4 3 6 4 8 5 10)
  ;
  ;; Returns (1 2 2 4 3 6 4 8 5 10)

  (take 10 (interleave numbers evens))
  ;
)

;
(def test-books
  [{:author "Bob Jordan", :title "Wheel of Time, Book 1"}
   {:author "Jane Austen", :title "Wheel of Time, Book 2"}
   {:author "Chuck Dickens", :title "Wheel of Time, Book 3"}
   {:author "Leo Tolstoy", :title "Wheel of Time, Book 4"}
   {:author "Bob Poe", :title "Wheel of Time, Book 5"}
   {:author "Jane Jordan", :title "Wheel of Time, Book 6"}
   {:author "Chuck Austen", :title "Wheel of Time, Book 7"}])
;

;
(def numbers [1 2 3])

(def trilogy (map #(str "Wheel of Time, Book " % ) numbers))
;

(def expected-trilogy (quote
  ;
  ("Wheel of Time, Book 1"
   "Wheel of Time, Book 2"
   "Wheel of Time, Book 3")
  ;
))

;

(should= expected-trilogy trilogy)

;
(def numbers (iterate inc 1))

(def titles (map #(str "Wheel of Time, Book " % ) numbers))
;

(should= expected-trilogy (take 3 titles))
(should= "Wheel of Time, Book 857" (nth titles 856))

;
(def first-names ["Bob" "Jane" "Chuck" "Leo"])
;

(def cycle-fn
  ;
  (cycle first-names)
  ;
)

(should= ["Bob" "Jane" "Chuck" "Leo" "Bob"] (take 5 cycle-fn))

;
(def last-names ["Jordan" "Austen" "Dickens" "Tolstoy" "Poe"])
;

(def cycle-ln
  ;
  (cycle last-names)
  ;
)

(should= ["Jordan" "Austen" "Dickens" "Tolstoy" "Poe" "Jordan"]
         (take 6 cycle-ln))


;
(defn combine-names [fname lname]
  (str fname " " lname))
;

(should= "John Smith" (combine-names "John" "Smith"))

;
(def authors
  (map combine-names
    (cycle first-names)
    (cycle last-names)))
;


(should= "Bob Jordan" (first authors))
(should= "Jane Austen" (second authors))
(should= "Chuck Austen" (nth authors 6))

;
(defn make-book [title author]
   {:author author :title title})

(def test-books (map make-book titles authors))
;

(should= {:title "Wheel of Time, Book 1" :author "Bob Jordan"}
         (first test-books))

(should= [1 2 3]
  ;
  (lazy-seq [1 2 3])
  ;
)

;
(defn chatty-vector []
  (println "Here we go!")
  [1 2 3])
;

(should= [1 2 3] (chatty-vector))
(should-print #"Here we go" (chatty-vector))

(should-print ""
  ;
  ;; No output when we do this.

  (def s (lazy-seq (chatty-vector)))
  ;
)

(should-print #"Here we go"
  ;
  ;; This will cause "Here we go!" to print.

  (first s)
  ;
)

;
;; Note that the real `repeat` has a couple of arities
;; that we won't bother to implement here.

(defn my-repeat [x]
  (cons x (lazy-seq (my-repeat x))))
;

(assert= (take 5 (my-repeat :x)) [:x :x :x :x :x])


;
(defn my-iterate [f x]
  (cons x (lazy-seq (my-iterate f (f x)))))
;

(assert= (take 5 (my-iterate inc 1)) [1 2 3 4 5])

;
(defn my-map [f col]
  (when-not (empty? col)
    (cons (f (first col))
             (lazy-seq (my-map f (rest col))))))
;

(assert= [2 4 6] (my-map (partial * 2) [1 2 3]))

;
(def chapters (take 10 (map slurp (map #(str "chap" % ".txt") numbers))))
;

(println (doall chapters))

(def the-result '("Chap 1\n" "Chap 2\n" "Chap 3\n" "Chap 4\n" "Chap 5\n"
   "Chap 6\n" "Chap 7\n" "Chap 8\n" "Chap 9\n" "Chap 10\n"))

(should=  the-result
  ;
  ;; Read the chapters NOW!

  (doall chapters)
  ;
)


(should-print #"(?s)The.*Chap 1.*Chap 10"
  ;
  ;; Read the chapters NOW!

  (doseq [c chapters]
    (println "The chapter text is" c))
  ;
)

(comment
  ;
  (repeatedly #(transport/recv transport timeout))
  ;
)

(comment
  ;
  ;; Say goodnight.

  (count (iterate inc 0))
;
)
