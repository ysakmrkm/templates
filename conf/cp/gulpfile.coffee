path = require('path')
gulp = require('gulp')
sass = require('gulp-sass')
sassImage = require('gulp-css-image-dimensions')
compassImporter = require('compass-importer')
scsslint = require('gulp-stylelint')
autoprefixer = require('gulp-autoprefixer')
cleanCss = require('gulp-clean-css')
coffee = require('gulp-coffee')
coffeeLint = require('gulp-coffeelint')
concat = require('gulp-concat-util')
sourcemaps = require('gulp-sourcemaps')
plumber = require('gulp-plumber')
debug = require('gulp-debug')
cache = require('gulp-cached')
changed = require('gulp-changed')
remember = require('gulp-remember')
watch = require('gulp-watch')
jade = require('gulp-jade')
jadeRef = require('gulp-jade/node_modules/jade')
puglint = require('gulp-pug-linter')
htmlmin = require('gulp-htmlmin')
rename = require('gulp-rename')
diff = require('gulp-diff-build')
del = require('del')
gulpif = require('gulp-if')
uglify = require('gulp-uglify')
notify = require('gulp-notify')
imagemin = require('gulp-imagemin')
pngquant = require('imagemin-pngquant')
mozjpeg  = require('imagemin-mozjpeg')
guetzli  = require('imagemin-guetzli')
svgo  = require('imagemin-svgo')
jp2  = require('gulp-jpeg-2000')
jxr  = require('gulp-jpeg-xr')
webp  = require('imagemin-webp')
browserSync = require('browser-sync').create()
minimist = require('minimist')
replace = require('gulp-replace')
homeDir = require('os').homedir()
args = minimist(process.argv.slice(2))

# --target
targetFolder = if args.target? and args.target.indexOf('/') is -1 then args.target+'/' else args.target
basePath = if targetFolder? then targetFolder else ''
srcPath = 'src/'
cssDestDir = 'css'
viewPath = 'views/'
csDestDir = 'cs'
jsDestDir = 'js'
pcDir = 'pc'
mobileDir = 'sp'
targetDir = if args.mode? and args.mode is 'pc' then pcDir else ''
targetDir = if targetDir is '' and args.mode is 'sp' then mobileDir else targetDir
targetPath = if targetDir is '' then '' else targetDir+'/'
destPath = if targetDir is 'pc' then '' else 'm/'
currentPath = path.resolve('')
currentFolder = currentPath.split('/').reverse()[0]
projectFolder = path.resolve('', '../').split('/').reverse()[0]+'/'+currentFolder
gulp.watching = false

gulp.task 'webserver', (done)->
  browserSync.init(
    proxy: if targetFolder? then 'localhost/'+currentFolder+'/'+targetFolder else 'localhost/'+currentFolder+'/'
    notify: false
  )

  done()

jadeRef.filters.php = (block) ->
  return "\n<?php\n"+block+"\n?>"

csCommonFolder = 'core'
csFolder = 'pages'

if args.mode is 'sp'
  csConcatRules = [
    [ basePath+srcPath+targetPath+csDestDir+'/'+csFolder+'/index.coffee' ]
    [ basePath+srcPath+targetPath+csDestDir+'/'+csFolder+'/fluxSlide.coffee',]
    [ basePath+srcPath+targetPath+csDestDir+'/'+csFolder+'/menu.coffee']
    [ basePath+srcPath+targetPath+csDestDir+'/'+csFolder+'/accordion.coffee']
    [ basePath+srcPath+targetPath+csDestDir+'/'+csFolder+'/anchor.coffee']
    [ basePath+srcPath+targetPath+csDestDir+'/'+csFolder+'/read-more.coffee']
    [ basePath+srcPath+targetPath+csDestDir+'/'+csFolder+'/toc.coffee']
    [ basePath+srcPath+targetPath+csDestDir+'/'+csFolder+'/rate.coffee']
    [ basePath+srcPath+targetPath+csDestDir+'/'+csFolder+'/contents.coffee']
    [ basePath+srcPath+targetPath+csDestDir+'/'+csFolder+'/qa.coffee']
    [ basePath+srcPath+targetPath+csDestDir+'/'+csFolder+'/error.coffee']
    [ basePath+srcPath+targetPath+csDestDir+'/'+csFolder+'/fixed-cv.coffee']
  ]
