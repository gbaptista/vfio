(local controller/help (require :vfio.controllers.help))
(local controller/config (require :vfio.controllers.config))

(local adapter/argv (require :vfio.adapters.argv))

(local port {})

(fn port.handle! [input?]
  (let [input     (or input? arg)
        arguments (adapter/argv.parse input)]
  (match (. arguments :command)
    :config  (controller/config.handle! arguments)
    _        (controller/help.handle!))))

port
