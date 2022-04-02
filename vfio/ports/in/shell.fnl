(local controller/config (require :vfio.controllers.config))
(local controller/help (require :vfio.controllers.help))
(local controller/devices (require :vfio.controllers.devices))
(local adapter/argv (require :vfio.adapters.argv))

(local port {})

(fn port.handle! [input?]
  (let [input     (or input? arg)
        arguments (adapter/argv.parse input)]
  (match (. arguments :command)
    nil     (controller/devices.list! arguments)
    :config (controller/config.handle! arguments)
    :help   (controller/help.handle! arguments)
    _       (port.device! input))))

(fn port.device! [input]
  (table.insert input 1 "device")
  (let [arguments (adapter/argv.parse input)]
    (controller/devices.set! arguments)))

port
