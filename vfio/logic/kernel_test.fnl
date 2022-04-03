(local t (require :fspec))

(local logic (require :vfio.logic.kernel))

(t.eq (logic.build-options-for
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
