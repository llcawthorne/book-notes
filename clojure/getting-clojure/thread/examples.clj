;---
; Excerpted from "Getting Clojure",
; published by The Pragmatic Bookshelf.
; Copyrights apply to this code. It may not be used to create training material,
; courses, books, articles, and the like. Contact us if you are in doubt.
; We make no guarantees that this code is fit for any purpose.
; Visit http://www.pragmaticprogrammer.com/titles/roclojure for more book information.
;---
;; Threads, Promises and Futures

(ns user
  (:require [testsupport :refer :all]))

;
(ns blottsbooks.threads)

(defn -main []
  (println "Coming to you live from the main thread!"))
;

;
;; Make a thread.

(defn do-something-in-a-thread []
  (println "Hello from the thread.")
  (println "Good bye from the thread."))

(def the-thread (Thread. do-something-in-a-thread))

;; And run it.

(.start the-thread)
;

;
;; Print two messages with a three second pause in the middle.

(defn do-something-else []
  (println "Hello from the thread.")
  (Thread/sleep 3000)
  (println "Good bye from the thread."))

(.start (Thread. do-something-else))
;

(defn do-the-first-job [])
(defn do-the-second-job [])
;
;; Do the first thing then the second.

(do-the-first-job)
(do-the-second-job)

;; Go on with the rest of the program...
;

;
;; Do the first job in another thread.

(.start (Thread. do-the-first-job))

;; Immediately start on the second job.

(do-the-second-job)

;; Go on with the rest of the program (but keep reading!)...
;

;
(.start (Thread. do-the-first-job))

(.start (Thread. do-the-second-job))

;; Do something else...
;

;
(def fav-book "Jaws")

(defn make-emma-favorite [] (def fav-book "Emma"))

(defn make-2001-favorite [] (def fav-book "2001"))
;

;
(make-emma-favorite)
(make-2001-favorite)
;

;
;; Kick off the threads.

(.start (Thread. make-emma-favorite))
(.start (Thread. make-2001-favorite))
;

;
(def inventory [{:title "Emma" :sold 51 :revenue 255}
                {:title "2001" :sold 17 :revenue 170}
                ;; Lots and lots of books...
                ])
;

(defn sum-copies-sold [x])
(defn sum-revenue [x])


;
(.start (Thread. (sum-copies-sold inventory)))

(.start (Thread. (sum-revenue inventory)))
;

;
(def ^:dynamic *favorite-book* "Oliver Twist")

(def thread-1
  (Thread.
    #(binding [*favorite-book* "2001"]
      (println "My favorite book is" *favorite-book*))))

(def thread-2
  (Thread.
    #(binding [*favorite-book* "Emma"]
      (println "My favorite book is" *favorite-book*))))

(.start thread-1)
(.start thread-2)
;

;
;; Delete a file in the background.

(.start (Thread. #(.delete (java.io.File. "temp-titles.txt"))))
;

;
(def del-thread (Thread. #(.delete (java.io.File. "temp-titles.txt"))))

(.start del-thread)

(.join del-thread)
;

;
(def the-result (promise))
;

;
(deliver the-result "Emma")
;

;
(println "The value in my promise is" (deref the-result))
;

;
(println "The value in my promise is" @the-result)
;

;
(def inventory [{:title "Emma" :sold 51 :revenue 255}
                {:title "2001" :sold 17 :revenue 170}
                ;; Lots and lots of books...
                ])

(defn sum-copies-sold [inv]
  (apply + (map :sold inv)))

(defn sum-revenue [inv]
  (apply + (map :revenue inv)))
;

;
(let [copies-promise (promise)
      revenue-promise (promise)]
  (.start (Thread. #(deliver copies-promise (sum-copies-sold inventory))))
  (.start (Thread. #(deliver revenue-promise (sum-revenue inventory))))

  ;; Do some other stuff in this thread...

  (println "The total number of books sold is" @copies-promise)
  (println "The total revenue is " @revenue-promise))
;



(Thread/sleep 75)

;
(def revenue-future
  (future (apply + (map :revenue inventory))))
;

(Thread/sleep 75)
;
(println "The total revenue is " @revenue-future)
;

;
(import java.util.concurrent.Executors)

;; Create a pool of at most three threads.

(def fixed-pool (Executors/newFixedThreadPool 3))
;

;
(defn a-lot-of-work []
  (println "Simulating function that takes a long time.")
  (Thread/sleep 1000))

(defn even-more-work []
  (println "Simulating function that takes a long time.")
  (Thread/sleep 1000))

(.execute fixed-pool a-lot-of-work)
(.execute fixed-pool even-more-work)
;

;
;; Throw more jobs at the fixed-pool than it can handle...

(.execute fixed-pool even-more-work)
(.execute fixed-pool even-more-work)
(.execute fixed-pool even-more-work)
(.execute fixed-pool even-more-work)
(.execute fixed-pool even-more-work)
(.execute fixed-pool even-more-work)

;; ... and it will get it all done as quickly as it can.
;

(def revenue-promise (promise))
(deliver revenue-promise 444)

;
(deref revenue-promise)
;

;
@revenue-promise
;

(def revenue-promise (promise))

(testsupport/should= :oh-snap
  ;
  ;; Wait 1/2 second (500 milliseconds) for the revenue.
  ;; Return :oh-snap on timeout.

  (deref revenue-promise 500 :oh-snap)
  ;
)

;
(defn -main []
  (let [t (Thread. #((Thread/sleep 5000)))]
    (.start t))
  (println "Main thread is all done, but..."))
;

;
(defn -main []
  (let [t (Thread. #((Thread/sleep 5000)))]
    (.setDaemon t true)
    (.start t))
  (println "Main thread is all done!"))
;

(def some-computationally-intensive-f inc)
(def a-collection [1 2 3])

(testsupport/should= [2 3 4]
  ;
  (pmap some-computationally-intensive-f a-collection)
  ;
)

;
(defn toy-pmap [f coll]
  (let [futures (doall (map #(future (f %)) coll))]
    (map deref futures)))
;

(testsupport/should= (toy-pmap inc []) [])
(testsupport/should= (toy-pmap inc [1 2 3]) (pmap inc [1 2 3]))

(System/exit 0)
