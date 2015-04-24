gulp = require('gulp')
compass = require('gulp-compass')
coffee = require('gulp-coffee')
concat = require('gulp-concat')
webserver = require('gulp-webserver')
sourcemaps = require('gulp-sourcemaps')
plumber = require('gulp-plumber')
debug = require('gulp-debug')
cache = require('gulp-cached')
remember = require('gulp-remember')

basePath = ''

gulp.task 'webserver',() ->
  gulp.src './'
    .pipe webserver(
      livereload: true
    )

gulp.task 'compass',() ->
  gulp.src basePath+'sass/**/*.scss'
    .pipe cache('compass')
    .pipe debug(title: 'start compass:')
    .pipe plumber()
    .pipe compass(
      config_file : 'config.rb'
      comments : false
      css : basePath+'css'
      sass: basePath+'sass'
    )
    .pipe gulp.dest(basePath+'css/')
    .pipe debug(title: 'end compass:')
    .pipe remember('compass')

csFiles = [
  ['cs/core/common.coffee' , 'cs/pages/index.coffee']
]

doConcat = (path) ->
  if path?
    target = path.split('/').reverse()[0]

    src = []

    console.log target

    `getSrc://`
    for set, i in csFiles
      for file, j in set
        if file.indexOf(target) isnt -1
          src = set
          `break getSrc`

    console.log src

    gulp.src src
      .pipe concat(target)
      .pipe gulp.dest('cs/')
      .pipe debug()

gulp.task 'concat', () ->
    #gulp.src 'cs/**/*.coffee'
    #  .pipe changed(basePath+'js/')

gulp.task 'coffee', () ->
  gulp.src [basePath+'cs/*.coffee']
    .pipe cache('coffee')
    .pipe debug(title: 'start coffee:')
    .pipe plumber()
    .pipe sourcemaps.init()
    .pipe coffee(
      bare: true
    )
    .pipe sourcemaps.write(
      './'
      sourceRoot: basePath+'cs/'
    )
    .pipe gulp.dest(basePath+'js/')
    .pipe debug(title: 'end coffee:')
    .pipe remember('coffee')

gulp.task 'watch', ['concat'] , () ->
  gulp.watch basePath+'cs/pages/*.coffee'
    .on 'change', (e) ->
      doConcat(e.path)

  gulp.watch basePath+'sass/**/*.scss', ['compass']
  #gulp.watch basePath+'cs/pages/*.coffee', ['concat']
  gulp.watch basePath+'cs/*.coffee', ['coffee']

gulp.task 'default', ['watch', 'webserver']
