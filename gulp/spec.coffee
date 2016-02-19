mocha       = require 'gulp-mocha'
runSequence = require 'run-sequence'
{spawnSync} = require 'child_process'

module.exports = (gulp) ->
  gulp.task 'spec', (callback) ->
    runSequence 'spec:server', 'spec:client', callback


  gulp.task 'spec:server', ->
    gulp.src([
      'src/server_spec_setup.coffee'
      'src/flush_timeouts.coffee'
      'src/flush_timeouts.spec.coffee'
      ])
      .pipe(mocha(reporter: 'spec'))


  gulp.task 'spec:client', ->
    process.env.karmaConf = "#{__dirname}/../karma.conf.coffee"
    spawnResult = spawnSync "coffee", ["#{process.cwd()}/gulp/helper/karma_server.coffee"],
      stdio: [0, 1, 2]

    new Promise (resolve, reject) ->
      if spawnResult.status is 0
        resolve()
      else
        reject new Error 'Karma run failed.'
