(ns serpent-talk.core
  (:require [camel-snake-kebab.core :as csk]))

(defn serpent-talk [input]
  (str "Serpent! You said: "
       (csk/->snake_case input)))

(defn -main [& args]
  (println (serpent-talk (first args))))
