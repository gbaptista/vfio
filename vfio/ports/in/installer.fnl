(local adapter/argv (require :vfio.adapters.argv))

(local controller (require :vfio.controllers.installer))

(local port {})

(fn port.handle! [input?]
  (let [input     (or input? arg)
        arguments (adapter/argv.parse input)]
    (controller.handle! arguments)))

port
