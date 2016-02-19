KarmaServer = require('karma').Server
process.env.DISPLAY = ':10'
karmaServer = new KarmaServer configFile: process.env.karmaConf, (exitCode) ->
  process.exit exitCode
karmaServer.start()
