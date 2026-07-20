;---
; Excerpted from "Getting Clojure",
; published by The Pragmatic Bookshelf.
; Copyrights apply to this code. It may not be used to create training material,
; courses, books, articles, and the like. Contact us if you are in doubt.
; We make no guarantees that this code is fit for any purpose.
; Visit http://www.pragmaticprogrammer.com/titles/roclojure for more book information.
;---
(require '[inventory.core-test :as ct])
(require '[clojure.test :as test])

;
;; Three ways to run the tests in a namespace.

(test/run-tests)
(test/run-tests *ns*)
(test/run-tests 'inventory.core-test)
;