else if args.mode is 'pc'
  csConcatRules = [
    [ basePath+srcPath+targetPath+csDestDir+'/'+csCommonFolder+'/functions.coffee',
    basePath+srcPath+targetPath+csDestDir+'/'+csCommonFolder+'/header.coffee',
    basePath+srcPath+targetPath+csDestDir+'/'+csFolder+'/about.coffee',
    basePath+srcPath+targetPath+csDestDir+'/'+csCommonFolder+'/footer.coffee']
    [ basePath+srcPath+targetPath+csDestDir+'/'+csCommonFolder+'/functions.coffee',
    basePath+srcPath+targetPath+csDestDir+'/'+csCommonFolder+'/header.coffee',
    basePath+srcPath+targetPath+csDestDir+'/'+csFolder+'/case.coffee',
    basePath+srcPath+targetPath+csDestDir+'/'+csCommonFolder+'/footer.coffee']
    [ basePath+srcPath+targetPath+csDestDir+'/'+csCommonFolder+'/functions.coffee',
    basePath+srcPath+targetPath+csDestDir+'/'+csCommonFolder+'/header.coffee',
    basePath+srcPath+targetPath+csDestDir+'/'+csFolder+'/contents.coffee',
    basePath+srcPath+targetPath+csDestDir+'/'+csCommonFolder+'/footer.coffee']
    [ basePath+srcPath+targetPath+csDestDir+'/'+csCommonFolder+'/functions.coffee',
    basePath+srcPath+targetPath+csDestDir+'/'+csCommonFolder+'/header.coffee',
    basePath+srcPath+targetPath+csDestDir+'/'+csFolder+'/members.coffee',
    basePath+srcPath+targetPath+csDestDir+'/'+csCommonFolder+'/footer.coffee']
    [ basePath+srcPath+targetPath+csDestDir+'/'+csFolder+'/smooth-scroll.coffee']
    [ basePath+srcPath+targetPath+csDestDir+'/'+csFolder+'/fixed-contents.coffee']
    [ basePath+srcPath+targetPath+csDestDir+'/'+csFolder+'/rate.coffee']
    [ basePath+srcPath+targetPath+csDestDir+'/'+csCommonFolder+'/functions.coffee',
    basePath+srcPath+targetPath+csDestDir+'/'+csCommonFolder+'/header.coffee',
    basePath+srcPath+targetPath+csDestDir+'/'+csFolder+'/qa.coffee',
    basePath+srcPath+targetPath+csDestDir+'/'+csCommonFolder+'/footer.coffee']
    [ basePath+srcPath+targetPath+csDestDir+'/'+csFolder+'/toc.coffee']
    [ basePath+srcPath+targetPath+csDestDir+'/'+csFolder+'/error.coffee']
  ]

