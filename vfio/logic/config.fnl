(local helper/list (require :vfio.helpers.list))

(local logic {})

(fn logic.standardize [device]
  (if (= (. device.config :passthrough) "true")
    (tset device.config :passthrough true)
    (tset device.config :passthrough false))
  device)

(fn logic.hydrate [config devices]
  (let [updated-devices (helper/list.deep-shallow-copy devices)]
    (each [_ device (pairs updated-devices)]
      (let [device-config (. config device.id)]
        (if device-config
          (tset device :config device-config)
          (tset device :config {}))))
    (helper/list.map logic.standardize updated-devices)))

logic
