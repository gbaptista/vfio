(local t (require :fspec))

(local component (require :vfio.components.io))

(t.eq (component.exists? "vfio/components/io.fnl") true)
(t.eq (component.exists? "iox.fnl") false)

(t.run!)
