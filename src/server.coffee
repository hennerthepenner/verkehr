libExpress = require "express"
libHttp = require "http"
libEvents = require "events"
libPath = require "path"


module.exports = exports = class Server extends libEvents.EventEmitter
  @states: [STATE_STOPPED = 1, STATE_STARTING = 2, STATE_STARTED = 3]

  # Setup express.js app
  constructor: (cb) ->
    @recentSamples = {}
    @app = libExpress()
    @app.use(libExpress.bodyParser())
    @state = STATE_STOPPED
    @emit("initialized")
    @emit("stopped")
    @app.get "/data", @handleData.bind(@)
    @app.post "/sample", @handleSample.bind(@)
    @app.use(libExpress.static(libPath.join(__dirname, "..", "client")))
    @port = undefined
    @hostname = undefined

    cb() if cb and typeof cb is "function"

  # Setup http server and start listening. Available options are passed to the
  # node.js http server
  start: (port = 58241, hostname = undefined, backlog = undefined) ->
    if @state is STATE_STOPPED
      @httpServer = libHttp.createServer(@app)
      @state = STATE_STARTING
      @emit("starting")

      @httpServer.listen port, hostname, backlog, () =>
        @port = port
        @hostname = @httpServer.address().address
        @state = STATE_STARTED
        @emit("started")
        @emit("info", "Monitoring server started on port #{port}.")

  stop: (cb) ->
    if @state is STATE_STARTED
      @httpServer.close()
      @port = undefined
      @hostname = undefined
      @emit("info", "Monitoring server stopped.")
      @state = STATE_STOPPED
      @emit("stopped")
    cb() if cb and typeof cb is "function"
  

  handleData: (req, res) ->
    res.send(200, JSON.stringify(@recentSamples))

  handleSample: (req, res) ->
    store = @recentSamples[req.body.uuid] = {}
    for name, value of req.body
      store[name] = value if name isnt "uuid"
      @emit("sample", req.body)
      res.send(201)
