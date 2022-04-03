(local sn (require :supernova))

(local controller/config (require :vfio.controllers.config))
(local component/io (require :vfio.components.io))
(local port/shell-out (require :vfio.ports.out.shell))
(local logic/lspci (require :vfio.logic.lspci))
(local logic/config (require :vfio.logic.config))
(local logic/smk (require :vfio.logic.smk))
(local helper/list (require :vfio.helpers.list))

(local controller {})

(fn controller.handle! [arguments]
  (controller/config.set! arguments)
  (controller.get! arguments))

(fn controller.list! [arguments]
  (let [devices (controller.devices!)]
    (local output
      (->> devices
        (helper/list.map #[
          [$1.class.name :right]
          [(controller.flags $1) :center #(sn.red $1)]
          [$1.id :center #(sn.yellow $1)]
          [$1.name.name :left #(sn.cyan $1)]
          [$1.vendor.name :left]])))

    (port/shell-out.dispatch! [[:table output]])))

(fn controller.flags [device]
  (local flags [])
  (when (= (. device.config :passthrough) true)
    (table.insert flags "passthrough"))
  (helper/list.join " " flags))

(fn controller.get! [arguments]
  (let [devices (controller.devices!)
        id     (. arguments.list 1)
        device (. (helper/list.filter #(= $1.id id) devices) 1)]

    (when (not device)
      (port/shell-out.dispatch! (logic/smk.line (.. "Device " (sn.red id) " not found.")))
      (os.exit))

    (local device-output
      [[""]
       [["id:" :right]      [device.id :left #(sn.yellow $1)]]
       [["address:" :right] [device.address.id :left]]
       [""]
       [["class:" :right]   [device.class.name :left]]
       [["vendor:" :right]  [device.vendor.name :left]]
       [["name:" :right]    [device.name.name :left #(sn.cyan $1)]]])

    (var first true)
    (each [key value (pairs device.config)]
      (when first (set first false) (table.insert device-output [""]))
      (table.insert device-output
        [[(.. key ":") :right] [(tostring value) :left #(sn.yellow $1)]]))

    (table.insert device-output [""])

    (port/shell-out.dispatch! [[:table device-output]])))

(fn controller.devices! [arguments]
  (let [config  (controller/config.load!)]
    (->> "lspci -nnmmD"
      (component/io.os-output)
      (logic/lspci.parse-devices)
      (logic/config.hydrate config)
      (helper/list.sort-by :name :name)
      (helper/list.sort-by :class :name))))

controller
