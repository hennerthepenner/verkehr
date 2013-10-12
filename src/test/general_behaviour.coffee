Measures = require "../lib/measure"


describe "General behaviour", () ->
  it "should start and stop", (cb) ->
    measures = new Measures()
    measures.once "finished", (samples) -> cb()
    measures.start(0)
    measures.stop()
