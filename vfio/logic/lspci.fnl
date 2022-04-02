(local helper/string (require :vfio.helpers.string))
(local helper/list (require :vfio.helpers.list))

(local lspci {})

(fn lspci.parse-devices [raw]
  (->> raw
    (helper/string.split "\n")
    (helper/list.map lspci.parse-device)))

(fn lspci.parse-device [raw-line]
  (-> raw-line
    (lspci.device-to-list)
    (lspci.list-to-named)))

(fn lspci.device-to-list [raw]
  (local items [])
  (each [i value (ipairs (helper/string.split "\"" raw))]
    (let [value (helper/string.strip value)]
      (when (not (= value "")) (table.insert items value))))
  items)

(fn lspci.list-to-named [list]
  {:address (lspci.parse-address (. list 1))
   :class (. list 2)
   :vendor (. list 3)
   :name (. list 4)})

(fn lspci.parse-address [raw]
  (let [parts-a  (helper/string.split ":" raw)
        parts-b  (helper/string.split "%." (. parts-a (length parts-a)))
        device   (. parts-b 1)
        function (. parts-b 2)
        address  {:id raw :function function :device device}]
    (if (= (length parts-a) 2)
      (tset address :bus (. parts-a 1))
      (do
        (tset address :domain (. parts-a 1))
        (tset address :bus (. parts-a 2))))
    address))

lspci
