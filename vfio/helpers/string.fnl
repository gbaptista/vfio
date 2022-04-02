(local helper/list (require :vfio.helpers.list))

(local helper {})

(fn helper.gsub-raw [data search new-value]
  (let [(from to) (helper.find-raw data search)]
    (if (not from)
      data
      (.. (string.sub data 1 (- from 1)) new-value (string.sub data (+ to 1) (length data))))))

(fn helper.find-raw [content search]
  (string.find content search 1 true))

(fn helper.strip [input]
  (-> input
    (string.gsub "\n" "")
    (string.gsub "%s+$" "")
    (string.gsub "^%s+" "")
    (tostring)))

(fn helper.strip-dash [input]
  (tostring (string.gsub input "^-+" "")))

(fn helper.split [delimiter content]
  (let [iterator (content:gmatch (.. "([^" delimiter "]+)" delimiter "?"))]
    (helper/list.reduce-iterator #(do (table.insert $1 $2) $1) iterator [])))

helper
