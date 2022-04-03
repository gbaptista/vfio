(local t (require :fspec))

(local logic (require :vfio.logic.bootloaders.grub))

(t.eq (logic.get-cmdline-linux (.. 
  "GRUB_DISTRIBUTOR=\"Manjaro\"\n"
  "GRUB_CMDLINE_LINUX=\"\"\n"
  "# If you want to enable the save default function, uncomment the following\n"
  "# line, and set GRUB_DEFAULT to saved.\n"
  "GRUB_SAVEDEFAULT=true\n"))
   
  {:raw "GRUB_CMDLINE_LINUX=\"\"" :value ""})

(t.eq (logic.get-cmdline-linux (.. 
  "GRUB_DISTRIBUTOR=\"Manjaro\"\n"
  "GRUB_CMDLINE_LINUX=\"quiet apparmor=1 security=apparmor\"\n"
  "# If you want to enable the save default function, uncomment the following\n"
  "# line, and set GRUB_DEFAULT to saved.\n"
  "GRUB_SAVEDEFAULT=true\n"))
   
  {:raw   "GRUB_CMDLINE_LINUX=\"quiet apparmor=1 security=apparmor\""
   :value "quiet apparmor=1 security=apparmor"})

(t.eq (logic.parse-cmdline-linux
        {:raw   "GRUB_CMDLINE_LINUX=\"quiet apparmor=1 security=apparmor\""
         :value "quiet apparmor=1 security=apparmor"})
  {:raw "GRUB_CMDLINE_LINUX=\"quiet apparmor=1 security=apparmor\""
   :options [{:key "quiet"}
             {:key "apparmor" :value "1"}
             {:key "security" :value "apparmor"}]})

(t.eq (logic.build
  [{:key "quiet"}
   {:key "apparmor" :value "1"}
   {:key "security" :value "apparmor"}])
   "GRUB_CMDLINE_LINUX=\"quiet apparmor=1 security=apparmor\"")

(t.eq (logic.apply (.. 
  "GRUB_DISTRIBUTOR=\"Manjaro\"\n"
  "GRUB_CMDLINE_LINUX=\"\"\n"
  "# If you want to enable the save default function, uncomment the following\n"
  "# line, and set GRUB_DEFAULT to saved.\n"
  "GRUB_SAVEDEFAULT=true\n")
  [{:key "quiet"}
             {:key "apparmor" :value "1"}
             {:key "security" :value "apparmor"}])

  {:previous "GRUB_CMDLINE_LINUX=\"\""
   :new "GRUB_CMDLINE_LINUX=\"quiet apparmor=1 security=apparmor\""})

(t.run!)
