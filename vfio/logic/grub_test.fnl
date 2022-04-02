(local t (require :fspec))

(local logic (require :vfio.logic.grub))

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

(t.eq (logic.build-kernel-options
  [{:address {:bus "00"
            :device "1f"
            :domain "0000"
            :function "3"
            :id "0000:00:1f.3"}
  :class {:code "0403" :name "Audio device"}
  :config {:passthrough true}
  :id "8086:34c8"
  :name {:code "34c8"
         :name "Ice Lake-LP Smart Sound Technology Audio Controller"}
  :vendor {:code "8086" :name "Intel Corporation"}}])
  
  [{:description "Enable IOMMU on Intel CPU." :key "intel_iommu" :value "on"}
   {:description "Skip devices that cannot be passed through."
    :key "iommu"
    :value "pt"}
   {:description "Bind the following devices to ensure that they will be available for the VM:"
    :key "pci-stub.ids"
    :value "8086:34c8"}
   {:description "Early load vfio-pci Kernel Driver."
    :key "rd.driver.pre"
    :value "vfio-pci"}])

(t.run!)
