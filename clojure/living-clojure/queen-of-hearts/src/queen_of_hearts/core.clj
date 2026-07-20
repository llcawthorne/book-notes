(ns queen-of-hearts.core
  (:require [clojure.core.async :as async]))

(def flowers ["white carnation"
              "yellow daffodil"
              "yellow rose"
              "red rose"
              "white rose"
              "purple lily"
              "pink carnation"])

;; the queen demands red flowers
(defn paint-it-red [s]
  (str "red "
       (last (clojure.string/split s #"\s"))))

;; the queen only allows roses
(defn is-a-rose? [s]
  (= "rose"
     (last (clojure.string/split s #"\s"))))

;; we build a set of transducers from unapplied maps and filters
(def fix-for-the-queen-xform
  (comp
    (map paint-it-red)
    (filter is-a-rose?)))

;; now there are four ways to use the transducers

;; into - a nonlazy way to turn the transformation into a collection
(def with-into (into [] fix-for-the-queen-xform flowers))

;; sequence - a lazy way to turn the transformation into a collection
(def with-sequence (sequence fix-for-the-queen-xform flowers))

;; transduce - which acts like reduce on all the transformed elements
(def with-transduce (transduce fix-for-the-queen-xform
                               (completing #(str %1 %2 ":"))
                               ""
                               flowers))

;; use core.async channels to do the transformations
(def flower-chan (async/chan 1 fix-for-the-queen-xform))

(def result-chan (async/reduce
                   (completing #(str %1 %2 ":"))
                   ""
                   flower-chan))

(async/onto-chan flower-chan flowers)

(def flowers-for-the-queen (async/<!! result-chan))
