// Generated by CoffeeScript 1.6.3
(function() {
  var libTcp, measures, server, verkehr;

  verkehr = require("../../");

  libTcp = require("net");

  server = libTcp.createServer();

  server.listen(9999);

  measures = new verkehr.Measures();

  measures.addMeasure("clients", function(cb) {
    return server.getConnections(cb);
  });

  measures.start();

}).call(this);
