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

csCommonFolder = 'core'
csFolder = 'pages'
csConcatRules = [
  ['src/cs/'+csCommonFolder+'/common.coffee' , 'src/cs/'+csFolder+'/index.coffee']
  ['src/cs/'+csCommonFolder+'/common.coffee' , 'src/cs/'+csFolder+'/about.coffee']
]

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

gulp.task 'watch', () ->
  watch [basePath+'src/cs/**/*.coffee', '!'+basePath+'src/cs/*.coffee'], (e)->
    path = e.path

    if path?
      folder = path.split('/').reverse()[1]
      target = path.split('/').reverse()[0]

    common = ()->
      return folder is csCommonFolder

    gulp.task 'concat', (callback)->
      src = []

      `getSrc://`
      for set, i in csConcatRules
        for file, j in set
          if file.indexOf(target) isnt -1
            src[0] = set
            `break getSrc`

      if common()
        src = csConcatRules

      waitMax   = src.length
      waitCount = 0

      onEnd = ()->
        if waitMax is ++waitCount
          callback()

      for key, val of src
        if common()
          target = val[1].split('/').reverse()[0]

        gulp.src val
          .pipe debug(title: 'start concat:')
          .pipe plumber(
            errorHandler: (error)->
              console.log error

              notifier.notify(
                title: 'gulp'
                message: error
              )

              this.emit('end')
          )
          .pipe concat(target)
          .pipe gulp.dest('src/cs/')
          .pipe debug(title: 'end concat:')
          .on 'finish', ()->
            onEnd()

    gulp.task 'coffee', ['concat'], ()->
      if common()
        regexp = new RegExp(csCommonFolder+'.*$')
        path = path.replace(regexp, '*.coffee')
      else
        path = path.replace('/'+csFolder, '')

      gulp.src path
        .pipe debug(title: 'start coffee:')
        .pipe gulpif(!common(), cache('coffee'))
        .pipe plumber(
          errorHandler: (error)->
            console.log error

            notifier.notify(
              title: 'gulp'
              message: error
            )

            this.emit('end')
        )
        #.pipe uglify()
        .pipe sourcemaps.init()
        .pipe coffee(
          bare: true
        )
        .pipe sourcemaps.write(
          './'
          sourceRoot: '../'+basePath+'src/cs/'
        )
        .pipe gulp.dest(basePath+'js/')
        .pipe gulpif(!common(), remember('coffee'))
        .pipe debug(title: 'end coffee:')
        .on('end',
          ()->
            browserSync.reload()
        )

    gulp.start 'coffee'

  watch basePath+'sass/**/*.scss', ->
    gulp.start(['compass', 'sprite'])

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
