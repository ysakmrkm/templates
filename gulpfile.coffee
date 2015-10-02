gulp = require('gulp')
compass = require('gulp-compass')
coffee = require('gulp-coffee')
concat = require('gulp-concat')
sourcemaps = require('gulp-sourcemaps')
plumber = require('gulp-plumber')
debug = require('gulp-debug')
cache = require('gulp-cached')
remember = require('gulp-remember')
watch = require('gulp-watch')
jade = require('gulp-jade')
jadeRef = require('gulp-jade/node_modules/jade')
rename = require('gulp-rename')
del = require('del')
gulpif = require('gulp-if')
uglify = require('gulp-uglify')
data = require('gulp-data')
notifier = require('node-notifier')
browserSync = require('browser-sync').create()

basePath = ''

gulp.task 'webserver',() ->
  browserSync.init(
    proxy: 'localhost/project_name/'
    notify: false
  )

jadeRef.filters.php = (block) ->
  return "\n<?php\n"+block+"\n?>"

gulp.task 'compass',() ->
  gulp.src basePath+'sass/**/*.scss'
    .pipe cache('compass')
    .pipe debug(title: 'start compass:')
    .pipe plumber(
      errorHandler: (error)->
        console.log error
        this.emit('end')
    )
    .pipe compass(
      config_file : './config.rb'
      comments : false
      css : basePath+'css'
      sass: basePath+'sass'
    )
    .pipe gulp.dest(basePath+'css/')
    .pipe debug(title: 'end compass:')
    .pipe remember('compass')

gulp.task 'sprite', ['compass'],() ->
  del basePath+'img/*-s+([a-z0-9]).png'

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
      .pipe debug(title: 'start concat:')
      .pipe concat(target)
      .pipe gulp.dest('cs/')
      .pipe debug(title: 'end concat:')

gulp.task 'coffee', () ->
  gulp.src [basePath+'cs/*.coffee']
    .pipe cache('coffee')
    .pipe debug(title: 'start coffee:')
    .pipe plumber(
      errorHandler: (error)->
        console.log error
        this.emit('end')
    )
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

gulp.task 'watch', () ->
  watch basePath+'cs/pages/*.coffee', (e)->
    doConcat(e.path)

  watch basePath+'sass/**/*.scss', ->
    gulp.start(['compass', 'sprite'])
  watch basePath+'cs/**/*.coffee', ->
    gulp.start 'coffee'

  watch basePath+'src/jade/**/*.jade', (e)->
    gulp.task 'jade', ()->
      path = e.path

      partial = ()->
        return /\/_[^\/]+\.jade/.test(path)

      if path?
        if partial()
          path = [basePath+'src/jade/**/*.jade', '!'+basePath+'src/jade/**/_*.jade']
          destPath = ''
        else
          destPath = path.split(basePath+'src/jade/')[1].split('/')[0]+'/'

          if destPath.indexOf('.') isnt -1
            destPath = ''

        gulp.src path
          .pipe gulpif(!partial(), cache('jade'))
          .pipe debug(title: 'start jade:')
          .pipe plumber(
            errorHandler: (error)->
              console.log error

              notifier.notify(
                title: 'gulp'
                message: error
              )

              this.emit('end');
          )
          .pipe data(() ->
            return require('./'+basePath+'src/jade/data.json')
          )
          .pipe jade(
            pretty: true
          )
          .pipe rename(
            extname: '.php'
          )
          #.pipe gulp.dest(basePath+'views/pc/'+destPath)
          .pipe gulp.dest(basePath+destPath)
          .pipe debug(title: 'end jade:')
          .pipe gulpif(!partial(), remember('jade'))
          .on('end',
            ()->
              browserSync.reload()
          )

    gulp.start 'jade'

gulp.task 'default', ['watch', 'webserver']
