;---
; Excerpted from "Programming Clojure, Fourth Edition",
; published by The Pragmatic Bookshelf.
; Copyrights apply to this code. It may not be used to create training material,
; courses, books, articles, and the like. Contact us if you are in doubt.
; We make no guarantees that this code is fit for any purpose.
; Visit https://pragprog.com/titles/shcloj4 for more book information.
;---
(ns examples.test
  (:require [clojure.test :refer :all]))

(def examples-tests 
     (map #(symbol (str "examples.test." (name %)))
	  [:chat :exploring :interop :introduction :multimethods :preface
	    :sequences :index-of-any :life-without-multi
	    :macros :macros.chain-1 :macros.chain-2 :macros.chain-3 :macros.chain-4
	    :macros.chain-5 :lazy-index-of-any :macros.bench-1
	    :concurrency :functional :snake :replace-symbol
	    :wallingford :trampoline
	    :male-female :memoized-male-female :male-female-seq]))

(doseq [test examples-tests] (require test))

(apply run-tests examples-tests)

(shutdown-agents)
