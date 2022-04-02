(local t (require :fspec))

(local logic (require :vfio.logic.config))

(t.eq
  (logic.hydrate
    {:8086:8a52 { :passthrough "true"}}
    [{:address {:bus "00" :device "00" :domain "0000" :function "0" :id "0000:00:00.0"}
      :id "8086:8a12"
      :class "Host bridge"
      :name "Ice Lake-LP Processor Host Bridge/DRAM Registers"
      :vendor "Intel Corporation"}
     {:address {:bus "00" :device "02" :domain "0000" :function "0" :id "0000:00:02.0"}
      :id "8086:8a52"
      :class "VGA compatible controller"
      :name "Iris Plus Graphics G7"
      :vendor "Intel Corporation"}])
  [{:address {:bus "00" :device "00" :domain "0000" :function "0" :id "0000:00:00.0"}
    :id "8086:8a12"
    :class "Host bridge"
    :name "Ice Lake-LP Processor Host Bridge/DRAM Registers"
    :vendor "Intel Corporation"
    :config {:passthrough false}}
   {:address {:bus "00" :device "02" :domain "0000" :function "0" :id "0000:00:02.0"}
    :id "8086:8a52"
    :class "VGA compatible controller"
    :name "Iris Plus Graphics G7"
    :vendor "Intel Corporation"
    :config {:passthrough true}}])

(t.run!)
