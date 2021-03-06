(local logic/smk (require :vfio.logic.smk))
(local port/shell-out (require :vfio.ports.out.shell))

(local controller {})

(fn controller.handle! []
  (port/shell-out.dispatch!
    [[:line "vfio 0.0.1"]
     [:line ""]
     [:line "usage:"]
     [:line "  vfio"]
     [:line "  vfio [id]"]
     [:line "  vfio [id] [attribute] [value]"]
     [:line "  vfio [id] passthrough true"]
     [:line "  vfio grub"]
     [:line "  vfio config"]
     [:line "  vfio help"]
     [:line ""]]))

controller
