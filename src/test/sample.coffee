libShould = require "should"
Measures = require "../lib/measure"


describe "Sample", () ->
  sample = null
  measures = null

  before (cb) ->
    measures = new Measures()
    measures.once "sampled", (_sample) ->
      sample = _sample
      cb()
    measures.start()
  after (cb) -> measures.stop(cb)

  it "should have a default property 'when' (Date)", (cb) ->
    sample.should.have.property "when"
    sample.when.should.be.an.instanceOf Date
    cb()

  it "should have a default property 'cpu' (Number)", (cb) ->
    sample.should.have.property "cpu"
    sample.cpu.should.be.an.Number
    cb()

  it "should have a default property 'memory' (Hash)", (cb) ->
    sample.should.have.property "memory"
    # Node provides a hash with some data
    mem = sample.memory
    mem.should.have.property "rss"
    mem.should.have.property "heapTotal"
    mem.should.have.property "heapUsed"
    cb()
