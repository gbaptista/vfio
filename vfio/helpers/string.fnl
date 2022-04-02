(local helper/list (require :vfio.helpers.list))

(local helper {})

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
