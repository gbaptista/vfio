; TODO: Why not VFIO-PCI over PCI-STUB?
; https://unix.stackexchange.com/questions/328422/pci-stub-vs-vfio-pci

(local helper/list (require :vfio.helpers.list))

(local logic {
  :options
  {:intel_iommu   {:key :intel_iommu :value "on"
                   :description "Enable IOMMU on Intel CPU."}
   :iommu         {:key :iommu :value "pt"
                   :description "Skip devices that cannot be passed through."}
   :pci-stub.ids  {:key :pci-stub.ids :value nil
                   :description "Bind the following devices to ensure that they will be available for the VM:"}
   :rd.driver.pre {:key :rd.driver.pre :value "vfio-pci"
                   :description "Early load vfio-pci Kernel Driver."}}})

(fn logic.build-options-for [devices]
  (let [options (helper/list.deep-shallow-copy logic.options)
        devices-ids (collect [key device (pairs devices)] key device.id)]
    (tset
      (. options :pci-stub.ids)
      :value
      (->> devices-ids
        (helper/list.sort)
        (helper/list.join ",")))

    (when (= (length devices-ids) 0)
      (tset options :pci-stub.ids nil)
      (tset options :rd.driver.pre nil))

    (local built-options [])

    (each [_ option (pairs options)]
      (table.insert built-options option))

    (->>
      built-options
      (helper/list.sort-by :value)
      (helper/list.sort-by :key))))

logic