gulp.task 'imagenextgen', ()->
  # webp
  webpConf = {
    quality: 99
    method: 6
    nearLossless: 20
  }

  if targetDir is mobileDir
    webpConf.quality = 85
    webpConf.nearLossless = false

  gulp.src([
    basePath+srcPath+targetPath+'img/**/*.jpg',
    basePath+srcPath+targetPath+'img/**/*.gif',
    basePath+srcPath+targetPath+'img/**/*.png',
    '!'+basePath+srcPath+targetPath+'img/**/*-s+([a-z0-9]).png'
    ], {
      since: gulp.lastRun(imagenextgen)
    })
    .pipe diff({
      clear: true
      hash: 'webp'
    })
    .pipe changed(basePath+targetPath+destPath+'img', {extension: '.webp'})
    .pipe imagemin(
      [
        webp(webpConf)
      ],
      {verbose: true}
    )
    .pipe rename(
      extname: '.webp'
    )
    .pipe(gulp.dest(basePath+targetPath+destPath+'img'))
    .on('end',
      ()->
        console.log 'finish compress webp'
    )

  # jpeg 2000
  gulp.src([
    basePath+srcPath+targetPath+'img/**/*.jpg',
    basePath+srcPath+targetPath+'img/**/*.gif',
    basePath+srcPath+targetPath+'img/**/*.png',
    '!'+basePath+srcPath+targetPath+'img/**/*-s+([a-z0-9]).png'
    ], {
      since: gulp.lastRun(imagenextgen)
    })
    .pipe diff({
      clear: true
      hash: 'jpeg2000'
    })
    .pipe changed(basePath+targetPath+destPath+'img', {extension: '.jp2'})
    .pipe jp2({ quality: 100})
    .pipe rename(
      extname: '.jp2'
    )
    .pipe(gulp.dest(basePath+targetPath+destPath+'img'))
    .on('end',
      ()->
        console.log 'finish compress jpeg2000'
    )

  # jpeg xr
  gulp.src([
    basePath+srcPath+targetPath+'img/**/*.jpg',
    basePath+srcPath+targetPath+'img/**/*.gif',
    basePath+srcPath+targetPath+'img/**/*.png',
    '!'+basePath+srcPath+targetPath+'img/**/*-s+([a-z0-9]).png'
    ], {
      since: gulp.lastRun(imagenextgen)
    })
    .pipe diff({
      clear: true
      hash: 'jxr'
    })
    .pipe changed(basePath+targetPath+destPath+'img', {extension: '.jxr'})
    .pipe jxr(['-truecolours', '-tile', '32'])
    .pipe rename(
      extname: '.jxr'
    )
    .pipe(gulp.dest(basePath+targetPath+destPath+'img'))
    .on('end',
      ()->
        console.log 'finish compress jpeg xr'
    )

gulp.task 'imagemin', ()->
  gulp.src([
    basePath+srcPath+'img/**/*.gif', basePath+srcPath+'img/**/*.png', basePath+srcPath+'img/**/*.svg', '!'+basePath+srcPath+'img/**/*-s+([a-z0-9]).png'
    ], {
      since: gulp.lastRun(imagemin)
    })
    .pipe diff({
      clear: true
      hash: 'img'
    })
    .pipe changed(basePath+'img')
    # .pipe cache('imagemin1')
    .pipe imagemin(
      [
        pngquant({ quality: [.9, 1], speed: 1}),
        svgo({
          plugins: [
            {removeViewBox: false}
          ]
        }),
        imagemin.gifsicle({optimizationLevel: 3, colors: 190})
      ],
      {verbose: true}
    )
    .pipe imagemin(
      [
        svgo({
          plugins: [
            {removeViewBox: false}
          ]
        })
      ]
    )
    .pipe(gulp.dest(basePath+'img'))
    .on('end',
      ()->
        console.log 'finish compress (gif|png|svg|png)'
    )

  gulp.src([
    basePath+srcPath+'img/**/*.jpg'
    ], {
      since: gulp.lastRun(imagemin)
    })
    .pipe diff({
      clear: true
      hash: 'jpg'
    })
    .pipe changed(basePath+'img')
    # .pipe cache('imagemin2')
    .pipe imagemin(
      [
        guetzli({ quality: 90})
      ],
      {verbose: true}
    )
    .pipe imagemin()
    .pipe(gulp.dest(basePath+'img'))
    .on('end',
      ()->
        console.log 'finish compress jpg'
    )

gulp.task 'cssmin', ()->
  gulp.src([basePath+cssDestDir+'/'+targetPath+'**/*.css'])
    # .pipe sourcemaps.init()
    .pipe cleanCss({rebase: false})
    # .pipe sourcemaps.write(
    #   './'
    #   sourceRoot: '../'+basePath+destPath+cssDestDir
    # )
    .pipe gulp.dest(basePath+destPath+targetPath+cssDestDir)

gulp.task 'jsmin', ()->
  gulp.src([basePath+'js/'+targetPath+'**/*.js'])
    .pipe uglify()
    .pipe gulp.dest(basePath+destPath+targetPath+'js')

