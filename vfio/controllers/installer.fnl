(local sn (require :supernova))

(local logic/smk (require :vfio.logic.smk))
(local component/io (require :vfio.components.io))
(local port/shell-out (require :vfio.ports.out.shell))
(local fennel (require :fennel))

(local controller {})

(fn controller.handle! [arguments]
  (let [working-directory (component/io.current-directory)
        bin-path          (.. (component/io.directory-for :executable) "/vfio")]
    
    (port/shell-out.dispatch! (logic/smk.line
      (.. "We need to create a "
          (sn.red "binary")
          " for vfio. Is this destination the desired one?")))

    (port/shell-out.dispatch! (logic/smk.line (sn.yellow bin-path)))
    (port/shell-out.dispatch! (logic/smk.fragment (sn.blue "[Yn]> ")))
    (let [answer (port/shell-out.retrieve!)]
      (when (= answer "n") (os.exit)))

    (port/shell-out.dispatch! (logic/smk.line
      (.. "\nWe need to ensure that we have the correct path for the "
          (sn.cyan "vfio")
          " source code directory. Is this path right?")))

    (port/shell-out.dispatch! (logic/smk.line (sn.yellow working-directory)))
    (port/shell-out.dispatch! (logic/smk.fragment (sn.blue "[Yn]> ")))
    (let [answer (port/shell-out.retrieve!)]
      (when (= answer "n") (os.exit)))

    (when (component/io.exists? bin-path)
      (port/shell-out.dispatch! (logic/smk.line (.. "\n" (sn.yellow bin-path))))
      (port/shell-out.dispatch! (logic/smk.line "Already exists. May I overwrite it?"))
      (port/shell-out.dispatch! (logic/smk.fragment (sn.blue "[Yn]> ")))
      (let [answer (port/shell-out.retrieve!)]
        (when (= answer "n") (os.exit))))

    (controller.install! arguments working-directory bin-path)))

(fn controller.install! [arguments working-directory bin-path]
  (let [bin-source (component/io.read "bin/vfio")
        bin-source (string.gsub bin-source ":FNX_WORKING_DIRECTORY" working-directory)]

    (when (component/io.exists? bin-path)
      (component/io.remove bin-path))

    (component/io.write bin-path bin-source)
    (component/io.os (.. "chmod +x " bin-path))))

controller
