(local helper/string (require :vfio.helpers.string))
(local helper/list (require :vfio.helpers.list))

(local logic {})

(fn logic.parse-devices [raw]
  (->> raw
    (helper/string.split "\n")
    (helper/list.map logic.parse-device)))

(fn logic.parse-device [raw-line]
  (-> raw-line
    (logic.device-to-list)
    (logic.list-to-named)))

(fn logic.device-to-list [raw]
  (local items [])
  (each [i value (ipairs (helper/string.split "\"" raw))]
    (let [value (helper/string.strip value)]
      (when (not (= value "")) (table.insert items value))))
  items)

(fn logic.list-to-named [list]
  (let [device {:address (logic.parse-address (. list 1))
                :class   (logic.parse-name-and-code (. list 2))
                :vendor  (logic.parse-name-and-code (. list 3))
                :name    (logic.parse-name-and-code (. list 4))}]
    (if (and device.vendor.code device.name.code)
      (tset device :id (.. device.vendor.code ":" device.name.code))
      (tset device :id nil))
    device))

(fn logic.parse-name-and-code [raw]
  (let [(from to) (string.find raw "%]*%s%[.*%]$")]

    (var code (if from (string.sub raw (+ from 2) (- to 1)) nil))
    (when (and code (string.find code "%["))
      (set code (string.gsub code ".*%[" "")))

    (let [name (if code
                 (helper/string.strip (helper/string.gsub-raw raw (.. "[" code "]") ""))
                 raw)]
      { :name name :code code})))

(fn logic.parse-address [raw]
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

logic
