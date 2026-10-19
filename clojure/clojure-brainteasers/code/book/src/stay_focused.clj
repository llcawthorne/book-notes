;---
; Excerpted from "Clojure Brain Teasers",
; published by The Pragmatic Bookshelf.
; Copyrights apply to this code. It may not be used to create training material,
; courses, books, articles, and the like. Contact us if you are in doubt.
; We make no guarantees that this code is fit for any purpose.
; Visit https://pragprog.com/titles/mmclobrain for more book information.
;---
(def my-msgs
  {:emails [[:from "boss"] [:from "mom"]
            #_ #_ [:from "Nigerian Prince"] [:from "LinkedIn"]]
   :discord-msgs {"Clojure Camp" 6
                  #_ #_ "Heart of Clojure" 3
                  "DungeonMasters" 20}
   :voicemails ["Your voicemail box is full."]})

(defn unread [msgs]
  (let [{:keys [emails discord-msgs voicemails]} msgs]
    (+ (count emails)
       (reduce + (vals discord-msgs))
       (count voicemails))))

(= 34 (unread my-msgs))