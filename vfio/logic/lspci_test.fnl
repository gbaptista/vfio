(local t (require :fspec))

(local logic (require :vfio.logic.lspci))

(t.eq (logic.device-to-list "0000:00:1f.3 \"Audio device [0403]\" \"Intel Corporation [8086]\" \"Ice Lake-LP Smart Sound Technology Audio Controller [34c8]\" -r30 -p80 \"Dell [1028]\" \"Device [096d]\"")
      ["0000:00:1f.3"
       "Audio device [0403]"
       "Intel Corporation [8086]"
       "Ice Lake-LP Smart Sound Technology Audio Controller [34c8]"
       "-r30 -p80"
       "Dell [1028]"
       "Device [096d]"])

(t.eq (logic.parse-name-and-code "Audio device [0403]")
      {:name "Audio device" :code :0403})

(t.eq (logic.list-to-named ["0000:00:1f.3"
                            "Audio device [0403]"
                            "Intel Corporation [8086]"
                            "Ice Lake-LP Smart Sound Technology Audio Controller [34c8]"
                            "-r30 -p80"
                            "Dell [1028]"
                            "Device [096d]"])
      {:address {:bus "00"
           :device "1f"
           :domain "0000"
           :function "3"
           :id "0000:00:1f.3"}
 :class {:code "0403" :name "Audio device"}
 :id "8086:34c8"
 :name {:code "34c8"
        :name "Ice Lake-LP Smart Sound Technology Audio Controller"}
 :vendor {:code "8086" :name "Intel Corporation"}})

(t.eq (logic.parse-devices "0000:00:00.0 \"Host bridge\" \"Intel Corporation\" \"Ice Lake-LP Processor Host Bridge/DRAM Registers\" -r03 \"Dell\" \"Device 096d\"
0000:00:02.0 \"VGA compatible controller\" \"Intel Corporation\" \"Iris Plus Graphics G7\" -r07 \"Dell\" \"Device 096d\"")
      [{:address {:bus :00
                  :device :00
                  :domain :0000
                  :function :0
                  :id "0000:00:00.0"}
        :class {:name "Host bridge"}
        :name {:name "Ice Lake-LP Processor Host Bridge/DRAM Registers"}
        :vendor {:name "Intel Corporation"}}
       {:address {:bus :00
                  :device :02
                  :domain :0000
                  :function :0
                  :id "0000:00:02.0"}
        :class {:name "VGA compatible controller"}
        :name {:name "Iris Plus Graphics G7"}
        :vendor {:name "Intel Corporation"}}])

(t.eq (logic.parse-device "0000:00:15.1 \"Serial bus controller\" \"Intel Corporation\" \"Ice Lake-LP Serial IO I2C Controller #1\" -r30 \"Dell\" \"Device 096d\"")
      {:address {:bus :00
                 :device :15
                 :domain :0000
                 :function :1
                 :id "0000:00:15.1"}
       :class {:name "Serial bus controller"}
       :name {:name "Ice Lake-LP Serial IO I2C Controller #1"}
       :vendor {:name "Intel Corporation"}})

(t.eq (logic.device-to-list "0000:00:15.1 \"Serial bus controller\" \"Intel Corporation\" \"Ice Lake-LP Serial IO I2C Controller #1\" -r30 \"Dell\" \"Device 096d\"")
      ["0000:00:15.1"
       "Serial bus controller"
       "Intel Corporation"
       "Ice Lake-LP Serial IO I2C Controller #1"
       :-r30
       :Dell
       "Device 096d"])

(t.eq (logic.parse-address "0000:00:15.1")
      {:bus :00 :device :15 :domain :0000 :function :1 :id "0000:00:15.1"})

(t.eq (logic.parse-address "00:15.1")
      {:bus :00 :device :15 :function :1 :id "00:15.1"})

(t.eq (logic.list-to-named ["0000:00:15.1"
                            "Serial bus controller"
                            "Intel Corporation"
                            "Ice Lake-LP Serial IO I2C Controller #1"
                            :-r30
                            :Dell
                            "Device 096d"])
      {:address {:bus :00
                 :device :15
                 :domain :0000
                 :function :1
                 :id "0000:00:15.1"}
       :class {:name "Serial bus controller"}
       :name {:name "Ice Lake-LP Serial IO I2C Controller #1"}
       :vendor {:name "Intel Corporation"}})

(t.run!)
