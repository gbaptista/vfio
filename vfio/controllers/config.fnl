(local logic/smk (require :vfio.logic.smk))
(local component/io (require :vfio.components.io))
(local port/shell-out (require :vfio.ports.out.shell))
(local helper/fennel (require :vfio.helpers.fennel))

(local controller {})

(fn controller.handle! [arguments]
  (let [config (controller.load!)]
    (port/shell-out.dispatch! (logic/smk.line (helper/fennel.data->string config)))))

(fn controller.load! []
  (let [config-path (controller.path)]
    (if (component/io.exists? config-path)
      (helper/fennel.string->data (component/io.read config-path))
      {})))

(fn controller.write! [config]
  (let [config-path (controller.path)]
    (component/io.write config-path (helper/fennel.data->string config))))

(fn controller.set! [arguments]
  (let [config     (controller.load! arguments)
        id         (. arguments.list 1)
        properties arguments.smart]

    (when (not (. config id))
      (tset config id {}))

    (let [device-config (. config id)]
      (each [key value (pairs properties)]
        (if (= value "nil")
          (tset device-config key nil)
          (tset device-config key value))))

    (controller.write! config)))

(fn controller.path []
  (.. (component/io.directory-for :shared-data) "/config.fnl"))

controller
