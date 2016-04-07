path = require('path')
gulp = require('gulp')
compass = require('gulp-compass')
forEach = require('gulp-foreach')
grapher = require('sass-graph')
scsslint = require('gulp-scss-lint')
coffee = require('gulp-coffee')
coffeeLint = require('gulp-coffeelint')
concat = require('gulp-concat')
sourcemaps = require('gulp-sourcemaps')
plumber = require('gulp-plumber')
debug = require('gulp-debug')
cache = require('gulp-cached')
remember = require('gulp-remember')
watch = require('gulp-watch')
jade = require('gulp-jade')
jadeRef = require('gulp-jade/node_modules/jade')
puglint = require('gulp-pug-lint')
rename = require('gulp-rename')
del = require('del')
gulpif = require('gulp-if')
uglify = require('gulp-uglify')
data = require('gulp-data')
notify = require('gulp-notify')
browserSync = require('browser-sync').create()

basePath = ''
srcPath = 'src/'
destPath = ''
projectFolder = path.resolve('').split('/').reverse()[0]
gulp.watching = false

gulp.task 'webserver',() ->
  browserSync.init(
    proxy: 'localhost/'+projectFolder+'/'
    notify: false
  )

jadeRef.filters.php = (block) ->
  return "\n<?php\n"+block+"\n?>"

csCommonFolder = 'core'
csFolder = 'pages'
csConcatRules = [
  [srcPath+'cs/'+csCommonFolder+'/common.coffee' , srcPath+'cs/'+csFolder+'/index.coffee']
  [srcPath+'cs/'+csCommonFolder+'/common.coffee' , srcPath+'cs/'+csFolder+'/about.coffee']
]

gulp.task 'sass', ->
  baseDir = srcPath+destPath+"sass/"
  graph = grapher.parseDir(baseDir)
  files = []

  gulp.src "#{baseDir}**/*.scss"
    .pipe debug(title: 'start compass:')
    .pipe plumber(
      errorHandler:
        notify.onError(
          title: "sass compile error"
          message: "<%= error %>"
        )

      this.emit('end')
    )
    .pipe cache('sass')
    .pipe gulpif(@watching, forEach (currentStream, file) ->
      files = [file.path]

      addParent = (childPath)->
        graph.visitAncestors childPath, (parent) ->
          files.push(parent)
          addParent(parent)

      addParent(file.path)

      gulp.src files, {base: baseDir}
    )
    .pipe debug(title: 'sass compile:'+files)
    .pipe debug(title: 'start lint:')
    .pipe scsslint('config': 'scss-lint.yml')
    .pipe debug(title: 'end lint:')
    .pipe compass(
      config_file : './config.rb'
      comments : false
      css : basePath+'css/'
      sass: basePath+srcPath+'sass/'
      #environment: 'production'
    )
    .pipe gulp.dest(destPath+"css")
    .pipe debug(title: 'end compass:')
    .on('end',
      ()->
        console.log 'start splite:'
        del basePath+'img/**/*-s+([a-z0-9]).png'
        console.log 'end splite:'
        browserSync.reload()
    )

gulp.task 'watch', () ->
  @watching = true
  taskCount =
    coffee: 0
    jade: 0

  gulp.watch srcPath+"**/sass/**/*.scss", ['sass']

  watch [basePath+srcPath+'cs/**/*.coffee', '!'+basePath+srcPath+'cs/*.coffee'], (e)->
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
            errorHandler:
              notify.onError(
                title: "coffee concat error"
                message: "<%= error %>"
              )

            this.emit('end')
          )
          .pipe concat(target)
          .pipe gulp.dest(srcPath+'cs/')
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
          errorHandler:
            notify.onError(
              title: "coffee compile error"
              message: "<%= error %>"
            )

          this.emit('end')
        )
        .pipe coffeeLint('./coffeelint.json')
        .pipe coffeeLint.reporter('coffeelint-stylish')
        #.pipe uglify()
        .pipe sourcemaps.init()
        .pipe coffee(
          bare: true
        )
        .pipe sourcemaps.write(
          './'
          sourceRoot: '../'+basePath+srcPath+'cs/'
        )
        .pipe gulp.dest(basePath+'js/')
        .pipe gulpif(!common(), remember('coffee'))
        .pipe debug(title: 'end coffee:')
        .on('end',
          ()->
            browserSync.reload()
        )

    gulp.start 'coffee'

  watch basePath+srcPath+'jade/**/*.jade', (e)->
    gulp.task 'jade', ()->
      path = e.path

      gulp.src path
        .pipe puglint()

      partial = ()->
        return /\/_[^\/]+\.jade/.test(path)

      if path?
        if partial()
          path = [basePath+srcPath+'jade/**/*.jade', '!'+basePath+'src/jade/**/mixin.jade', '!'+basePath+srcPath+'jade/**/_*.jade']
          jadeDestPath = ''
        else
          jadeDestPath = path.split(basePath+srcPath+'jade/')[1].split('/')
          jadeDestPath.pop()
          jadeDestPath = jadeDestPath.join('/')+'/'

          if jadeDestPath.indexOf('.') isnt -1 or jadeDestPath is '/'
            jadeDestPath = ''

        gulp.src path
          .pipe gulpif(!partial(), cache('jade'))
          .pipe debug(title: 'start jade:')
          .pipe plumber(
            errorHandler:
              notify.onError(
                title: "jade compile error"
                message: "<%= error %>"
              )

            this.emit('end')
          )
          .pipe data(() ->
            return require('./'+basePath+srcPath+'jade/data.json')
          )
          .pipe jade(
            pretty: true
          )
          .pipe rename(
            extname: '.php'
          )
          #.pipe gulp.dest(basePath+'views/pc/'+jadeDestPath)
          .pipe gulp.dest(basePath+jadeDestPath)
          .pipe debug(title: 'end jade:')
          .pipe gulpif(!partial(), remember('jade'))
          .on('end',
            ()->
              browserSync.reload()
          )

    gulp.start 'jade'

gulp.task 'default', ['webserver', 'watch']
