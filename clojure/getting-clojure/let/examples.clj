;---
; Excerpted from "Getting Clojure",
; published by The Pragmatic Bookshelf.
; Copyrights apply to this code. It may not be used to create training material,
; courses, books, articles, and the like. Contact us if you are in doubt.
; We make no guarantees that this code is fit for any purpose.
; Visit http://www.pragmaticprogrammer.com/titles/roclojure for more book information.
;---
;; Let

(ns user
  (:require [testsupport :refer :all]))

;
(defn compute-discount-amount [amount discount-percent min-charge]
  (if (> (* amount (- 1.0 discount-percent)) min-charge)
    (* amount (- 1.0 discount-percent))
    min-charge))
;


(should= (compute-discount-amount 10.0 0.50 1.0) 5.0)
(should= (compute-discount-amount 10.0 0.50 2.0) 5.0)
(should= (compute-discount-amount 10.0 0.50 4.0) 5.0)
(should= (compute-discount-amount 10.0 0.50 5.0) 5.0)
(should= (compute-discount-amount 10.0 0.50 6.0) 6.0)
(should= (compute-discount-amount 10.0 0.50 10.0) 10.0)


;
;; Don't do this!

(defn compute-discount-amount [amount discount-percent min-charge]
  (def discounted-amount (* amount (- 1.0 discount-percent)))   ; NOOOOO!
  (if (> discounted-amount min-charge)
    discounted-amount
    min-charge))
;

(should= (compute-discount-amount 10.0 0.50 1.0) 5.0)
(should= (compute-discount-amount 10.0 0.50 2.0) 5.0)
(should= (compute-discount-amount 10.0 0.50 4.0) 5.0)
(should= (compute-discount-amount 10.0 0.50 5.0) 5.0)
(should= (compute-discount-amount 10.0 0.50 6.0) 6.0)
(should= (compute-discount-amount 10.0 0.50 10.0) 10.0)


;
;; A nasty side effect is brewing here.

(def discounted-amount "Some random string.")

(compute-discount-amount 10.0 0.20 1.0)

discounted-amount   ; Is now 8.00
;

(should= discounted-amount 8.00)

;
;; Do use let!

(defn compute-discount-amount [amount discount-percent min-charge]
  (let [discounted-amount (* amount (- 1.0 discount-percent))]
    (if (> discounted-amount min-charge)
      discounted-amount
      min-charge)))
;

(should= (compute-discount-amount 10.0 0.50 1.0) 5.0)
(should= (compute-discount-amount 10.0 0.50 2.0) 5.0)
(should= (compute-discount-amount 10.0 0.50 4.0) 5.0)
(should= (compute-discount-amount 10.0 0.50 5.0) 5.0)
(should= (compute-discount-amount 10.0 0.50 6.0) 6.0)
(should= (compute-discount-amount 10.0 0.50 10.0) 10.0)


;
(defn compute-discount-amount [amount discount-percent min-charge]
  (let [discount (* amount discount-percent)
        discounted-amount (- amount discount)]
    (if (> discounted-amount min-charge)
      discounted-amount
      min-charge)))
;

(should= (compute-discount-amount 10.0 0.50 1.0) 5.0)
(should= (compute-discount-amount 10.0 0.50 2.0) 5.0)
(should= (compute-discount-amount 10.0 0.50 4.0) 5.0)
(should= (compute-discount-amount 10.0 0.50 5.0) 5.0)
(should= (compute-discount-amount 10.0 0.50 6.0) 6.0)
(should= (compute-discount-amount 10.0 0.50 10.0) 10.0)

;
(defn compute-discount-amount [amount discount-percent min-charge]
  (let [discount (* amount discount-percent)
        discounted-amount (- amount discount)]
    (println "Discount:" discount)
    (println "Discounted amount" discounted-amount)
    (if (> discounted-amount min-charge)
      discounted-amount
      min-charge)))
;

(should= (compute-discount-amount 10.0 0.50 1.0) 5.0)
(should= (compute-discount-amount 10.0 0.50 2.0) 5.0)
(should= (compute-discount-amount 10.0 0.50 4.0) 5.0)
(should= (compute-discount-amount 10.0 0.50 5.0) 5.0)
(should= (compute-discount-amount 10.0 0.50 6.0) 6.0)
(should= (compute-discount-amount 10.0 0.50 10.0) 10.0)

