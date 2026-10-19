;---
; Excerpted from "Programming Clojure, Fourth Edition",
; published by The Pragmatic Bookshelf.
; Copyrights apply to this code. It may not be used to create training material,
; courses, books, articles, and the like. Contact us if you are in doubt.
; We make no guarantees that this code is fit for any purpose.
; Visit https://pragprog.com/titles/shcloj4 for more book information.
;---
(ns examples.multimethods)

(defmulti my-print class)

(defn my-println [ob]
  (my-print ob)
  (.write *out* "\n"))

(defmethod my-print String [s]
  (.write *out* s))

(defmethod my-print nil [s]
  (.write *out* "nil"))

(defmethod my-print Number [n]
  (.write *out* (.toString n)))

(defmethod my-print :default [s]
  (.write *out* "#<")
  (.write *out* (.toString s))
  (.write *out* ">"))

(require '[clojure.string :as str])
(defmethod my-print java.util.Collection [c]
  (.write *out* "(")
  (.write *out* (str/join " " c))
  (.write *out* ")"))

(defmethod my-print clojure.lang.IPersistentVector [c]
  (.write *out* "[")
  (.write *out* (str/join " " c))
  (.write *out* "]"))

(prefer-method 
 my-print clojure.lang.IPersistentVector java.util.Collection)  

(defmulti my-class identity)
(defmethod my-class nil [_] nil)
(defmethod my-class :default [x] (.getClass x))


(defmulti my-print class :default :everything-else)
(defmethod my-print String [s]
  (.write *out* s))
(defmethod my-print :everything-else [_]
  (.write *out* "Not implemented yet..."))

(defmulti interest-rate :tag)
(defmethod interest-rate ::checking [_] 0M)
(defmethod interest-rate ::savings  [_] 0.05M)

(defmulti account-level :tag)
(defmethod account-level ::checking [acct]
  (if (>= (:balance acct) 5000) ::premium ::basic))
(defmethod account-level ::savings [acct]
  (if (>= (:balance acct) 1000) ::premium ::basic))


(comment

; bad approach
(defmulti service-charge account-level)
(defmethod service-charge ::basic [acct]
  (if (= (:tag acct) ::checking) 25 10))
(defmethod service-charge ::premium [_] 0)

)


(defmulti service-charge2 (fn [acct] [(account-level acct) (:tag acct)]))
(defmethod service-charge2 [::basic ::checking]  [_] 25)
(defmethod service-charge2 [::basic ::savings]    [_] 10)
(defmethod service-charge2 [::premium ::checking] [_] 0)
(defmethod service-charge2 [::premium ::savings]  [_] 0)



(derive ::savings ::account)
(derive ::checking ::account)

(defmulti service-charge3 (fn [acct] [(account-level acct) (:tag acct)]))
(defmethod service-charge3 [::basic ::checking]   [_] 25)
(defmethod service-charge3 [::basic ::savings]    [_] 10)
(defmethod service-charge3 [::premium ::account]  [_] 0)

