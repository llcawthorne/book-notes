(set-env!
  :source-paths #{"../util"}
  :dependencies '[[org.clojure/clojure "1.8.0"]
                  [de.ubercode.clostache/clostache "1.4.0"]])

(deftask runtest []
  (with-pass-thru _
    (load-file "examples.clj")))
