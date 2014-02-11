module.exports = (grunt) ->
  #load package.json
  pkg = grunt.file.readJSON 'package.json'

  grunt.fileexpandMapping

  grunt.initConfig
      compassMultiple:
        options:
          config:'config.rb'
          debugInfo:true
          time:true
          multiple:[
            {
              sassDir:'sass'
              cssDir:'css'
            }
          ]
        dist:
          options:
            environment:'production'
          common:{}
        dev:
          common:{}
      coffee:
        compile:
          files:[
            {# {{{
              expand:true
              cwd:'cs/'
              src:['**/*.coffee']
              dest:'js/'
              ext:'.js'
            },# }}}
            {# {{{
              expand:true
              cwd:'sp/cs/'
              src:['**/*.coffee']
              dest:'sp/js/'
              ext:'.js'
            }# }}}
          ]
          options:
            bare:true
      uglify:
        dist:
          src:'js/function.js'
          dest:'js/function.min.js'
      imagemin:
        dist:
          options:
            optimizationLevel:3
          files:[
            expand:true
            src:'**/*.{png,jpg,jpeg}'
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
