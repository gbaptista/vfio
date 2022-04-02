(local t (require :fspec))

(local helper (require :vfio.helpers.string))

(t.eq (helper.strip "/folder/file\n") "/folder/file")
(t.eq (helper.strip-dash "-force") "force")
(t.eq (helper.split "=" "a=b c = d") ["a" "b c " " d"])

(t.eq (helper.gsub-raw "/folder/file" "file" "blue") "/folder/blue")
(t.eq (helper.gsub-raw "/folder/file" "/folder" "blue") "blue/file")

(t.eq (helper.gsub-raw "/folder/file" "red" "blue") "/folder/file")

(t.eq (helper.gsub-raw
  "\nGRUB_CMDLINE_LINUX=\"rd.driver.pre=vfio-pci\"\n"
  "GRUB_CMDLINE_LINUX=\"rd.driver.pre=vfio-pci\""
  "blue")
  "\nblue\n")

(t.eq (helper.strip "  /folder/file  \n") "/folder/file")

(t.run!)
