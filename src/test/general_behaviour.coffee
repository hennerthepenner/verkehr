verkehr = require "../"


describe "General behaviour", () ->
  it "should start and stop", (cb) ->
    measures = new verkehr.Measures()
    measures.once "finished", (samples) -> cb()
    measures.start(0)
    measures.stop()
