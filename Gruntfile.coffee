module.exports = (grunt) ->
  #load package.json
  pkg = grunt.file.readJSON 'package.json'

  grunt.fileexpandMapping

  grunt.initConfig
      compassMultiple:
        options:
          sassDir:'sass'
        dev:
          options:
            config:'config.rb'
        dist:
          options:
            environment:'production'
            cssDir:'release/css'
      coffee:
        compile:
          expand:true
          cwd:'cs/'
          src:['**/*.coffee']
          dest:'js/'
          ext:'.js'
        options:
          bare:true
      uglify:
        options:
          sourceMap:true
        dist:
          expand:true
          cwd:'js/'
          src:'*.js'
          dest:'release/js/'
      imagemin:
        dist:
          options:
            optimizationLevel:3
          files:[
            expand:true
            src:'img/**/*.{png,jpg,jpeg}'
            dest:'release/'
          ]
      styleguide:
        styledocco:
          options:
            framework:
              name:'styledocco'
            name:'Style Guide'
          files:
            'docs':'docs/css/style.css'
      htmllint:
        all:[
          '**/*.html'
          '**/*.php'
        ]
      watch:
        file: # {{{
          files:[
            '**/*.html'
            '**/*.php'
          ]
          #tasks:['htmllint','notify:file']
          tasks:['notify:file']
          options:
            nospawn:true
            livereload:true
        img: # {{{
          files:[
            '**/img/*.gif'
            '**/img/*.jpg'
            '**/img/*.png'
          ]
          tasks:['notify:img']
          options:
            nospawn:true
            livereload:true
        sass: # {{{
          files:[
            '**/sass/**/*.scss'
            '**/sass/**/*.sass'
          ]
          tasks:['compassMultiple:dev','styleguide','notify:sass']
          options:
            debounceDelay:100
            nospawn:true
            livereload:true
        coffee: # {{{
          files:[
            '**/cs/*.coffee'
          ]
          tasks:['coffee','notify:coffee']
          options:
            debounceDelay:100
            nospawn:true
            livereload:true
      notify:
        file:
          options:
            title:'Grunt Notify'
            message:'Change file'
        img:
          options:
            title:'Grunt Notify'
            message:'Change img'
        sass:
          options:
            title:'Grunt Notify'
            message:'Change Sass'
        coffee:
          options:
            title:'Grunt Notify'
            message:'Change Coffee Script'

  #load plugins
  for taskName of pkg.devDependencies when taskName.substring(0, 6) is 'grunt-'
    grunt.loadNpmTasks taskName

  #define 'default' task
  grunt.registerTask 'default',['watch']
  grunt.registerTask 'release',['compassMultiple:dist','uglify','imagemin']
