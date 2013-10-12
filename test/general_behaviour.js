// Generated by CoffeeScript 1.6.3
(function() {
  var verkehr;

  verkehr = require("../");

  describe("General behaviour", function() {
    return it("should start and stop", function(cb) {
      var measures;
      measures = new verkehr.Measures();
      measures.once("finished", function(samples) {
        return cb();
      });
      measures.start(0);
      return measures.stop();
    });
  });

}).call(this);
