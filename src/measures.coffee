libAsync = require "async"
libUsage = require "usage"
libEvents = require "events"
libHttp = require "http"


module.exports = exports = class Measures extends libEvents.EventEmitter
  # Some default measurements
  # Though this constructor is synchronous, one can pass an optional callback
  constructor: (cb) ->
    # Keep track of what we want to measure
    @measuring = {}
    @names = []

    # Keep track of one sample
    @sample = null

    # Tell monitor to repeat or not to repeat measuring
    @repeat = true

    # Keep track of timeout, to enable real stop function
    @timeoutId = null

    @addMeasure "when", (cb) ->  cb(null, new Date())
    @addMeasure "cpu", (cb) -> 
      libUsage.lookup process.pid, keepHistory: false, (err, result) ->
        return cb(err) if err
        cb(null, result.cpu)
    @addMeasure "memory", (cb) -> cb(null, process.memoryUsage())

    cb() if cb and typeof cb is "function"


  # Start sampling. Sampling will be repeated every 5000 ms (default) or 
  # whatever is defined there.
  start: (@samplingRate = 5000, @hostname = "127.0.0.1", @port = 58241) ->
    libAsync.doWhilst @takeSample.bind(@), ( () => @repeat).bind(@), (err) =>
      return @emit("error", err) if err
      @emit("finished")

  # Stop sampling as soon as possible
  # Though this function is synchronous, one can pass an optional callback
  stop: (cb) ->
    @repeat = false
    clearTimeout(@timeoutId)
    cb() if cb and typeof cb is "function"


  # Other modules can add stuff that they like to have measured. Use like this:
  # addMeasure("niceVariable", getNiceVariable)
  addMeasure: (name, samplingFunc) ->
    return if not name or not samplingFunc
    if not (typeof name is "string") and not (name instanceof String)
      throw Error("name is not a string")
    if not (typeof samplingFunc is "function")
      throw Error("samplingFunc is not a function")
    @measuring[name] = samplingFunc
    @names = Object.keys(@measuring)


  # Taking one sample for all defined names
  takeSample: (cb) ->
    @sample = {}
    # For every name (like cpu, memory), call the iterator
    libAsync.each @names, @callSamplingFunc.bind(@), (err) =>
      return @emit("error", err) if err
      # When we're done with one sample take, try to send that to the
      # monitoring server (verkehrsmonitor)

      # First, let's prepare the sample to be sent over the wire
      data = JSON.stringify(@sample)

      # Build the parameters to communicate with the verkehrsmonitor
      params =
        hostname: @hostname
        port: @port
        method: "POST"
        path: "/sample"
        headers: 
          "content-type": "application/json"  # express.js likes json
          "content-length": Buffer.byteLength(data)

      # Make the request and send data. If we can't connect to the server,
      # just print it the stdout
      req = libHttp.request params
      req.on "error", (err) => 
        msg = "Could not connect to verkehrsmonitor using #{@hostname}:#{@port}"
        @emit("warning", {msg: msg, sample: @sample})
      req.end(data)

      # Also emit that we did the sampling
      @emit("sampled", @sample)

      # Wait some time before finishing
      @timeoutId = setTimeout cb, @samplingRate


  # Called for every name (like cpu, memory)
  callSamplingFunc: (name, cb) ->
    # Find out how we can sample and then do it!
    samplingFunc = @measuring[name]
    samplingFunc (err, result) =>
      return cb(err) if err
      @sample[name] = result
      cb()
