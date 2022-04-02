(local t (require :fspec))

(local logic (require :vfio.logic.lspci))

(t.eq
  (logic.parse-devices "0000:00:00.0 \"Host bridge\" \"Intel Corporation\" \"Ice Lake-LP Processor Host Bridge/DRAM Registers\" -r03 \"Dell\" \"Device 096d\"\n0000:00:02.0 \"VGA compatible controller\" \"Intel Corporation\" \"Iris Plus Graphics G7\" -r07 \"Dell\" \"Device 096d\"")
  [{:address {:bus "00" :device "00" :domain "0000" :function "0" :id "0000:00:00.0"}
    :class "Host bridge"
    :name "Ice Lake-LP Processor Host Bridge/DRAM Registers"
    :vendor "Intel Corporation"}
   {:address {:bus "00" :device "02" :domain "0000" :function "0" :id "0000:00:02.0"}
    :class "VGA compatible controller"
    :name "Iris Plus Graphics G7"
    :vendor "Intel Corporation"}])

(t.eq
  (logic.parse-device "0000:00:15.1 \"Serial bus controller\" \"Intel Corporation\" \"Ice Lake-LP Serial IO I2C Controller #1\" -r30 \"Dell\" \"Device 096d\"")
  {:address {:id "0000:00:15.1" :domain "0000" :bus "00" :device "15" :function "1"}
   :class "Serial bus controller"
   :vendor "Intel Corporation"
   :name "Ice Lake-LP Serial IO I2C Controller #1"})

(t.eq
  (logic.device-to-list "0000:00:15.1 \"Serial bus controller\" \"Intel Corporation\" \"Ice Lake-LP Serial IO I2C Controller #1\" -r30 \"Dell\" \"Device 096d\"")
  ["0000:00:15.1"
   "Serial bus controller"
   "Intel Corporation"
   "Ice Lake-LP Serial IO I2C Controller #1"
   "-r30"
   "Dell"
   "Device 096d"])

(t.eq
  (logic.parse-address "0000:00:15.1")
  {:id "0000:00:15.1" :domain "0000" :bus "00" :device "15"  :function "1" })

(t.eq
  (logic.parse-address "00:15.1")
  {:id "00:15.1" :bus "00" :device "15"  :function "1" })

(t.eq
  (logic.list-to-named
    ["0000:00:15.1"
     "Serial bus controller"
     "Intel Corporation"
     "Ice Lake-LP Serial IO I2C Controller #1"
     "-r30"
     "Dell"
     "Device 096d"])
  {:address {:id "0000:00:15.1" :domain "0000" :bus "00" :device "15" :function "1"}
   :class "Serial bus controller"
   :vendor "Intel Corporation"
   :name "Ice Lake-LP Serial IO I2C Controller #1"})

(t.run!)
