(local port/shell-out (require :vfio.ports.out.shell))

(local controller {})

(fn controller.handle! [arguments]
  (port/shell-out.dispatch! "config"))

controller
