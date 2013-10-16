verkehr = require "../../"  # Uh, we're actually inside a folder in examples
libTcp = require "net"


maxConnections = 1000


measures = new verkehr.Measures()
conns = 0
requests = 0
ok = 0
measures.addMeasure "connections", (cb) -> cb(null, conns)
measures.addMeasure "requests", (cb) -> cb(null, requests)
measures.addMeasure "ok", (cb) -> cb(null, ok)
measures.start()

prettyNum = (num) ->
  return "000#{num}" if num < 10
  return "00#{num}" if num < 100
  return "0#{num}" if num < 1000
  return "#{num}"

[0...maxConnections].forEach () ->
  num1 = Math.floor(Math.random() * 9999)
  num2 = Math.floor(Math.random() * 9999)
  expected = num1 + num2
  returned = new Buffer(8)
  pointer = 0
  conn = libTcp.connect {port: 9999}, () -> 
    conns++
    conn.write(prettyNum(num1) + prettyNum(num2))
    requests++
  conn.on "data", (chunk) ->
    for b in chunk
      returned[pointer] = b
      pointer++
      if pointer is 8
        pointer = 0
        result = parseInt(returned.toString())
        if result is expected
          ok++
        else
          console.log "Was #{result} but expected #{expected}"
        num1 = Math.floor(Math.random() * 9999)
        num2 = Math.floor(Math.random() * 9999)
        expected = num1 + num2
        conn.write(prettyNum(num1) + prettyNum(num2))    
  conn.on "end", () -> conns--
