(local sn (require :supernova))

(local logic/smk (require :vfio.logic.smk))
(local port/shell-out (require :vfio.ports.out.shell))

(local helper/list (require :vfio.helpers.list))
(local controller/devices (require :vfio.controllers.devices))
(local controller/grub (require :vfio.controllers.bootloaders.grub))
(local logic/kernel (require :vfio.logic.kernel))

(local controller {})

(fn controller.handle! [arguments]
  (let [devices   (->> (controller/devices.devices!)
                       (helper/list.filter #(= $1.config.passthrough true)))
        options   (logic/kernel.build-options-for devices)]

     (port/shell-out.dispatch! (logic/smk.line
      "The following settings will be applied to your Kernel startup:"))
    (each [_ option (pairs options)]
      (controller.describe! option devices))

    ; TODO: Support other bootloaders.
    (controller/grub.apply! options)))

(fn controller.describe! [option devices]
  (port/shell-out.dispatch!
    (logic/smk.line (.. "\n" (sn.cyan "> ") option.key "=" (sn.yellow option.value))))
  (port/shell-out.dispatch!
    (logic/smk.line (..  "  " option.description)))
  (when (= option.key :pci-stub.ids) (controller.describe-devices! devices)))

(fn controller.describe-devices! [devices]
  (local output
    (->> devices
      (helper/list.map #[
        [(.. "    " $1.id) :right #(sn.yellow $1)]
        [$1.name.name :left #(sn.cyan $1)]
        [$1.vendor.name :left]
        [$1.class.name :left #(sn.cyan $1)]])))

  (port/shell-out.dispatch! [[:table output]]))

controller
