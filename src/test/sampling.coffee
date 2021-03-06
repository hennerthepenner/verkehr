libShould = require "should"
verkehr = require "../"


describe "Sampling", () ->
  measures = null

  before (cb) -> measures = new verkehr.Measures(cb)
  after (cb) -> measures.stop(cb)

  it "should be extendable", (cb) ->
    x = 23
    measureX = (cb) -> cb(null, x)
    measures.addMeasure("superX", measureX)
    measures.once "sampled", (sample) ->
      sample.should.have.property "superX"
      sample.superX.should.eql x
      cb()
    measures.start()

  it "should accept only strings as name", (cb) ->
    fakeFunc = () -> 42
    ( () -> measures.addMeasure(23, fakeFunc)
    ).should.throw("name is not a string")
    cb()

  it "should accept only functions as samplingFunction", (cb) ->
    ( () -> measures.addMeasure("test", 23)
    ).should.throw("samplingFunc is not a function")
    cb()

  it "should be able to overwrite default measures", (cb) ->
    fakeFunc = (cb) -> cb(null, 42)
    measures.addMeasure("uuid", fakeFunc)
    measures.once "sampled", (sample) ->
      sample.uuid.should.eql 42
      cb()
    measures.start()


describe "Problem during sampling", () ->
  measures = null

  before (cb) -> measures = new verkehr.Measures(cb)
  after (cb) -> measures.stop(cb)

  it "should bubble up as error event", (cb) ->
    # Errors are passed as first argument
    problem = "I am problematic"
    problematicMeasuring = (cb) -> cb(problem)
    measures.addMeasure("superX", problematicMeasuring)
    measures.on "error", (err) ->
      err.should.eql problem
      cb()
    measures.start()


describe "Connection problem", () ->
  measures = null

  before (cb) -> measures = new verkehr.Measures(cb)
  after (cb) -> measures.stop(cb)

  it "should emit a warning including the sample", (cb) ->
    measures.on "warning", (warn) ->
      warn.should.have.property "sample"
      warn.should.have.property "msg"
      warn.msg.should.startWith "Could not connect to verkehrsmonitor"
      cb()
    measures.start()
