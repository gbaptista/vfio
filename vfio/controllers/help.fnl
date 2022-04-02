(local logic/smk (require :vfio.logic.smk))
(local port/shell-out (require :vfio.ports.out.shell))

(local controller {})

(fn controller.handle! []
  (port/shell-out.dispatch! (logic/smk.line "vfio 0.0.1")))

controller
