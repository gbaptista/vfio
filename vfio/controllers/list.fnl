(local sn (require :supernova))

(local controller/config (require :vfio.controllers.config))
(local component/io (require :vfio.components.io))
(local port/shell-out (require :vfio.ports.out.shell))
(local logic/lspci (require :vfio.logic.lspci))
(local logic/config (require :vfio.logic.config))
(local helper/list (require :vfio.helpers.list))

(local controller {})

(fn controller.handle! [arguments]
  (let [config  (controller/config.load! arguments)
        devices (->> "lspci -mmD"
                  (component/io.os-output)
                  (logic/lspci.parse-devices)
                  (logic/config.hydrate config))]

    (local output
      (->> devices
        (helper/list.sort-by :name)
        (helper/list.sort-by :class)
        (helper/list.map #[
          [$1.class :right]
          [$1.address.id :right #(sn.yellow $1)]
          [$1.name :left]
          [$1.vendor :left]])))

    (port/shell-out.dispatch! [[:table output]])))

(fn controller.hydrate [])

controller
