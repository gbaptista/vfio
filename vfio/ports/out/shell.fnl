(local port {})

(fn port.dispatch! [data]
  (print data))

(fn port.retrieve! []
  (io.read "*line"))

port
