watch = require 'gulp-watch'

module.exports = (gulp) ->
  gulp.task 'watch', ->
    gulp.watch [
      '+(src)/*.+(coffee)'
    ], ['spec']
    return