;
(def user-discounts
  {"Nicholas" 0.10 "Jonathan" 0.07 "Felicia" 0.05})
;

;
(defn compute-discount-amount [amount user-name user-discounts min-charge]
  (let [discount-percent (user-discounts user-name)
        discount (* amount discount-percent)
        discounted-amount (- amount discount)]
    (if (> discounted-amount min-charge)
      discounted-amount
      min-charge)))
;

(should= (compute-discount-amount 10.0 "Nicholas" user-discounts 1.0) 9.0)
(should= (compute-discount-amount 10.0 "Nicholas" user-discounts 100.0) 100.0)


;
(defn mk-discount-price-f [user-name user-discounts min-charge]
  (let [discount-percent (user-discounts user-name)]
    (fn [amount]
      (let [discount (* amount discount-percent)
            discounted-amount (- amount discount)]
        (if (> discounted-amount min-charge)
          discounted-amount
          min-charge)))))

;; Get a price function for Felicia.

(def compute-felicia-price (mk-discount-price-f "Felicia" user-discounts 10.0))

;; ...and sometime later compute a price

(compute-felicia-price 20.0)
;

(should=
  (compute-discount-amount 10.0 "Felicia" user-discounts 10.0)
  (compute-felicia-price 10.0))

(should=
  (compute-discount-amount 100.0 "Felicia" user-discounts 10.0)
  (compute-felicia-price 100.0))

;
(def anonymous-book
  {:title "Sir Gawain and the Green Knight"})

(def with-author
  {:title "Once and Future King" :author "White"})
;

;
(defn uppercase-author [book]
  (let [author (:author book)]
    (if author
      (.toUpperCase author))))
;

(should= "WHITE" (uppercase-author with-author))
(should= nil (uppercase-author anonymous-book))

;
(defn uppercase-author [book]
  (if-let [author (:author book)]
    (.toUpperCase author)))
;

(should= "WHITE" (uppercase-author with-author))
(should= nil (uppercase-author anonymous-book))

;
(defn uppercase-author [book]
  (if-let [author (:author book)]
    (.toUpperCase author)
    "ANONYMOUS"))
;

(should= (uppercase-author {:author "russ"}) "RUSS")
(should= (uppercase-author {}) "ANONYMOUS")

;
(defn uppercase-author [book]
  (when-let [author (:author book)]
    (.toUpperCase author)))
;

(should= "WHITE" (uppercase-author with-author))
(should= nil (uppercase-author anonymous-book))

(comment
;
(defn parse-params [params encoding]
  (let [params (codec/form-decode params encoding)]
    (if (map? params) params {})))
;
)

(comment
;
(defn assoc-query-params
  "Parse and assoc parameters from the query string
  with the request."
  [request encoding]
  (merge-with merge request
    (if-let [query-string (:query-string request)]
      (let [params (parse-params query-string encoding)]
        {:query-params params, :params params})
      {:query-params {}, :params {}})))
;
)

(comment
;
(let [opts (if options (apply assoc {} options) {})
      data (or (:data opts) $data)
      _x (data-as-list x data)
      nbins (or (:nbins opts) 10)
      theme (or (:theme opts) :default)
      density? (true? (:density opts))
      title (or (:title opts) "")
      x-lab (or (:x-label opts) (str 'x))
      y-lab (or (:y-label opts)
                 (if density? "Density" "Frequency"))
      series-lab (or (:series-label opts) (str 'x))
      legend? (true? (:legend opts))
      dataset (HistogramDataset.)]

  ;; Do something heroic with x-lab and density?
  ;; and title and...
  )
;
)

(comment
;
;; We can use title inside of the let.

(let [title "Let's Pretend This Never Happened"]
  (println "The title is" title)
  (print-the-title))

;; But now we're outside of the let.

(defn print-the-title []
  (println "The title is" title)) ; Boom!
;
)

(should-print "Sense and Sensibility\n"
  ;
  (let [title "Pride and Prejudice"]
    (let [title "Sense and Sensibility"]
      (println title)))                   ; Sense & Sensibility.
  ;
)

(should-print "Pride and Prejudice and Zombies\n"
  ;
  (let [title "Pride and Prejudice"       ; Classic novel.
        title (str title " and Zombies")] ; Now with the undead.
    (println title))                      ; Brains!
  ;
)
