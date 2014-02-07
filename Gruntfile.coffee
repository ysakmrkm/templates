module.exports = (grunt) ->
  #load package.json
  pkg = grunt.file.readJSON 'package.json'

  grunt.fileexpandMapping

  grunt.initConfig
    #start compass multiple # {{{
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
    #end compass multiple # }}}
    #start coffee # {{{
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
    #end coffee # }}}
    #start uglify # {{{
      uglify:
        dist:
          src:'js/function.js'
          dest:'js/function.min.js'
    #end uglify # }}}
    #start imagemin # {{{
      imagemin:
        dist:
          options:
            optimizationLevel:3
          files:[
            expand:true
            src:'**/*.{png,jpg,jpeg}'
          ]
    #end imagemin # }}}
    #start styleguide # {{{
      styleguide:
        styledocco:
          options:
            framework:
              name:'styledocco'
            name:'Style Guide'
          files:
            'docs':'docs/css/style.css'
    #end styleguide # }}}
    # start html lint # {{{
      htmllint:
        all:[
          '**/*.html'
          '**/*.php'
        ]
    # end html lint # }}}
    #start watch # {{{
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
        # }}}
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
        # }}}
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
        # }}}
        coffee: # {{{
          files:[
            '**/cs/*.coffee'
          ]
          tasks:['coffee','notify:coffee']
          options:
            debounceDelay:100
            nospawn:true
            livereload:true
        # }}}
    #end watch # }}}
    #start notify # {{{
      notify:
        file: # {{{
          options:
            title:'Grunt Notify'
            message:'Change file'
        # }}}
        img: # {{{
          options:
            title:'Grunt Notify'
            message:'Change img'
        # }}}
        sass: # {{{
          options:
            title:'Grunt Notify'
            message:'Change Sass'
        # }}}
        coffee: # {{{
          options:
            title:'Grunt Notify'
            message:'Change Coffee Script'
        # }}}
    #end notify # }}}

  #変更のあったファイルへのタスク適応
  grunt.event.on('watch'
    (action,filepath)->
      grunt.config(['htmllint','all'],[filepath])
  )

  #load plugins
  for taskName of pkg.devDependencies when taskName.substring(0, 6) is 'grunt-'
    grunt.loadNpmTasks taskName

  #define 'default' task
  grunt.registerTask 'default',['watch']
  grunt.registerTask 'release',['compassMultiple:dist','uglify','imagemin']
