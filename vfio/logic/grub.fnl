(local helper/list (require :vfio.helpers.list))
(local helper/string (require :vfio.helpers.string))

; TODO: Why not VFIO-PCI over PCI-STUB?
; https://unix.stackexchange.com/questions/328422/pci-stub-vs-vfio-pci

(local logic {
 :kernel-options
 {:intel_iommu
  {:key :intel_iommu :value "on"
   :description "Enable IOMMU on Intel CPU."}
  :iommu
   {:key :iommu :value "pt"
    :description "Prevent Linux from touching devices that cannot be passed through."}
  :pci-stub.ids
   {:key :pci-stub.ids :value nil
    :description "Bind the following devices to ensure that they will be available for the VM:"}
  :rd.driver.pre
   {:key :rd.driver.pre :value "vfio-pci"
    :description "Early load vfio-pci Kernel Driver."}}})

(fn logic.build-kernel-options [devices]
  (let [kernel-options (helper/list.deep-shallow-copy logic.kernel-options)
        devices-ids (collect [key device (pairs devices)] key device.id)]
    (tset (. kernel-options :pci-stub.ids) :value (helper/list.join "," devices-ids))
    kernel-options))

(fn logic.get-cmdline-linux [raw]
  (var cmdline-linux nil)
  (each [_ line (pairs (helper/string.split "\n" raw))]
    (when (string.find line "^GRUB_CMDLINE_LINUX=")
      (set cmdline-linux line)))
  {:raw cmdline-linux
   :value (-> cmdline-linux
              (string.gsub "^GRUB_CMDLINE_LINUX=\"" "")
              (string.gsub "\"%s*$" ""))})

(fn logic.parse-cmdline-linux [line]
  (local options [])
  (each [_ item (pairs (helper/string.split "%s" line.value))]
    (if (string.find item "=")
      (let [parts (helper/string.split "=" item)]
        (table.insert options {:key (. parts 1) :value (. parts 2)}))
      (table.insert options {:key item})))
  {:raw line.raw :options options})

(fn logic.build [options]
  (local raw "GRUB_CMDLINE_LINUX=\"")
  (local raw-options
    (->> options
      (helper/list.map #(.. $1.key (if $1.value (.. "=" $1.value) "")))
      (helper/list.join " ")))
  (.. raw raw-options "\""))

(fn logic.apply-option! [options to-apply]
  (var found false)

  (each [_ candidate (pairs options)]
    (when (= candidate.key to-apply.key)
      (set found true)
      (tset candidate :value to-apply.value)))

  (if (not found) (table.insert options {:key to-apply.key :value to-apply.value}))
  options)

(fn logic.apply [raw-grub-file kernel-options]
  (let [options (->> raw-grub-file
                  (logic.get-cmdline-linux)
                  (logic.parse-cmdline-linux))]
    (each [_ option (pairs kernel-options)]
      (logic.apply-option! options option))
    {:previous options.raw :new (logic.build options)}))
  
logic
