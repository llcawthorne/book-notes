;---
; Excerpted from "Getting Clojure",
; published by The Pragmatic Bookshelf.
; Copyrights apply to this code. It may not be used to create training material,
; courses, books, articles, and the like. Contact us if you are in doubt.
; We make no guarantees that this code is fit for any purpose.
; Visit http://www.pragmaticprogrammer.com/titles/roclojure for more book information.
;---
(defproject inventory "0.1.0-SNAPSHOT"
  :description "FIXME: write description"
  :url "http://example.com/FIXME"
  :license {:name "Eclipse Public License"
            :url "http://www.eclipse.org/legal/epl-v10.html"}
  :main inventory.core
  :dependencies [[org.clojure/clojure "1.9.0-beta3"]
                 [org.clojure/test.check "0.10.0-alpha2"]
                 [org.clojure/spec.alpha "0.1.134"]]
  :profiles {:dev {:source-paths ["../../util"]}})
