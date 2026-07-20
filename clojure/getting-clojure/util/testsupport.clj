;---
; Excerpted from "Getting Clojure",
; published by The Pragmatic Bookshelf.
; Copyrights apply to this code. It may not be used to create training material,
; courses, books, articles, and the like. Contact us if you are in doubt.
; We make no guarantees that this code is fit for any purpose.
; Visit http://www.pragmaticprogrammer.com/titles/roclojure for more book information.
;---
(ns testsupport)

;;(def verbose (java.lang.System/getenv "VERBOSE"))

(def verbose true)


(defn log-test
  "Print the info to stdout if verbose mode."
  [& info]
  (when verbose (apply println "Test:" info)))

(defmacro defq
  "Like def but quotes the value."
  [s x]
  `(def ~s (quote ~x)))

(defn mk-error
  "Make a new assertion error with the messages."
  [& messages]
  (AssertionError. (apply str "Assertion failed: " (interpose " " messages))))

(defn throw-error
  "Throw a new assertion error."
  [& messages]
  (throw (apply mk-error messages)))

(defmacro assert=
  "Assert that the two values are equal."
  [a b]
  `(let [val-a# ~a
         val-b# ~b]
     (if-not (= val-a# val-b#)
       (throw-error '~a "is not equal to " '~b "\n<<" val-a# ">> != <<" val-b# ">>"))))

(defn mk-assert
  "Make an assertion expression that asserts x."
  [x]
  `(let [val-x# ~x]
     (if-not val-x#
       (throw-error "Assertion failed:" '~x "\n<<" val-x# ">>"))))


(defn mk-assert=
  "Make an assertion expression that asserts expected = expr"
  [expected expr]
  (log-test :assert= expected expr)
  (cond
    (= expected (symbol "_")) expr
    (= expected (symbol "_t")) `(assert ~expr)
    (= expected (symbol "_f")) `(assert (not ~expr))
    :default `(assert= ~expected ~expr)))

(defmacro should=
  "Assert the two expressions result in = values."
  [expected expr]
  (mk-assert= expected expr))

(defmacro should-result [expected-vals & exprs]
  (log-test :should-return expected-vals exprs)
  (cons 'do (map mk-assert= expected-vals exprs)))

(defmacro should-throw [& exprs]
  `(let [result# (try (do ~@exprs ::no-throw) (catch Throwable e# ::throw))]
     (when (= result# ::no-throw)
       (throw-error '~exprs "should have thrown an exception."))))

(defmacro should [expr]
  (log-test :should expr)
  (mk-assert expr))

(defmacro should-match [re expr]
  (log-test :should-match expr)
  `(if-not (re-find ~re ~expr)
    (throw-error "Does not match:" ~re "\n" ~expr)))

;;  `(mk-assert (re-find ~re ~expr)))

(defmacro print-to-str [& exprs]
  `(let [result# (with-out-str ~@exprs)]
    (println result#)
    result#))

(defmacro should-print [output & exprs]
  (log-test :should-print output exprs)
  (if (string? output)
    `(assert= ~output (print-to-str ~@exprs))
    `(assert (re-find ~output (print-to-str ~@exprs)))))

(defmacro mdef [names & values]
  (cons 'do (map (partial list 'def) names values)))
