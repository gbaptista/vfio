(local controller/help (require :vfio.controllers.help))
(local controller/config (require :vfio.controllers.config))
(local controller/list (require :vfio.controllers.list))

(local adapter/argv (require :vfio.adapters.argv))

(local port {})

(fn port.handle! [input?]
  (let [input     (or input? arg)
        arguments (adapter/argv.parse input)]
  (match (. arguments :command)
    :list   (controller/list.handle! arguments)
    :config (controller/config.handle! arguments)
    _       (controller/help.handle!))))

port
