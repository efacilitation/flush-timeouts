gulp  = require 'gulp'
gutil = require 'gulp-util'

gulp.on 'err', (e) ->
gulp.on 'task_err', (e) ->
  if process.env.NODE_ENV isnt 'workstation'
    gutil.log e
    process.exit 1

require('./gulp/watch')(gulp)
require('./gulp/spec')(gulp)
require('./gulp/build')(gulp)
require('./gulp/bump')(gulp)
