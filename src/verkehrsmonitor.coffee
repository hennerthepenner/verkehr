#! /usr/bin/env node

verkehr = require("./")


printHelp = () ->
  console.log "Usage: verkehrsmonitor [<port> [<hostname> [<backlog>]]]"

checkInputAndStart = () ->
  port = undefined
  hostname = undefined
  backlog = undefined

  # When user gives no options at all, server starts on default port, but let's
  # check if maybe he supplied us with some inputs...

  # First argument could be "help" or a port between 1 and 65535
  if process.argv.length > 2
    arg = process.argv[2]
    if arg is "help" or arg is "-h" or arg is "--help"
      return printHelp()
    else
      testPort = parseInt(arg, 10)
      if 1 <= testPort <= 65535
        port = testPort
      else
        return printHelp()

  # Second argument could be hostname
  if process.argv.length > 3
    hostname = process.argv[3]

  # Thirst argument could be backlog
  if process.argv.length > 4
    backlog = parseInt(process.argv[4], 10)

  # Finally start the server
  s = new verkehr.Server()
  s.start(port, hostname, backlog)
  s.on "info", (info) -> console.log info

checkInputAndStart()
