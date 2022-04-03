(local sn (require :supernova))

(local component/io (require :vfio.components.io))
(local logic/grub (require :vfio.logic.bootloaders.grub))
(local helper/list (require :vfio.helpers.list))
(local helper/string (require :vfio.helpers.string))
(local controller/devices (require :vfio.controllers.devices))

(local logic/smk (require :vfio.logic.smk))
(local port/shell-out (require :vfio.ports.out.shell))

(local controller {})

(fn controller.apply! [kernel-options]
  (let [grub-path "/etc/default/grub"
        content     (component/io.read grub-path)
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
    (port/shell-out.dispatch! (logic/smk.line (sn.green "  Successfully updated!\n")))

    ; TODO: sudo grub-mkconfig -o /boot/grub/grub.cfg
    ))

(fn controller.backup! [path]
  (let [content     (component/io.read path)
        data-path   (component/io.directory-for :shared-data)
        file-name   (os.date "%Y-%m-%d-%H-%M-%S-grub.backup")
        backup-path (.. data-path "/" file-name)]
    (component/io.write backup-path content)
    (port/shell-out.dispatch! (logic/smk.line (.. (sn.cyan "\n> ") (sn.yellow backup-path))))
    (port/shell-out.dispatch! (logic/smk.line "  Backup created!"))))

(fn controller.permission-error! [error-message]
  (port/shell-out.dispatch! (logic/smk.line (sn.red (.. "\nError: " error-message))))
  (port/shell-out.dispatch! (logic/smk.line
    (.. "\nHow about trying to run the command with " (sn.yellow "sudo") "?\n")))
  (os.exit))

(fn controller.check! [grub-path expected]
  (let [content (component/io.read grub-path)]
    (if (helper/string.find-raw content expected 1 true) true false)))

controller
