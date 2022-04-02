(local helper/list (require :vfio.helpers.list))

(local config {})

(fn config.hydrate [config devices]
  (let [updated-devices (helper/list.deep-shallow-copy devices)]
    (each [_ device (pairs updated-devices)]
      (let [device-config (. config device.address.id)]
        (when device-config
          (tset device :config device-config))))
    updated-devices))

config