gulp.task 'htmlmin', ()->
  gulp.src([basePath+'views/'+targetPath+'**/*.php'])
    .pipe htmlmin({'collapseWhitespace': true})
    .pipe gulp.dest(basePath+'views/'+targetPath)

gulp.task 'release', gulp.parallel('cssmin', 'jsmin', 'htmlmin', 'imagemin')

gulp.task 'scsslint', ()->
  gulp.src basePath+srcPath+'**/sass/**/*.scss'
    .pipe plumber(
      errorHandler:
        notify.onError(
          title: "sass lint error"
          message: "<%= error %>"
        )
    )
    .pipe cache('scsslint')
    .pipe debug(title: 'start lint:')
    .pipe scsslint(
      reporters: [
        {formatter: 'string', console: true}
      ]
      fix: true
    )
    .pipe debug(title: 'end lint:')
    # .pipe gulp.dest(basePath+srcPath+'sass/')
    .pipe gulp.dest(basePath+srcPath)
    .pipe remember('scsslint')

gulp.task 'sass', ()->
  gulp.src [ basePath+srcPath+"#{targetPath}sass/**/*.scss", "!"+basePath+srcPath+"#{targetPath}sass/**/_*.scss" ]
    .pipe debug(title: 'start sass:')
    .pipe plumber(
      errorHandler:
        notify.onError(
          title: "sass compile error"
          message: "<%= error %>"
        )

      # this.emit('end')
    )
    .pipe sourcemaps.init()
    .pipe sassImage()
    .pipe sass({
      precision: 10
      outputStyle: 'expanded'
      importer: compassImporter
    })
    .pipe sassImage()
    .pipe autoprefixer()
    .pipe sourcemaps.write(
      ''
      includeContent: false
      sourceRoot: "../../src/#{targetPath}sass/"
    )
    .pipe debug(title: 'end sass:')
    # .pipe remember('sass')
    .pipe replace('src/', '')
    .pipe gulp.dest(basePath+cssDestDir+"/#{targetPath}")
    .pipe browserSync.stream()

gulp.task 'cleanCss', ()->
  baseDir = basePath+cssDestDir+"/"

  gulp.src "#{baseDir}**/*first.css"
    .pipe cleanCss()
    .pipe gulp.dest(basePath+destPath+cssDestDir)

gulp.task 'puglint', ()->
  baseDir = basePath+srcPath+targetPath+'jade/**/*.jade'

  gulp.src "#{baseDir}**/*.jade"
    .pipe debug(title: 'start lint:')
    .pipe cache('puglint')
    .pipe puglint({failAfterError: true})
    .pipe debug(title: 'end lint:')

gulp.task 'jade', ()->
  gulp.src basePath+srcPath+targetPath+'jade/**/*.jade'
    .pipe watch basePath+srcPath+targetPath+'jade/**/*.jade', (e)->
      path = e.path

      partial = ()->
        return /\/_[^\/]+\.jade/.test(path)

      if path?
        if partial()
          console.log(path)
          jadeDestPath = path.split(basePath+srcPath)[1].split('/')
          console.log(jadeDestPath)
          jadeDestPath.pop()
          console.log(jadeDestPath)
          jadeDestPath = jadeDestPath.join('/')+'/'
          jadeDestPath = jadeDestPath.replace('jade/', '')
          console.log(jadeDestPath)

          path = [basePath+srcPath+targetPath+'jade/**/*.jade', '!'+basePath+srcPath+targetPath+'jade/**/mixin.jade', '!'+basePath+srcPath+targetPath+'jade/components/**/*.jade', '!'+basePath+srcPath+targetPath+'jade/**/_*.jade']
          #
          # jadeDestPath = ''
        else
          console.log(path)
          jadeDestPath = path.split(basePath+srcPath)[1].split('/')
          console.log(jadeDestPath)
          jadeDestPath.pop()
          console.log(jadeDestPath)
          jadeDestPath = jadeDestPath.join('/')+'/'
          jadeDestPath = jadeDestPath.replace('jade/', '')
          console.log(jadeDestPath)

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

            # this.emit('end')
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

