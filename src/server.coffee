libExpress = require "express"
libHttp = require "http"
libEvents = require "events"


module.exports = exports = class Server extends libEvents.EventEmitter
  @states: [STATE_STOPPED = 1, STATE_STARTING = 2, STATE_STARTED = 3]

  # Setup express.js app
  constructor: (cb) ->
    @app = libExpress()
    @app.use(libExpress.bodyParser())
    @state = STATE_STOPPED
    @emit("initialized")
    @emit("stopped")
    @app.post "/sample", @handleSample.bind(@)

    cb() if cb and typeof cb is "function"

  # Setup http server and start listening. Available options are passed to the
  # node.js http server
  start: (port = 10000, hostname = undefined, backlog = undefined) ->
    if @state is STATE_STOPPED
      @httpServer = libHttp.createServer(@app)
      @state = STATE_STARTING
      @emit("starting")

      @httpServer.listen port, hostname, backlog, () =>
        @state = STATE_STARTED
        @emit("started")
        @emit("info", "Monitoring server started on port #{port}.")

  stop: (cb) ->
    if @state is STATE_STARTED
      @httpServer.close()
      @emit("info", "Monitoring server stopped.")
      @state = STATE_STOPPED
      @emit("stopped")
    cb() if cb and typeof cb is "function"
  

  handleSample: (req, res) ->
    for name, value of req.body
      console.log "#{name}: #{value}"
      @emit("sample", req.body)
      res.send(201)
