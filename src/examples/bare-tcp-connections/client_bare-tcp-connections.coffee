verkehr = require "../../"  # Uh, we're actually inside a folder in examples
libTcp = require "net"


maxConnections = 5


measures = new verkehr.Measures()
conns = 0
measures.addMeasure "connections", (cb) -> cb(null, conns)
measures.start()

[0...maxConnections].forEach () ->
  conn = libTcp.connect {port: 9999}, () -> conns++
  conn.on "end", () -> conns--
