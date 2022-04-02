(local port/shell-out (require :vfio.ports.out.shell))

(local controller {})

(fn controller.handle! []
  (port/shell-out.dispatch! "vfio 0.0.1"))

controller
