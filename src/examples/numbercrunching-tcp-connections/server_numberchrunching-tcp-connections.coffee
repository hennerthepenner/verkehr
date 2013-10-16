verkehr = require "../../"  # Uh, we're actually inside a folder in examples
libTcp = require "net"


server = libTcp.createServer()
server.listen(9999)
calculations = 0

measures = new verkehr.Measures()
measures.addMeasure "clients", (cb) -> server.getConnections(cb)
measures.addMeasure "calculations", (cb) -> cb(null, calculations)
measures.start()

prettyNum = (num) ->
  return "0000000#{num}" if num < 10
  return "000000#{num}" if num < 100
  return "00000#{num}" if num < 1000
  return "0000#{num}" if num < 10000
  return "000#{num}" if num < 100000
  return "00#{num}" if num < 1000000
  return "0#{num}" if num < 10000000
  return "#{num}"

server.on "connection", (socket) ->
  request = new Buffer(8)
  pointer = 0
  socket.on "data", (chunk) ->
    for b in chunk
      request[pointer] = b
      pointer++
      if pointer is 8
        pointer = 0
        s = request.toString()
        num1 = parseInt(s.slice(0, 4))
        num2 = parseInt(s.slice(4))
        sum = num1 + num2
        calculations++
        socket.write(prettyNum(sum))
