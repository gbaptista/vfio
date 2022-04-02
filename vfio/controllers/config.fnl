(local logic/smk (require :vfio.logic.smk))
(local component/io (require :vfio.components.io))
(local port/shell-out (require :vfio.ports.out.shell))
(local fennel (require :fennel))

(local controller {})

(fn controller.handle! [arguments]
  (let [config (controller.load! arguments)]
    (port/shell-out.dispatch! (logic/smk.line (fennel.view config)))))

(fn controller.load! [arguments]
  (let [config-path (.. (component/io.directory-for :data) "/vfio.fnl")]
    (if (component/io.exists? config-path)
      (component/io.read config-path)
      {})))

controller
