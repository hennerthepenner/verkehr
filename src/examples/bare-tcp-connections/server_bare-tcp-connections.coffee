verkehr = require "../../"  # Uh, we're actually inside a folder in examples
libTcp = require "net"


server = libTcp.createServer()
server.listen(9999)

measures = new verkehr.Measures()
measures.addMeasure "clients", (cb) -> server.getConnections(cb)
measures.start()
