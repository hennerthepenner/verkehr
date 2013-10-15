verkehr = require "../"


describe "General behaviour of measuring", () ->
  it "should start and stop", (cb) ->
    measures = new verkehr.Measures()
    measures.once "finished", () -> cb()
    measures.start(0)
    measures.stop()
