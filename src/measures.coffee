libAsync = require "async"
libUsage = require "usage"
libEvents = require "events"


module.exports = exports = class Measures extends libEvents.EventEmitter
  # Keep track of what we want to measure
  measuring: {}
  names: []

  # Keep track of samples
  # TODO: instead of stacking them here in memory, send away via network
  samples: []
  sample: null

  # Tell monitor to repeat or not to repeat measuring
  repeat: true

  # Keep track of timeout, to enable real stop function
  timeoutId: null

  # Some default measurements
  # Though this constructor is synchronous, one can pass an optional callback
  constructor: (cb) ->
    @addMeasure "when", (cb) ->  cb(null, new Date())
    @addMeasure "cpu", (cb) -> 
      libUsage.lookup process.pid, keepHistory: false, (err, result) ->
        return cb(err) if err
        cb(null, result.cpu)
    @addMeasure "memory", (cb) -> cb(null, process.memoryUsage())

    cb() if typeof cb is "function"


  # Other modules can add stuff they like to have measure. Use like this:
  # addMeasure("niceVariable", getNiceVariable)
  addMeasure: (name, samplingFunc) ->
    return if not name or not samplingFunc
    if not (typeof name is "string") and not (name instanceof String)
      throw Error("name is not a string")
    if not (typeof samplingFunc is "function")
      throw Error("samplingFunc is not a function")
    @measuring[name] = samplingFunc
    @names = Object.keys(@measuring)

  # Called for every name (like cpu, memory)
  callSamplingFunc: (name, cb) ->
    # Find out how we can sample and then do it!
    samplingFunc = @measuring[name]
    samplingFunc (err, result) =>
      return cb(err) if err
      @sample[name] = result
      cb()

  # Taking one sample for all defined names
  takeSample: (cb) ->
    @sample = {}
    # For every name (like cpu, memory), 
    # call the iterator and add sample to list
    libAsync.each @names, @callSamplingFunc.bind(@), (err) =>
      return @emit("error", err) if err
      @emit("sampled", @sample)
      @samples.push(@sample)
      # Wait some time before finishing
      @timeoutId = setTimeout cb, @samplingRate

  # Start sampling. Sampling will be repeated every 5000 ms (default) or 
  # whatever is defined there.
  start: (@samplingRate = 5000) ->
    libAsync.doWhilst @takeSample.bind(@), ( () => @repeat).bind(@), (err) =>
      return @emit("error", err) if err
      @emit("finished", @samples)

  # Stop sampling as soon as possible
  # Though this function is synchronous, one can pass an optional callback
  stop: (cb) ->
    @repeat = false
    clearTimeout(@timeoutId)
    cb() if typeof cb is "function"
