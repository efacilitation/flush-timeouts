mocha       = require 'gulp-mocha'
runSequence = require 'run-sequence'
fs          = require 'fs'

module.exports = (gulp) ->
  gulp.task 'spec', (next) ->
    runSequence 'spec:server', 'spec:client', next


  gulp.task 'spec:server', ->
    gulp.src([
      'src/server_spec_setup.coffee'
      'src/flush_timeouts.coffee'
      'src/flush_timeouts.spec.coffee'
      ])
      .pipe(mocha(reporter: 'spec'))


  gulp.task 'spec:client', (next) ->
    executeChildProcess = require './helper/child_process'
    executeChildProcess(
      'Karma specs'
      'node_modules/karma/bin/karma start'
      next
    )
