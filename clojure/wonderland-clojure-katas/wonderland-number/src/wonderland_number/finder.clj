(ns wonderland-number.finder)

(defn check-digits? [n1 n2]
  (let [s1 (set (str n1))
        s2 (set (str n2))]
    (= s1 s2)))

(defn wonderland-number []
  (first (for [i (range 100000 1000000)
               :when (and (check-digits? i (* 2 i))
                          (check-digits? i (* 3 i))
                          (check-digits? i (* 4 i))
                          (check-digits? i (* 5 i))
                          (check-digits? i (* 6 i)))]
           i)))

;; what numbers under 1000 are equal to the sum of the cube of their digits
;; '(0 1 153 370 371 407)
(defn- char->int [c]
  (Integer/parseInt (str c)))

(defn sum-of-cube-of-digits [n1]
  (let [digits (map char->int (str n1))]
    (int (reduce #(+ %1 (Math/pow %2 3)) 0 digits))))

(def sum-of-cube-of-digits-list
  (for [i (range 1000) :when (= (sum-of-cube-of-digits i) i)]
    i))
