(local controller/config (require :vfio.controllers.config))
(local controller/help (require :vfio.controllers.help))
(local controller/devices (require :vfio.controllers.devices))
(local adapter/argv (require :vfio.adapters.argv))

(local port {})

(fn port.handle! [input?]
  (let [input     (or input? arg)
        arguments (adapter/argv.parse input)]
  (match (. arguments :command)
    :config (controller/config.handle! arguments)

    :list   (controller/devices.list! arguments)
    :get    (controller/devices.get! arguments)
    :set    (controller/devices.set! arguments)
    _       (controller/help.handle!))))

port
