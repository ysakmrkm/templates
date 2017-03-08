path = require('path')
gulp = require('gulp')
compass = require('gulp-compass')
forEach = require('gulp-foreach')
grapher = require('sass-graph')
scsslint = require('gulp-scss-lint')
stylefmt = require('gulp-stylefmt')
coffee = require('gulp-coffee')
coffeeLint = require('gulp-coffeelint')
concat = require('gulp-concat-util')
sourcemaps = require('gulp-sourcemaps')
plumber = require('gulp-plumber')
debug = require('gulp-debug')
cache = require('gulp-cached')
remember = require('gulp-remember')
watch = require('gulp-watch')
jade = require('gulp-jade')
jadeRef = require('gulp-jade/node_modules/jade')
puglint = require('gulp-pug-linter')
rename = require('gulp-rename')
del = require('del')
gulpif = require('gulp-if')
uglify = require('gulp-uglify')
notify = require('gulp-notify')
browserSync = require('browser-sync').create()
minimist = require('minimist')
args = minimist(process.argv.slice(2))

# --target
targetFolder = if args.target? and args.target.indexOf('/') is -1 then args.target+'/' else args.target
basePath = if targetFolder? then targetFolder else ''
srcPath = 'src/'
destPath = ''
cssDestDir = 'css'
viewPath = ''
currentPath = path.resolve('')
currentFolder = currentPath.split('/').reverse()[0]
projectFolder = path.resolve('', '../').split('/').reverse()[0]+'/'+currentFolder
gulp.watching = false

gulp.task 'webserver',() ->
  browserSync.init(
    proxy: if targetFolder? then 'localhost/'+currentFolder+'/'+targetFolder else 'localhost/'+currentFolder+'/'
    notify: false
  )

jadeRef.filters.php = (block) ->
  return "\n<?php\n"+block+"\n?>"

csCommonFolder = 'core'
csFolder = 'pages'
csConcatRules = [
  [basePath+srcPath+'cs/'+csCommonFolder+'/functions.coffee',
  basePath+srcPath+'cs/'+csCommonFolder+'/header.coffee',
  basePath+srcPath+'cs/'+csFolder+'/index.coffee',
  basePath+srcPath+'cs/'+csCommonFolder+'/footer.coffee']
]

gulp.task 'stylefmt', ->
  baseDir = basePath+srcPath+"sass/"

  gulp.src "#{baseDir}**/*.scss"
    .pipe debug(title: 'start stylefmt:')
    .pipe cache('stylefmt')
    .pipe stylefmt()
    .pipe debug(title: 'end stylefmt:')
    .pipe remember('stylefmt')
    .pipe gulp.dest(basePath+srcPath+'sass/')

gulp.task 'scsslint', ['stylefmt'], ->
  baseDir = basePath+srcPath+"sass/"

  gulp.src "#{baseDir}**/*.scss"
    .pipe debug(title: 'start lint:')
    .pipe plumber(
      errorHandler:
        notify.onError(
          title: "sass lint error"
          message: "<%= error %>"
        )
    )
    .pipe cache('scsslint')
    .pipe scsslint()
    .pipe debug(title: 'end lint:')
    .pipe remember('scsslint')
    .pipe scsslint.failReporter()

gulp.task 'sass', ['scsslint'], ->
  baseDir = basePath+srcPath+"sass/"
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
    .pipe compass(
      config_file : currentPath+'/config.rb'
      project: currentPath+'/'+basePath
      css : cssDestDir
      sass: srcPath+'sass'
      image: 'img'
      javascript: 'js'
      #environment: 'production'
    )
    .pipe gulp.dest(basePath+destPath+cssDestDir)
    .pipe debug(title: 'end compass:')
    .on('end',
      ()->
        console.log 'start splite:'
        del basePath+'img/**/*-s+([a-z0-9]).png'
        console.log 'end splite:'
        browserSync.reload()
    )

gulp.task 'puglint', ->
  baseDir = basePath+srcPath+"jade/"

  gulp.src "#{baseDir}**/*.jade"
    .pipe debug(title: 'start lint:')
    .pipe cache('puglint')
    .pipe puglint()
    .pipe debug(title: 'end lint:')
    .pipe puglint.reporter('fail')

gulp.task 'watch', () ->
  @watching = true
  taskCount =
    coffee: 0
    jade: 0

  gulp.watch basePath+srcPath+"**/sass/**/*.scss", ['sass']

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
          for key2, file of val
            if file.indexOf(csFolder) isnt -1
              target = val[key2].split('/').reverse()[0]

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
          .pipe concat(target, {
            process:
              (src, filePath)->
                if filePath.indexOf(csFolder) isnt -1
                  src = src.split('\n')
                  for text, key in src
                    src[key] = '  '+text

                  src = src.join('\n')

                return src
          })
          .pipe gulp.dest(basePath+srcPath+'cs/')
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
        .pipe debug(title: 'start lint:')
        .pipe coffeeLint('./coffeelint.json')
        .pipe coffeeLint.reporter('coffeelint-stylish')
        .pipe coffeeLint.reporter('fail')
        .pipe debug(title: 'end lint:')
        #.pipe uglify()
        .pipe sourcemaps.init()
        .pipe coffee(
          bare: true
        )
        .pipe sourcemaps.write(
          './'
          sourceRoot: '../'+basePath+srcPath+'cs/'
        )
        .pipe gulp.dest(basePath+destPath+'js/')
        .pipe gulpif(!common(), remember('coffee'))
        .pipe debug(title: 'end coffee:')
        .on('end',
          ()->
            browserSync.reload()
        )

    gulp.start 'coffee'

  watch basePath+srcPath+'jade/**/*.jade', (e)->
    gulp.task 'jade', ['puglint'], ()->
      path = e.path

      partial = ()->
        return /\/_[^\/]+\.jade/.test(path)

      if path?
        if partial()
          path = [basePath+srcPath+'jade/**/*.jade', '!'+basePath+srcPath+'jade/**/mixin.jade', '!'+basePath+srcPath+'jade/**/_*.jade']
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
          .pipe jade(
            pretty: true
          )
          .pipe rename(
            extname: '.php'
          )
          .pipe gulp.dest(basePath+viewPath+jadeDestPath)
          .pipe debug(title: 'end jade:')
          .pipe gulpif(!partial(), remember('jade'))
          .on('end',
            ()->
              browserSync.reload()
          )

    gulp.start 'jade'

gulp.task 'default', ['webserver', 'watch']