# isCommon = (e)->
#   path = e.path
#   isMobile = false
#
#   if path?
#     folder = path.split('/').reverse()[1]
#     target = path.split('/').reverse()[0]
#     mobile = path.split('/').reverse()[2]
#
#   if mobile is mobileDir
#     csDestPath = mobileDir+'/'
#     isMobile = true
#   else
#     csDestPath = ''
#
#   # common = ()->
#   console.log folder is csCommonFolder
#   return folder is csCommonFolder

gulp.task 'coffeeConcat', ()->
  gulp.src [basePath+srcPath+targetPath+csDestDir+'/**/*.coffee', '!'+basePath+srcPath+targetPath+csDestDir+'/*.coffee']
    .pipe watch [basePath+srcPath+targetPath+csDestDir+'/**/*.coffee', '!'+basePath+srcPath+targetPath+csDestDir+'/*.coffee'], (e)->
      path = e.path
      isMobile = false

      if path?
        folder = path.split('/').reverse()[1]
        target = path.split('/').reverse()[0]
        mobile = path.split('/').reverse()[2]

      if mobile is mobileDir
        csDestPath = mobileDir+'/'
        isMobile = true
      else
        csDestPath = ''

      common = ()->
        console.log folder is csCommonFolder
        return folder is csCommonFolder

      src = []

      if common()
        # src = csConcatRules

        for key, val of csConcatRules
          for key2, file of val
            if isMobile
              if file.indexOf(mobileDir) isnt -1
                src.push(val)
                break
            else
              if file.indexOf(mobileDir) is -1
                src.push(val)
                break
      else
        `getSrc://`
        for set, i in csConcatRules
          for file, j in set
            if file.indexOf(target) isnt -1
              src[0] = set
              `break getSrc`

      waitMax   = src.length
      waitCount = 0

      # onEnd = ()->
      #   if waitMax is ++waitCount
      #     callback()

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

            # this.emit('end')
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
          .pipe gulp.dest(basePath+srcPath+targetPath+csDestDir+'/'+csDestPath)
          .pipe debug(title: 'end concat:')
          # .on 'finish', ()->
          #   onEnd()

gulp.task 'coffee', ()->
  gulp.src basePath+srcPath+targetPath+csDestDir+'/*.coffee'
    .pipe watch basePath+srcPath+targetPath+csDestDir+'/*.coffee', (e)->
      path = e.path
      isMobile = false

      if path?
        folder = path.split('/').reverse()[1]
        target = path.split('/').reverse()[0]
        mobile = path.split('/').reverse()[2]

      if mobile is mobileDir
        csDestPath = mobileDir+'/'
        isMobile = true
      else
        csDestPath = ''

      common = ()->
        return folder is csCommonFolder

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

          # this.emit('end')
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
          sourceRoot: '../../'+basePath+srcPath+targetPath+csDestDir+'/'
        )
        # .pipe gulp.dest(basePath+destPath+jsDestDir+'/'+targetPath+csDestPath)
        .pipe gulp.dest(basePath+jsDestDir+'/'+targetPath)
        .pipe gulpif(!common(), remember('coffee'))
        .pipe debug(title: 'end coffee:')
        .on('end',
          ()->
            del basePath+srcPath+csDestDir+'/*.coffee'
            browserSync.reload()
        )

gulp.task 'watch', (done)->
  gulp.watch [basePath+srcPath+'img/**/*.(gif|png|svg|jpg)', '!'+basePath+srcPath+'img/**/*-s+([a-z0-9]).png'], gulp.parallel('imagenextgen', 'imagemin')

  gulp.watch basePath+srcPath+"**/sass/**/*.scss", gulp.series('scsslint', 'sass')

  gulp.watch [basePath+srcPath+targetPath+csDestDir+'/**/*.coffee', '!'+basePath+srcPath+targetPath+csDestDir+'/*.coffee'], gulp.series('coffeeConcat', 'coffee')

  gulp.watch basePath+srcPath+'**/jade/**/*.jade', gulp.series('puglint', 'jade')

  done()

gulp.task 'default', gulp.parallel('webserver', 'watch')
