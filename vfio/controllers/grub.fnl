(local sn (require :supernova))

(local component/io (require :vfio.components.io))
(local logic/grub (require :vfio.logic.grub))
(local helper/list (require :vfio.helpers.list))
(local helper/string (require :vfio.helpers.string))
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

(fn controller.backup! [path]
  (let [content     (component/io.read path)
        data-path   (component/io.directory-for :shared-data)
        file-name   (os.date "%Y-%m-%d-%H-%M-%S-grub.backup")
        backup-path (.. data-path "/" file-name)]
    (component/io.write backup-path content)
    (port/shell-out.dispatch! (logic/smk.line (.. (sn.cyan "\n> ") (sn.yellow backup-path))))
    (port/shell-out.dispatch! (logic/smk.line "  Backup created!"))))

(fn controller.apply-to-grub! [grub-path kernel-options]
  (let [content     (component/io.read grub-path)
        diff        (logic/grub.apply content kernel-options)
        new-content (helper/string.gsub-raw content diff.previous diff.new)]

    (port/shell-out.dispatch! (logic/smk.line (.. (sn.cyan "\n> ") (sn.yellow grub-path))))
    (port/shell-out.dispatch! (logic/smk.line (.. (sn.red "  - ") (sn.red diff.previous))))
    (port/shell-out.dispatch! (logic/smk.line (.. (sn.green "  + ") (sn.green diff.new))))

    (when (= diff.previous diff.new)
      (port/shell-out.dispatch! (logic/smk.line (sn.blue "\nNothing to be changed.\n")))
      (os.exit))

    (port/shell-out.dispatch! (logic/smk.line "\nProceed with setup?"))
    (port/shell-out.dispatch! (logic/smk.fragment (sn.blue "[Yn]> ")))
    (let [answer (port/shell-out.retrieve!)]
      (when (= answer "n") (os.exit)))

    (controller.backup! grub-path)

    (let [error-message (component/io.safe-write grub-path new-content)]
      (when error-message
        (if (string.find error-message "ermission denied")
          (controller.permission-error! error-message)
          (error error-message))))

    (when (not (controller.check! grub-path diff.new))
      (port/shell-out.dispatch! (logic/smk.line 
        (sn.red "\nError: Couldn't find new expected content in the grub file.\n")))
      (os.exit))

    (port/shell-out.dispatch! (logic/smk.line (.. (sn.cyan "\n> ") (sn.yellow grub-path))))
    (port/shell-out.dispatch! (logic/smk.line (sn.green "  Successfully updated!\n")))))

(fn controller.permission-error! [error-message]
  (port/shell-out.dispatch! (logic/smk.line (sn.red (.. "\nError: " error-message))))
  (port/shell-out.dispatch! (logic/smk.line
    (.. "\nHow about trying to run the command with " (sn.yellow "sudo") "?\n")))
  (os.exit))

(fn controller.check! [grub-path expected]
  (let [content (component/io.read grub-path)]
    (if (helper/string.find-raw content expected 1 true) true false)))

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
