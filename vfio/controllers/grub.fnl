(local sn (require :supernova))

(local component/io (require :vfio.components.io))
(local logic/grub (require :vfio.logic.grub))
(local helper/list (require :vfio.helpers.list))
(local controller/devices (require :vfio.controllers.devices))

(local logic/smk (require :vfio.logic.smk))
(local port/shell-out (require :vfio.ports.out.shell))

(local controller {})

(fn controller.handle! [arguments]
  (let [grub-path "/etc/default/grub"
        devices   (->> (controller/devices.devices!)
                       (helper/list.filter #(= $1.config.passthrough true)))
        kernel-options (logic/grub.build-kernel-options devices)]

    (port/shell-out.dispatch! (logic/smk.line
      "The following settings will be applied to your Kernel startup:"))
    (each [_ option (pairs kernel-options)]
      (controller.describe! option devices))

    (controller.apply-to-grub! grub-path kernel-options)))

(fn controller.apply-to-grub! [grub-path kernel-options]
  (let [content  (component/io.read grub-path)
        diff     (logic/grub.apply content kernel-options)
        tmp-path "/tmp/vfio-tmp-grub"]

    (port/shell-out.dispatch! (logic/smk.line (.. (sn.cyan "\n> ") (sn.yellow grub-path))))
    (port/shell-out.dispatch! (logic/smk.line (.. (sn.red "  - ") (sn.red diff.previous))))
    (port/shell-out.dispatch! (logic/smk.line (.. (sn.green "  + ") (sn.green diff.new))))

    (port/shell-out.dispatch! (logic/smk.line "\nProceed with setup?"))
    (port/shell-out.dispatch! (logic/smk.fragment (sn.blue "[Yn]> ")))
    (let [answer (port/shell-out.retrieve!)]
      (when (= answer "n") (os.exit)))

    (component/io.write tmp-path (string.gsub content diff.previous diff.new))

    (component/io.safe-os (.. "(cat " tmp-path " > " grub-path ") &>/dev/null"))

    (if (not (controller.check! grub-path diff.new))
      (component/io.os (.. "sudo sh -c '" tmp-path " > " grub-path "'"))
      (print "Done!"))))

(fn controller.check! [grub-path expected]
  (let [content (component/io.read grub-path)]
    (if (string.find content expected) true false)))

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
