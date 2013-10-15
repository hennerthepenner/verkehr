libHttp = require "http"
verkehr = require "../"


describe "Monitoring Server", () ->
  server = null

  before (cb) -> server = new verkehr.Server(cb)

  it "should start and stop", (cb) ->
    server.once "started", () ->
      server.once "stopped", cb
      server.stop()
    server.start()

  it "should receive samples", (cb) ->
    server.once "started", () ->
      hostname = "127.0.0.1"
      port = 10000
      data = JSON.stringify({hello: "world"})
      params =
        hostname: hostname
        port: port
        method: "POST"
        path: "/sample"
        headers: 
          "content-type": "application/json"
          "content-length": Buffer.byteLength(data)
      req = libHttp.request params, (res) ->
        if 200 <= res.statusCode < 300
          server.stop()
          cb()
        else
          cb(res.statusCode)
      req.end(data)
    server.start()
