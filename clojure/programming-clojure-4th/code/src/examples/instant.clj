;---
; Excerpted from "Programming Clojure, Fourth Edition",
; published by The Pragmatic Bookshelf.
; Copyrights apply to this code. It may not be used to create training material,
; courses, books, articles, and the like. Contact us if you are in doubt.
; We make no guarantees that this code is fit for any purpose.
; Visit https://pragprog.com/titles/shcloj4 for more book information.
;---
(ns examples.instant
  (:import [java.util Date]
           [java.time Instant]))

(set! *warn-on-reflection* true)

(defn inst->ms
  "Given a java.time.Instant, return ms since the epoch"
  [^Instant instant]
  (.toEpochMilli instant))

(comment
  (def TEST-MS 1760323945754)
  (= TEST-MS (inst->ms (Instant/ofEpochMilli TEST-MS)))
  )

(defn time->ms
  "Given a time source, return ms since the epoch"
  [time-source]
  (cond
    (instance? Instant time-source)
    (.toEpochMilli ^Instant time-source)
    
    (instance? Date time-source)
    (.getTime ^Date time-source)))

(comment
  (def TEST-MS 1760323945754)
  (= TEST-MS (time->ms (Instant/ofEpochMilli TEST-MS)))
  (= TEST-MS (time->ms (Date. TEST-MS)))
  )

(defprotocol InstantProvider
  "An abstraction for instant providers. Use to-ms to resolve
   to ms since the epoch."
  (to-ms [source]
    "Given a time source, return ms since the epoch"))

(extend-protocol InstantProvider
  Instant
  (to-ms [inst]
    (.toEpochMilli ^Instant inst))
  Date
  (to-ms [date]
    (.getTime ^Date date)))

(defn unknown-src
  [time-source]
  (throw
    (ex-info (str "Unknown time source: "
               (or
                 (some-> time-source class .getName)
                 "nil"))
    {})))

(extend-protocol InstantProvider
  nil
  (to-ms [src]
    (unknown-src src))
  Object
  (to-ms [src]
    (unknown-src src)))

(comment
  (def TEST-MS 1760323945754)
  (= TEST-MS (to-ms (Instant/ofEpochMilli TEST-MS)))
  (= TEST-MS (to-ms (Date. ^long TEST-MS)))
  (= TEST-MS (to-ms TEST-MS))
  (to-ms "oops")
  (to-ms nil)
  )

(defprotocol Simulation
  (advance! [_] "Advance the simulation to the next step"))

(deftype SimClock
  [start granularity tick]
  Simulation
  (advance! [_]
    (swap! tick inc))

  InstantProvider
  (to-ms [_]
    (+ start (* granularity @tick))))

(defn init-simulation
  [granularity]
  (->SimClock (to-ms (Instant/now)) granularity (atom 0)))

(comment

  (def sim (init-simulation 1000))
  (dotimes [_ 5]
    (advance! sim)
    (println (to-ms sim)))

  )